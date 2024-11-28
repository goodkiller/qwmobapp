import 'dart:async';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:provider/provider.dart';
import 'package:qilowatt/notification_service.dart';
import 'package:qilowatt/provider/locale_provider.dart';
import 'package:qilowatt/screens/home/home.dart';
import 'package:qilowatt/screens/home/home_controller.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async =>
    NotificationService.buildNotificationWithActions(message);

Future<void> main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  await NotificationService.initNotifications();

  FlutterNativeSplash.remove();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (context) => LocaleProvider(),
        builder: (context, child) {
          LocaleProvider provider = Provider.of<LocaleProvider>(context);
          return MaterialApp(
            navigatorKey: MyApp.navigatorKey,
            theme: ThemeData(
              useMaterial3: true,
              scaffoldBackgroundColor: Colors.white,
              canvasColor: Colors.white,
              colorScheme: ColorScheme.fromSeed(
                  primary: Colors.white,
                  secondary: Colors.white,
                  onBackground: Colors.white,
                  tertiary: Colors.white,
                  seedColor: Colors.white,
                  surface: Colors.white,
                  surfaceTint: Colors.white),
            ),
            initialRoute: "/",
            title: 'qilowatt',
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en'), // English
              Locale('et'), // Spanish
            ],
            locale: provider.locale,
            home: const Home(
              redirectUrl: baseUri,
            ),
          );
        });
  }
}
