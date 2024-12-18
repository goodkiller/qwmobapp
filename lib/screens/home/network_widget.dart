import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class NetworkConnectionWidget extends StatelessWidget {
  final Widget child;

  const NetworkConnectionWidget({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ConnectivityResult>(
      future: Connectivity().checkConnectivity().then((list) => list.first),
      builder: (BuildContext context, AsyncSnapshot<ConnectivityResult> futureSnapshot) {
        // Show loading indicator while waiting for the Future
        if (futureSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              color: Color(0xff8e91d5),
            ),
          );
        }

        // FutureBuilder complete, set initial network state
        final ConnectivityResult initialResult = futureSnapshot.data ?? ConnectivityResult.none;

        return StreamBuilder<ConnectivityResult>(
          stream: Connectivity()
              .onConnectivityChanged
              .map((list) => list.first), // Ensure single ConnectivityResult
          initialData: initialResult,
          builder: (BuildContext context, AsyncSnapshot<ConnectivityResult> streamSnapshot) {
            final ConnectivityResult? result = streamSnapshot.data;

            if (result != null && result != ConnectivityResult.none) {
              // If connected, show the child widget
              return child;
            } else {
              // If offline, show an offline image
              return Center(
                child: Image.asset("assets/images/offline.png"),
              );
            }
          },
        );
      },
    );
  }
}
