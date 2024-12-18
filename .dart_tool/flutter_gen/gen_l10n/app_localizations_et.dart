import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Estonian (`et`).
class AppLocalizationsEt extends AppLocalizations {
  AppLocalizationsEt([String locale = 'et']) : super(locale);

  @override
  String get thereHasBeenAProblem => 'Tekkis probleem. Palun taaskäivitage rakendus.';

  @override
  String get noDevicesFound => 'Qilowatt seadmeid ei leitud.';

  @override
  String get tryAgain => 'Proovige uuesti.';

  @override
  String get failedToConnectTo => 'Ühenduse loomine ebaõnnestus: ';

  @override
  String get connectionTookTooLong => 'ühenduse loomine võttis liiga kaua aega';

  @override
  String get platformNotSupported => 'Platvormi ei toetata.';

  @override
  String get locationPermissionsRequired => 'Asukoha kasutus pole lubatud.';

  @override
  String get locationPermissionsDenied => 'Asukoha kasutus pole keelatud.';

  @override
  String get locationAccuracyPermissionsDenied => 'Täpne asukoha kasutus on keelatud.';

  @override
  String get locationServicesDisabled => 'Asukohateave välja lülitatud.';

  @override
  String get wifiScanFailed => 'Seadmete otsimine ebaõnnestus.';

  @override
  String get exception => 'Viga';

  @override
  String get pleaseEnableWifi => 'Palun lülitage WiFi sisse ja proovige uuesti.';

  @override
  String get search => 'Otsi';

  @override
  String get restart => 'Taaskäivita';
}
