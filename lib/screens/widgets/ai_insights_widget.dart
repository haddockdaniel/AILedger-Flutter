import 'package:flutter/material.dart';
import 'package:autoledger/services/ai_insight_service.dart';
import 'package:autoledger/theme/app_theme.dart';
import 'package:autoledger/widgets/skeleton_loader.dart';

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
      final basic = await AIInsightService.getInsights();
      final cashFlow = await AIInsightService.forecastCashFlow();
      final risk = await AIInsightService.latePaymentRiskScores();
      final cltv = await AIInsightService.predictCustomerLifetimeValue();
      final anomalies = await AIInsightService.detectExpenseAnomalies();
      final actions = await AIInsightService.nextBestCustomerAction();

      String cashFlowSummary = cashFlow
          .map((e) => "${e['date'].month}/${e['date'].day}: \${e['net'].toStringAsFixed(2)}")
          .join("\n");
      String riskSummary = risk.map((e) => "${e['name']}: ${e['score']}%").join("\n");
      String cltvSummary = cltv.map((e) => "${e['name']}: \$${e['cltv']}").join("\n");
      String anomalySummary = anomalies.isEmpty
          ? 'No anomalies detected'
          : anomalies
              .map((e) => "${e.vendor}: \$${e.amount.toStringAsFixed(2)} on ${e.date.month}/${e.date.day}")
              .join("\n");
      String actionSummary = actions.map((e) => "${e['name']}: ${e['action']}").join("\n");

      setState(() {
        _insights = {
          ...basic,
          'Cash Flow Forecast': cashFlowSummary,
          'Late Payment Risk': riskSummary,
          'CLTV Prediction': cltvSummary,
          'Expense Anomalies': anomalySummary,
          'Next Best Action': actionSummary,
        };
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
    if (_loading) return const Center(child: SkeletonLoader(itemCount: 4));

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
			if (_insights!.containsKey('Cash Flow Forecast'))
              _buildInsightCard("Cash Flow Forecast", _insights!['Cash Flow Forecast']),
            if (_insights!.containsKey('Late Payment Risk'))
              _buildInsightCard("Late Payment Risk", _insights!['Late Payment Risk']),
            if (_insights!.containsKey('CLTV Prediction'))
              _buildInsightCard("CLTV Prediction", _insights!['CLTV Prediction']),
            if (_insights!.containsKey('Expense Anomalies'))
              _buildInsightCard("Expense Anomalies", _insights!['Expense Anomalies']),
            if (_insights!.containsKey('Next Best Action'))
              _buildInsightCard("Next Best Action", _insights!['Next Best Action']),
          ],
        ),
      ),
    );
  }
}
