import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:qilowatt/screens/home/home_controller.dart';
import 'package:qilowatt/screens/home/network_widget.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Home extends StatefulWidget {
  final String? redirectUrl;

  const Home({super.key, this.redirectUrl});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final homeController = HomeController();

  @override
  Widget build(BuildContext context) {
    final pullToRefreshController = PullToRefreshController(
      settings: PullToRefreshSettings(
        color: const Color(0xff8e91d5),
      ),
      onRefresh: () async {
        await homeController.webViewController?.reload();
      },
    );
    return SafeArea(
        child: Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Center(
            child: Image.asset(
              'assets/icons/logo-sm-dark.png',
              width: 200,
            ),
          ),
          NetworkConnectionWidget(
            child: FutureBuilder(
                future: homeController.getFirebaseToken(),
                builder: (context, contentSnapshot) {
                  if (contentSnapshot.hasData) {
                    return PopScope(
                        onPopInvoked: (canPop) =>
                            homeController.onPopInvoked(canPop),
                        canPop: false,
                        child: InAppWebView(
                            initialSettings: InAppWebViewSettings(
                              javaScriptEnabled: true,
                              userAgent: 'QILOWATT-APP',
                              transparentBackground: true,
                            ),
                            initialUrlRequest:
                                URLRequest(url: WebUri.uri(Uri.parse(baseUri))),
                            onWebViewCreated: (controller) =>
                                homeController.webViewController = controller,
                            onLoadStop: (controller, url) async {
                              pullToRefreshController.endRefreshing();
                              return homeController.onPageLoaded(
                                  url.toString(), context);
                            },
                            pullToRefreshController: pullToRefreshController,
                            onReceivedError: (controller, request, error) {
                              setState(() {});
                            }));
                  }
                  if (contentSnapshot.hasError) {
                    return Center(
                      child: Text(
                        AppLocalizations.of(context)?.thereHasBeenAProblem ??
                            'There has been a problem. Please restart the app.',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }
                  return const Center(
                      child: CircularProgressIndicator(
                    color: Color(0xff8e91d5),
                  ));
                }),
          ),
        ],
      ),
    ));
  }
}
