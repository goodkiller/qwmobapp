import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class NetworkConnectionWidget extends StatelessWidget {
  final Widget child;

  const NetworkConnectionWidget({required this.child, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ConnectivityResult>(
      future: Connectivity().checkConnectivity(),
      builder:
          (BuildContext context, AsyncSnapshot<ConnectivityResult> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator(
            color: Color(0xff8e91d5),
          );
        } else {
          return StreamBuilder<ConnectivityResult>(
            stream: Connectivity().onConnectivityChanged,
            initialData: snapshot.data,
            builder: (BuildContext context,
                AsyncSnapshot<ConnectivityResult> snapshot) {
              if (snapshot.hasData &&
                  snapshot.data != ConnectivityResult.none) {
                return child;
              } else {
                return Center(
                  child: Image.asset("assets/images/offline.png"),
                );
              }
            },
          );
        }
      },
    );
  }
}
