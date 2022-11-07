// ignore: file_names
import 'package:flutter/material.dart';
import 'package:flutter_app_firebase/data/volcano.dart';

class SplashPage extends StatelessWidget {
  SplashPage({super.key});
  final volcanoData = VolcanoData.getData;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: ListView.builder(
              scrollDirection: Axis.vertical,
              itemCount: volcanoData.length,
              itemBuilder: (context, index) {
                return Card(
                  elevation: 5,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      children: <Widget>[
                        SizedBox(
                          height: 150,
                          child: Image.asset(
                            volcanoData[index]['imgUrl']!,
                            fit: BoxFit.fill,
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Column(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                volcanoData[index]['title']!,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            Text(
                              maxLines: 5,
                              textAlign: TextAlign.justify,
                              overflow: TextOverflow.ellipsis,
                              softWrap: true,
                              volcanoData[index]['desc']!,
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),
        ),
      ],
    );
  }
}
