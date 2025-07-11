import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:autoledger/services/invoice_service.dart';
import 'package:autoledger/services/ai_insight_service.dart';
import 'package:autoledger/services/customer_service.dart';
import 'package:autoledger/theme/app_theme.dart';
import 'package:autoledger/widgets/skeleton_loader.dart';
import 'package:intl/intl.dart';

import '../../models/invoice_model.dart';
import '../../models/customer_model.dart';
import 'filtered_invoices.dart';

class AnalyticsDashboard extends StatefulWidget {
  const AnalyticsDashboard({Key? key}) : super(key: key);

  @override
  State<AnalyticsDashboard> createState() => _AnalyticsDashboardState();
}

class _AnalyticsDashboardState extends State<AnalyticsDashboard> {
  bool _loading = true;
  List<Map<String, dynamic>> _sales = [];
  List<Map<String, dynamic>> _overdue = [];
  List<Map<String, dynamic>> _cashFlow = [];
  Map<String, dynamic>? _insights;
  DateTime _startDate = DateTime(DateTime.now().year, 1, 1);
  DateTime _endDate = DateTime.now();
  String? _customerId;
  List<Customer> _customers = [];
  List<Invoice> _filteredInvoices = [];

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    _customers = await CustomerService.fetchCustomers();
    await _loadData();
  }

  Future<void> _loadData() async {
    try {
      List<Invoice> invoices;
      if (_customerId != null) {
        invoices = await InvoiceService.getInvoicesByCustomerId(_customerId!);
      } else {
        invoices = await InvoiceService.getInvoices();
      }

      invoices = invoices.where((inv) {
        return inv.invoiceDate.isAfter(_startDate.subtract(const Duration(days: 1))) &&
            inv.invoiceDate.isBefore(_endDate.add(const Duration(days: 1)));
      }).toList();

      final forecast = await AIInsightService.forecastCashFlow(invoices: invoices);
      final risk = await AIInsightService.latePaymentRiskScores(invoices: invoices);
      final basic = await AIInsightService.getInsights();

      setState(() {
        _filteredInvoices = invoices;
        _sales = _buildMonthlySales(invoices);
        _overdue = _buildOverdueAmounts(invoices);
        _cashFlow = forecast;
        _insights = {
          ...basic,
          'Late Payment Risk': risk.map((e) => "${e['name']}: ${e['score']}%").join("\n")
        };
        _loading = false;
      });
    } catch (e) {
      debugPrint('Failed to load analytics: $e');
      setState(() => _loading = false);
    }
  }

  List<Map<String, dynamic>> _buildMonthlySales(List<Invoice> invoices) {
    final Map<String, double> totals = {};
    for (final inv in invoices.where((i) => i.isPaid)) {
      final key = "${inv.invoiceDate.year}-${inv.invoiceDate.month}";
      totals[key] = (totals[key] ?? 0) + inv.total;
    }
    final entries = totals.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    return [for (final e in entries) {'label': e.key, 'value': e.value}];
  }

  List<Map<String, dynamic>> _buildOverdueAmounts(List<Invoice> invoices) {
    final now = DateTime.now();
    final Map<String, double> totals = {};
    for (final inv in invoices.where((i) => !i.isPaid && i.dueDate != null && i.dueDate!.isBefore(now))) {
      final key = "${inv.dueDate!.year}-${inv.dueDate!.month}";
      totals[key] = (totals[key] ?? 0) + inv.total;
    }
    final entries = totals.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    return [for (final e in entries) {'label': e.key, 'value': e.value}];
  }

  Widget _buildLineChart(List<Map<String, dynamic>> data) {
    return GestureDetector(
      onTap: () => _openInvoiceList(),
      child: LineChart(
        LineChartData(
          titlesData: FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: [for (int i = 0; i < data.length; i++) FlSpot(i.toDouble(), data[i]['value'])],
              isCurved: true,
              barWidth: 3,
              color: AppTheme.accentColor,
              dotData: FlDotData(show: false),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildBarChart(List<Map<String, dynamic>> data) {
    return GestureDetector(
      onTap: () => _openInvoiceList(),
      child: BarChart(
        BarChartData(
          titlesData: FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          barGroups: [
            for (int i = 0; i < data.length; i++)
              BarChartGroupData(x: i, barRods: [BarChartRodData(y: data[i]['value'], colors: [AppTheme.accentColor])])
          ],
        ),
      ),
    );
  }

  Widget _buildInsightCards() {
    if (_insights == null) return const SizedBox.shrink();
    return Column(
      children: _insights!.entries
          .map((e) => Card(
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: ListTile(
                  title: Text(e.key, style: AppTheme.subHeaderStyle),
                  subtitle: Text(e.value.toString()),
                ),
              ))
          .toList(),
    );
  }

  void _openInvoiceList() {
    if (_filteredInvoices.isEmpty) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FilteredInvoices(
          invoices: _filteredInvoices,
          title: 'Invoices',
        ),
      ),
    );
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      _loadData();
    }
  }

  Widget _buildFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButton<String?>(
          value: _customerId,
          hint: const Text('All Customers'),
          onChanged: (val) {
            setState(() => _customerId = val);
            _loadData();
          },
          items: [
            const DropdownMenuItem(value: null, child: Text('All Customers')),
            ..._customers.map((c) => DropdownMenuItem(
                  value: c.customerId,
                  child: Text(c.fullName),
                )),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Text('From: ${DateFormat.yMd().format(_startDate)}'),
            const SizedBox(width: 16),
            Text('To: ${DateFormat.yMd().format(_endDate)}'),
            IconButton(
              icon: const Icon(Icons.date_range),
              onPressed: _pickDateRange,
            )
          ],
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        appBar: AppBar(title: Text('Analytics')),
        body: Center(child: SkeletonLoader(itemCount: 3)),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Analytics')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildFilters(),
            const SizedBox(height: 16),
            SizedBox(height: 200, child: _buildLineChart(_sales)),
            const SizedBox(height: 24),
            SizedBox(height: 200, child: _buildBarChart(_overdue)),
            const SizedBox(height: 24),
            SizedBox(height: 200, child: _buildLineChart(_cashFlow)),
            const SizedBox(height: 24),
            _buildInsightCards(),
            if (_filteredInvoices.isNotEmpty) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _openInvoiceList,
                child: const Text('View Invoices'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}