import 'package:flutter/material.dart';
import 'package:autoledger/services/ai_insight_service.dart';
import 'package:autoledger/theme/app_theme.dart';

class AIInsightsWidget extends StatefulWidget {
  const AIInsightsWidget({Key? key}) : super(key: key);

  @override
  State<AIInsightsWidget> createState() => _AIInsightsWidgetState();
}

class _AIInsightsWidgetState extends State<AIInsightsWidget> {
  Map<String, dynamic>? _insights;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchInsights();
  }

  Future<void> _fetchInsights() async {
    try {
      final insights = await AIInsightService.getInsights();
      setState(() {
        _insights = insights;
        _loading = false;
      });
    } catch (e) {
      print('Error loading AI insights: $e');
      setState(() => _loading = false);
    }
  }

  Widget _buildInsightCard(String title, String summary) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(title, style: AppTheme.subHeaderStyle),
        subtitle: Text(summary),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());

    if (_insights == null || _insights!.isEmpty) {
      return const Center(child: Text("No AI insights available."));
    }

    return Scaffold(
      appBar: AppBar(title: const Text("AI Insights")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            if (_insights!.containsKey('invoices'))
              _buildInsightCard("Invoices", _insights!['invoices']),
            if (_insights!.containsKey('tasks'))
              _buildInsightCard("Tasks", _insights!['tasks']),
            if (_insights!.containsKey('emails'))
              _buildInsightCard("Emails", _insights!['emails']),
            if (_insights!.containsKey('general'))
              _buildInsightCard("General", _insights!['general']),
          ],
        ),
      ),
    );
  }
}
