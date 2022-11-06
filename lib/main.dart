import 'dart:developer';
import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter_app_firebase/pages/SplashPage.dart';
import 'package:flutter_app_firebase/pages/WebViewPage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_info_plus/device_info_plus.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(
    MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      home: FutureBuilder<FirebaseRemoteConfig>(
        future: setupRemouteConfig(),
        builder: ((BuildContext context,
            AsyncSnapshot<FirebaseRemoteConfig> snapshot) {
          return snapshot.hasData
              ? HomePage(remoteConfig: snapshot.requireData)
              : const Center(
                  child: Text('NOT DATA'),
                );
        }),
      ),
    ),
  );
}

class HomePage extends StatefulWidget {
  final FirebaseRemoteConfig remoteConfig;

  const HomePage({Key? key, required this.remoteConfig}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late SharedPreferences _sharedPrefs;
  static const String _pathSharedPrefsKey = 'path_pref';

  String _brandDevice = '';
  String _path = '';

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((pref) {
      setState(() => {_sharedPrefs = pref});
      _checkPath();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _path.isEmpty || _brandDevice.contains('google')
          ? const SplashPage()
          : WebViewPage(url: _path),
      floatingActionButton: FloatingActionButton(
        onPressed: (() {
          _resetDataPref();
          // await widget.remoteConfig.setConfigSettings(
          //     RemoteConfigSettings(
          //         fetchTimeout: const Duration(seconds: 10),
          //         minimumFetchInterval: Duration.zero));
          // await widget.remoteConfig.fetchAndActivate();
        }),
        child: const Icon(Icons.refresh),
      ),
    );
  }

// проверка path
  _checkPath() {
    _path = _sharedPrefs.getString(_pathSharedPrefsKey) ?? '';

    if (_path.isEmpty) {
      _loadPath();
    } else {
      return _path;
    }
  }

// загрузка path
  void _loadPath() {
    final String path = widget.remoteConfig.getString('url');

    setState(() {
      _sharedPrefs.setString(_pathSharedPrefsKey, path);
    });

    _checkBrandDevice();
  }

// определение бренда телефона
  void _checkBrandDevice() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    _brandDevice = androidInfo.brand;
    log('brand ${androidInfo.brand}');
  }

// проверка на наличие симкарты
  void _checkSimDevice() async {}

  // сбросить path
  Future<void> _resetDataPref() async {
    await _sharedPrefs.remove(_pathSharedPrefsKey);
    setState(() {
      _path = '';
    });
  }
}

Future<FirebaseRemoteConfig> setupRemouteConfig() async {
  final FirebaseRemoteConfig remoteConfig = FirebaseRemoteConfig.instance;
  await remoteConfig.fetch();
  await remoteConfig.activate();

  return remoteConfig;
}
