import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:provider/provider.dart';
import 'package:qilowatt/provider/locale_provider.dart';

const String baseUri = 'https://app.qilowatt.it/';

class HomeController {
  InAppWebViewController? webViewController;

  bool isFCMTokenChecked = false;

  String? token;

  Future<String?> getFirebaseToken() async {
    await FirebaseMessaging.instance
        .getAPNSToken()
        .timeout(const Duration(seconds: 10));
    token = await FirebaseMessaging.instance.getToken();
    return token;
  }

  Future<dynamic> _getJwtDataFromCookies(
      InAppWebViewController? controller, BuildContext context) async {
    final String cookies =
        ((await controller?.evaluateJavascript(source: 'document.cookie')) ??
            '') as String;

    final jwtCookie = cookies
        .split(';')
        .firstWhere((cookie) => cookie.contains('jwt='), orElse: () => '');

    if (jwtCookie != '') {
      final jwt = jwtCookie.replaceAll('jwt=', '');
      final decodedPayload = _decodeBase64Url(jwt.split('.')[1]);

      return json.decode(decodedPayload);
    } else {
      return null;
    }
  }

  String _decodeBase64Url(String input) {
    final normalizedInput = input.replaceAll('-', '+').replaceAll('_', '/');

    switch (normalizedInput.length % 4) {
      case 0:
        break;
      case 2:
        return utf8.decode(base64Url.decode('$normalizedInput=='));
      case 3:
        return utf8.decode(base64Url.decode('$normalizedInput='));
      default:
        throw Exception('Illegal base64url string!"');
    }

    return utf8.decode(base64Url.decode(normalizedInput));
  }

  Future<void> _updateTokenIfNeeded(String userId, String token) async {
    final firestoreDocRef =
        FirebaseFirestore.instance.collection("fcmTokens").doc(userId);

    final event = await firestoreDocRef.get();
    String? storedToken = event.data()?["token"];

    final currentUtc = DateTime.now().toUtc();
    Map<String, String?> firestoreData = {
      "last_activity": currentUtc.toString()
    };

    if (token != storedToken) {
      firestoreData["timestamp"] = currentUtc.toString();
      firestoreData["token"] = token;
      firestoreData["platform"] = Platform.operatingSystem;
    }

    if (storedToken == null) {
      firestoreDocRef.set(firestoreData);
    } else {
      firestoreDocRef.update(firestoreData);
    }
  }

  Future<void> onPageLoaded(String value, BuildContext context) async {
    if (value == "https://app.qilowatt.it/login" && token == null) {
      isFCMTokenChecked = false;
    } else if (value == baseUri ||
        value == "https://app.qilowatt.it/account/profile") {
      final jwtPayload =
          await _getJwtDataFromCookies(webViewController, context);

      if (jwtPayload == null) {
        return;
      }

      _updateAppLanguage(jwtPayload, context);
      await _checkFCMToken(jwtPayload);
    }
  }

  Future<void> _checkFCMToken(jwtPayload) async {
    if (!isFCMTokenChecked && token != null) {
      String userId = jwtPayload['id'];

      try {
        await _updateTokenIfNeeded(userId, token!);
        isFCMTokenChecked = true;
      } catch (exception) {
        await FirebaseAnalytics.instance
            .logEvent(name: "exception", parameters: {
          "receivedAt": DateTime.now().toUtc().toIso8601String(),
          "error": exception,
        });
      }
    } else {
      isFCMTokenChecked = false;
    }
  }

  void _updateAppLanguage(jwtPayload, BuildContext context) {
    String languageCode = jwtPayload['language_code'];

    Locale locale = Locale(languageCode);
    Provider.of<LocaleProvider>(context, listen: false).setLocale(locale);
  }

  void onPopInvoked(bool canPop) {
    webViewController?.goBack();
  }
}
