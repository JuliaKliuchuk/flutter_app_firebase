import 'dart:developer';
import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_info_plus/device_info_plus.dart';

import 'package:flutter_app_firebase/pages/SplashPage.dart';
import 'package:flutter_app_firebase/pages/WebViewPage.dart';

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
                  child: CircularProgressIndicator(),
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
  // bool _isSimDevice = false;
  bool _isPhysicalDevice = false;
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
      appBar: AppBar(
        title: const Text('WebView'),
      ),
      body:
          _path.isEmpty || _brandDevice.contains('google') || _isPhysicalDevice
              ? const SplashPage()
              : WebViewPage(url: _path),
      persistentFooterButtons: [
        IconButton(
            onPressed: (() => {
                  _resetDataPref(),
                  log('url delete--- $_path'),
                }),
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Сбросить url'),
        const SizedBox(width: 5),
        IconButton(
            onPressed: (() => {
                  _path = widget.remoteConfig.getString('url'),
                  setState(() {
                    _sharedPrefs.setString(_pathSharedPrefsKey, _path);
                  }),
                  log('url refresh --- $_path'),
                }),
            icon: const Icon(Icons.refresh),
            tooltip: 'Обновить url'),
        const SizedBox(
          width: 10,
        ),
      ],
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
    _isPhysicalDevice = androidInfo.isPhysicalDevice;
  }

// проверка на наличие симкарты
  // void _checkSimDevice() async {}

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
