import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:autoledger/services/report_service.dart';
import 'package:autoledger/theme/app_theme.dart';
import 'package:autoledger/utils/voice_assistant.dart';
import 'package:autoledger/utils/voice_event_bus.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:autoledger/widgets/skeleton_loader.dart';  // ← new

class ReportsWidget extends StatefulWidget {
  @override
  _ReportsWidgetState createState() => _ReportsWidgetState();
}

class _ReportsWidgetState extends State<ReportsWidget> {
  String selectedReport = "Tax";
  DateTime startDate = DateTime(DateTime.now().year, 1, 1);
  DateTime endDate = DateTime.now();
  String? customerId;
  String? vendor;
  String reportContent = '';
  bool isLoading = false;

  final List<String> reportTypes = [
    "Tax",
    "Customer",
    "Invoice Aging",
    "Expense",
    "Cash Flow"
  ];

  @override
  void initState() {
    super.initState();
    VoiceEventBus().on('refresh_reports', (_) => _loadReport());
    VoiceEventBus().on('set_report_type', (type) {
      setState(() => selectedReport = type);
      _loadReport();
    });
    VoiceEventBus().on('export_report', (format) => _exportReport(format));
    _loadReport();
  }

  Future<void> _loadReport() async {
    setState(() => isLoading = true);
    final content = await ReportService.generateReport(
      reportType: selectedReport,
      from: startDate,
      to: endDate,
      customerId: customerId,
      vendor: vendor,
    );
    setState(() {
      reportContent = content;
      isLoading = false;
    });
  }

  Future<void> _exportReport(String format) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final dir = await getTemporaryDirectory();
    final path = '${dir.path}/${selectedReport}_report_$now.$format';
    File file = File(path);

    switch (format) {
      case 'json':
        await file.writeAsString(json.encode({"report": reportContent}));
        break;
      case 'csv':
        final csv = reportContent.replaceAll('\n', ',\n');
        await file.writeAsString(csv);
        break;
      case 'pdf':
        await ReportService.exportPdf(reportContent, path);
        break;
      default:
        return;
    }

    Share.shareXFiles([XFile(path)], text: "Here is the $selectedReport report");
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: startDate, end: endDate),
    );
    if (picked != null) {
      setState(() {
        startDate = picked.start;
        endDate = picked.end;
      });
      _loadReport();
    }
  }

  Widget buildDropdown() {
    return DropdownButton<String>(
      value: selectedReport,
      onChanged: (val) {
        setState(() => selectedReport = val!);
        _loadReport();
      },
      items: reportTypes.map((r) {
        return DropdownMenuItem(value: r, child: Text(r));
      }).toList(),
    );
  }

  Widget buildFilters() {
    return Column(
      children: [
        buildDropdown(),
        SizedBox(height: 8),
        Row(
          children: [
            Text("From: ${DateFormat.yMd().format(startDate)}"),
            SizedBox(width: 16),
            Text("To: ${DateFormat.yMd().format(endDate)}"),
            IconButton(
              icon: Icon(Icons.date_range),
              onPressed: _pickDateRange,
            )
          ],
        ),
      ],
    );
  }

  Widget buildExportButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
          onPressed: () => _exportReport('pdf'),
          child: Text("Export PDF"),
        ),
        ElevatedButton(
          onPressed: () => _exportReport('csv'),
          child: Text("Export CSV"),
        ),
        ElevatedButton(
          onPressed: () => _exportReport('json'),
          child: Text("Export JSON"),
        ),
      ],
    );
  }

  Widget buildReportDisplay() {
    if (isLoading) {
      return const Expanded(child: SkeletonLoader());  // ← replaced spinner
    }
    return Expanded(
      child: RefreshIndicator(
        onRefresh: _loadReport,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(12),
          physics: const AlwaysScrollableScrollPhysics(),
          child: SelectableText(reportContent),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text("Reports"),
        backgroundColor: AppTheme.primaryColor,
        actions: [
          IconButton(
            icon: Icon(Icons.mic),
            tooltip: "Voice Command",
            onPressed: () => VoiceAssistant().startListening(),
          )
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(padding: EdgeInsets.all(12), child: buildFilters()),
          buildExportButtons(),
          buildReportDisplay(),
        ],
      ),
    );
  }
}
