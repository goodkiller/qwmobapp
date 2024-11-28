import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:qilowatt/screens/add_device/local_device_web_view.dart';
import 'package:wifi_iot/wifi_iot.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:wifi_scan/wifi_scan.dart';

class AddDeviceScreen extends StatefulWidget {
  const AddDeviceScreen({super.key});

  @override
  AddDeviceScreenState createState() => AddDeviceScreenState();
}

class AddDeviceScreenState extends State<AddDeviceScreen> {
  bool isConnectingToWifi = false;
  Future<WifiScanResult>? wifiScanFuture;

  @override
  void initState() {
    wifiScanFuture = buildWifiScanFuture();
    super.initState();
  }

  @override
  Widget build(BuildContext poContext) {
    return SafeArea(
      child: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: SizedBox(
                height: 36,
                width: 36,
                child: SvgPicture.asset('assets/icons/logo-sm-dark.svg')),
          ),
          body: FutureBuilder(
              future: wifiScanFuture,
              builder: (context, content) {
                if (content.connectionState != ConnectionState.done) {
                  return buildLoader();
                }
                if (content.hasData) {
                  WifiScanResult wifiScanResult = content.data!;
                  List<WiFiAccessPoint> wifiEndpoints =
                      wifiScanResult.accessPoints;
                  if (!wifiScanResult.wifiEnabled) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(AppLocalizations.of(context)!.pleaseEnableWifi),
                          const SizedBox(
                            height: 8,
                          ),
                          scanButton(context)
                        ],
                      ),
                    );
                  } else if (wifiEndpoints.isEmpty) {
                    return Center(
                        child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(AppLocalizations.of(context)!.noDevicesFound),
                        const SizedBox(
                          height: 8,
                        ),
                        scanButton(context)
                      ],
                    ));
                  }
                  return Stack(
                    children: [
                      ListView.builder(
                          itemCount: wifiEndpoints.length,
                          itemBuilder: (context, index) =>
                              buildAPTile(wifiEndpoints[index])),
                      Positioned(
                        bottom: 25,
                        right: 25,
                        child: scanButton(context),
                      )
                    ],
                  );
                } else if (content.hasError) {
                  Exception error = content.error as Exception;
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(error.toString().replaceAll(
                            "${AppLocalizations.of(context)!.exception}: ",
                            "")),
                        const SizedBox(
                          height: 8,
                        ),
                        scanButton(context)
                      ],
                    ),
                  );
                }
                return buildLoader();
              })),
    );
  }

  ElevatedButton scanButton(BuildContext context) {
    return ElevatedButton(
        style: ButtonStyle(
            backgroundColor:
                MaterialStateProperty.all<Color>(const Color(0xff8e91d5)),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0),
                    side: const BorderSide(color: Color(0xff8e91d5))))),
        onPressed: () => setState(() {
              wifiScanFuture = buildWifiScanFuture();
            }),
        child: Text(
          AppLocalizations.of(context)!.search,
          style: const TextStyle(color: Colors.white),
        ));
  }

  Center buildLoader() {
    return const Center(
        child: CircularProgressIndicator(
      color: Colors.grey,
    ));
  }

  Future<WifiScanResult> buildWifiScanFuture() {
    return WiFiForIoTPlugin.isEnabled().then((value) async {
      if (!value) {
        return WifiScanResult(false, []);
      } else {
        await Future.delayed(const Duration(milliseconds: 2000));
        return startScan()
            .then((value) => getScannedResults(value))
            .then((list) {
          List<WiFiAccessPoint> filteredAccessPoints = list
              .where((element) => element.ssid.contains("Qilowatt"))
              .toList();

          return WifiScanResult(true, filteredAccessPoints);
        });
      }
    });
  }

  Future<bool> startScan() async {
    final can = await WiFiScan.instance.canStartScan(askPermissions: true);
    switch (can) {
      case CanStartScan.yes:
        return await WiFiScan.instance.startScan();
      case CanStartScan.notSupported:
        throw Exception(AppLocalizations.of(context)!.platformNotSupported);
      case CanStartScan.noLocationPermissionRequired:
        throw Exception(
            AppLocalizations.of(context)!.locationPermissionsRequired);
      case CanStartScan.noLocationPermissionDenied:
        throw Exception(
            AppLocalizations.of(context)!.locationPermissionsDenied);
      case CanStartScan.noLocationPermissionUpgradeAccuracy:
        throw Exception(
            AppLocalizations.of(context)!.locationAccuracyPermissionsDenied);
      case CanStartScan.noLocationServiceDisabled:
        throw Exception(AppLocalizations.of(context)!.locationServicesDisabled);
      case CanStartScan.failed:
        throw Exception(AppLocalizations.of(context)!.wifiScanFailed);
    }
  }

  Future<List<WiFiAccessPoint>> getScannedResults(bool value) async {
    final can =
        await WiFiScan.instance.canGetScannedResults(askPermissions: true);
    switch (can) {
      case CanGetScannedResults.yes:
        return await WiFiScan.instance.getScannedResults();
      case CanGetScannedResults.notSupported:
        throw Exception(AppLocalizations.of(context)!.platformNotSupported);
      case CanGetScannedResults.noLocationPermissionRequired:
        throw Exception(
            AppLocalizations.of(context)!.locationPermissionsDenied);
      case CanGetScannedResults.noLocationPermissionDenied:
        throw Exception(
            AppLocalizations.of(context)!.locationPermissionsDenied);
      case CanGetScannedResults.noLocationPermissionUpgradeAccuracy:
        throw Exception(
            AppLocalizations.of(context)!.locationAccuracyPermissionsDenied);
      case CanGetScannedResults.noLocationServiceDisabled:
        throw Exception(AppLocalizations.of(context)!.locationServicesDisabled);
    }
  }

  Future<bool> goToDeviceAdd(BuildContext context) {
    return Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => LocalDeviceWebView()))
        .then((value) => WiFiForIoTPlugin.forceWifiUsage(false))
        .then((value) => WiFiForIoTPlugin.disconnect());
  }

  Widget buildAPTile(WiFiAccessPoint wiFiAccessPoint) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListTile(
        enabled: !isConnectingToWifi,
        title: Text(
          wiFiAccessPoint.ssid,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        leading: const Icon(Icons.wifi),
        tileColor: Colors.grey[200],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        onTap: () async {
          bool isWifiEnabled = false;
          setState(() {
            isConnectingToWifi = true;
          });
          try {
            isWifiEnabled = await WiFiForIoTPlugin.isEnabled();
            if (isWifiEnabled) {
              return await WiFiForIoTPlugin.getSSID().then((currentSSID) async {
                if (wiFiAccessPoint.ssid != currentSSID) {
                  return await WiFiForIoTPlugin.connect(wiFiAccessPoint.ssid);
                } else {
                  return true;
                }
              }).then((success) {
                if (!success) {
                  throw Exception(AppLocalizations.of(context)!.tryAgain);
                }
                return success;
              }).then((result) async {
                return await WiFiForIoTPlugin.forceWifiUsage(true);
              }).then((result) {
                if (result) {
                  goToDeviceAdd(context);
                } else {
                  throw Exception(AppLocalizations.of(context)!.tryAgain);
                }
              });
            }
          } on TimeoutException {
            showScaffoldMessage(
                '${AppLocalizations.of(context)!.failedToConnectTo} ${wiFiAccessPoint.ssid}, ${AppLocalizations.of(context)!.connectionTookTooLong}.');
          } catch (e) {
            showScaffoldMessage(
                '${AppLocalizations.of(context)!.failedToConnectTo}. ${e.toString().replaceAll("${AppLocalizations.of(context)!.exception}: ", "")}');
          } finally {
            setState(() {
              isConnectingToWifi = false;
              if (!isWifiEnabled) {
                wifiScanFuture = buildWifiScanFuture();
              }
            });
          }
        },
        trailing: isConnectingToWifi
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.black12),
                ),
              )
            : null,
      ),
    );
  }

  void showScaffoldMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
        ),
      ),
    );
  }
}

class WifiScanResult {
  bool wifiEnabled;
  List<WiFiAccessPoint> accessPoints;

  WifiScanResult(this.wifiEnabled, this.accessPoints);
}
