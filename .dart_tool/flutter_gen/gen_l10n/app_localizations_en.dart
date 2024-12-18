import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get thereHasBeenAProblem => 'There has been a problem. Please restart the app.';

  @override
  String get noDevicesFound => 'No Qilowatt devices found.';

  @override
  String get tryAgain => 'Try again.';

  @override
  String get failedToConnectTo => 'Failed to connect to ';

  @override
  String get connectionTookTooLong => 'connection took too long';

  @override
  String get platformNotSupported => 'Platform not supported.';

  @override
  String get locationPermissionsRequired => 'Location permissions required.';

  @override
  String get locationPermissionsDenied => 'Location permissions denied.';

  @override
  String get locationAccuracyPermissionsDenied => 'Location upgrade accuracy permissions denied.';

  @override
  String get locationServicesDisabled => 'Location services disabled.';

  @override
  String get wifiScanFailed => 'WiFi scan failed.';

  @override
  String get exception => 'Exception';

  @override
  String get pleaseEnableWifi => 'Please enable WiFi and try again.';

  @override
  String get search => 'Search';

  @override
  String get restart => 'Restart';
}
