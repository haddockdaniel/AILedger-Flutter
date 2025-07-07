import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:autoledger/services/invoice_service.dart';
import 'package:autoledger/services/ai_insight_service.dart';
import 'package:autoledger/theme/app_theme.dart';
import 'package:autoledger/widgets/skeleton_loader.dart';

import '../../models/invoice_model.dart';

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

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final invoices = await InvoiceService.getInvoices();
      final forecast = await AIInsightService.forecastCashFlow();
      final risk = await AIInsightService.latePaymentRiskScores(invoices: invoices);
      final basic = await AIInsightService.getInsights();
      setState(() {
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
      print('Failed to load analytics: $e');
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
    return LineChart(
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
    );
  }

  Widget _buildBarChart(List<Map<String, dynamic>> data) {
    return BarChart(
      BarChartData(
        titlesData: FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: [
          for (int i = 0; i < data.length; i++)
            BarChartGroupData(x: i, barRods: [BarChartRodData(y: data[i]['value'], colors: [AppTheme.accentColor])])
        ],
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
            SizedBox(height: 200, child: _buildLineChart(_sales)),
            const SizedBox(height: 24),
            SizedBox(height: 200, child: _buildBarChart(_overdue)),
            const SizedBox(height: 24),
            SizedBox(height: 200, child: _buildLineChart(_cashFlow)),
            const SizedBox(height: 24),
            _buildInsightCards(),
          ],
        ),
      ),
    );
  }
}