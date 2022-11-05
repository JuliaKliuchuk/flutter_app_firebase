import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(
    MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      home: FutureBuilder<FirebaseRemoteConfig>(
        future: setipRemouteConfig(),
        builder: ((BuildContext context,
            AsyncSnapshot<FirebaseRemoteConfig> snapshot) {
          return snapshot.hasData
              ? Home(remoteConfig: snapshot.requireData)
              : Container(child: const Text('NOT DATA'));
        }),
      ),
    ),
  );
}

class Home extends AnimatedWidget {
  final FirebaseRemoteConfig remoteConfig;

  const Home({super.key, required this.remoteConfig})
      : super(listenable: remoteConfig);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Remoute config'),
      ),
      body: Column(
        children: [
          Image.network(remoteConfig.getString('Image')),
          const Text('test'),
        ],
      ),
    );
  }
}

Future<FirebaseRemoteConfig> setipRemouteConfig() async {
  final FirebaseRemoteConfig remoteConfig = FirebaseRemoteConfig.instance;
  await remoteConfig.fetch();
  await remoteConfig.activate();

  print(remoteConfig.getString(''));

  return remoteConfig;
}
