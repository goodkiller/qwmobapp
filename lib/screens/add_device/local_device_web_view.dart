import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:webview_flutter/webview_flutter.dart';

class LocalDeviceWebView extends StatelessWidget {
  LocalDeviceWebView({Key? key}) : super(key: key);
  final String BASE_URI = 'http://192.168.4.1';
  late WebViewController webViewController;

  @override
  Widget build(BuildContext context) {
    webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onWebResourceError: (error) {},
        onPageFinished: (url) => webViewController
            .runJavaScriptReturningResult("document.documentElement.innerHTML")
            .then((value) {
          String? result = value as String;
          if (result.toLowerCase().contains("successful wifi connection")) {
            Navigator.of(context).pop();
            Navigator.of(context).pop();
          }
        }),
      ))
      ..loadRequest(Uri.parse(BASE_URI));

    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title: SizedBox(
            height: 36,
            width: 36,
            child: SvgPicture.asset('assets/icons/logo-sm-dark.svg')),
      ),
      body: WebViewWidget(
        controller: webViewController,
      ),
    ));
  }
}
