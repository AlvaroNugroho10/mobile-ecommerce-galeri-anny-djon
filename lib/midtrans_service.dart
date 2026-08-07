import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class MidtransService {
  static void openPaymentPage(
    BuildContext context,
    String token,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MidtransWebView(token: token),
      ),
    );
  }
}

class MidtransWebView extends StatefulWidget {
  final String token;

  const MidtransWebView({
    super.key,
    required this.token,
  });

  @override
  State<MidtransWebView> createState() =>
      _MidtransWebViewState();
}

class _MidtransWebViewState
    extends State<MidtransWebView> {

  late final WebViewController controller;

  @override
  void initState() {
    super.initState();

    controller = WebViewController()
      ..setJavaScriptMode(
        JavaScriptMode.unrestricted,
      )
      ..loadRequest(
        Uri.parse(
          "https://app.sandbox.midtrans.com/snap/v2/vtweb/${widget.token}",
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pembayaran"),
      ),
      body: WebViewWidget(
        controller: controller,
      ),
    );
  }
}