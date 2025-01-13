import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class NetworkConnectionWidget extends StatelessWidget {
  final Widget child;

  const NetworkConnectionWidget({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ConnectivityResult>(
      future: Connectivity().checkConnectivity(),
      builder: (BuildContext context, AsyncSnapshot<ConnectivityResult> futureSnapshot) {
        if (futureSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              color: Color(0xff8e91d5),
            ),
          );
        }

        final ConnectivityResult initialResult = futureSnapshot.data ?? ConnectivityResult.none;

        return StreamBuilder<ConnectivityResult>(
          stream: Connectivity().onConnectivityChanged, // Ensure this returns a Stream<ConnectivityResult>
          initialData: initialResult,
          builder: (BuildContext context, AsyncSnapshot<ConnectivityResult> streamSnapshot) {
            final ConnectivityResult? result = streamSnapshot.data;

            if (result != null && result != ConnectivityResult.none) {
              return child; // Show child if connected
            } else {
              return Center(
                child: Image.asset("assets/images/offline.png"), // Show offline image if disconnected
              );
            }
          },
        );
      },
    );
  }
}
