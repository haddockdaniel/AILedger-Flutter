import 'dart:io';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:autoledger/utils/constants.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});
  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  late final String approvalUrl;

  @override
  void initState() {
    super.initState();
    // WebView on Android needs this
    if (Platform.isAndroid) WebView.platform = AndroidWebView();
    approvalUrl = ModalRoute.of(context)!.settings.arguments as String;
  }

  @override
  Widget build(BuildContext c) {
    return Scaffold(
      appBar: AppBar(title: const Text('Complete Subscription')),
      body: WebView(
        initialUrl: approvalUrl,
        javascriptMode: JavascriptMode.unrestricted,
        navigationDelegate: (nav) {
          final uri = Uri.parse(nav.url);
          // PayPal redirects to execute-subscription
          if (uri.path.contains('/execute-subscription')) {
            // extract token & userId
            final token = uri.queryParameters['token']!;
            final userId = uri.queryParameters['userId']!;
            // call execute on backend
            PaymentService.executeSubscription(token, userId)
                .then((_) => Navigator.pushReplacementNamed(c, '/dashboard'))
                .catchError((e) => ScaffoldMessenger.of(c)
                    .showSnackBar(SnackBar(content: Text('Error: $e'))));
            return NavigationDecision.prevent;
          }
          return NavigationDecision.navigate;
        },
      ),
    );
  }
}
