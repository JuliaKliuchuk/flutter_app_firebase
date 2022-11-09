import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewPage extends StatefulWidget {
  final String url;

  const WebViewPage({Key? key, required this.url}) : super(key: key);

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  late WebViewController webController;
  bool _isLoading = true;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (await webController.canGoBack()) {
          webController.goBack();
        }
        return false;
      },
      child: Stack(
        children: <Widget>[
          _isLoading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : const SizedBox(),
          WebView(
            initialUrl: widget.url,
            javascriptMode: JavascriptMode.unrestricted,
            onPageFinished: (finish) {
              setState(() {
                _isLoading = false;
              });
            },
          ),
        ],
      ),
    );
  }
}
