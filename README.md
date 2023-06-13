<!-- 
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages). 

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages). 
-->

A minimalistic asynchronous worker.
## Features

This package simplifies the boilerplate and execution of asynchronous tasks

## Usage

```dart
import 'package:flutter/material.dart';

import 'package:services_worker/services_worker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Test',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  double _data = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const SizedBox(
                  height: 15,
                ),
                const Text(
                  'This is the result of your task',
                ),
                const SizedBox(
                  height: 25,
                ),
                Text(
                  _data.toString(),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _execute,
        tooltip: 'execute',
        child: const Icon(Icons.download),
      ),
    );
  }

  Future<void> _execute() async {
    final res = await ServicesWorker.executeInOtherThread(
      () => _hardTask(_data),
    );

    if (res.hasError) {
      final error = res.error!;

      throw ServicesException.fromServicesError(
        error,
      );
    }

    final double value = res.data!;

    setState(() {
      _data = value;
    });

    return;
  }

  static Future<double> _hardTask(double oldValue) async {
    final double value = oldValue + 1;

    final double newValue = ((((value * value) / 2) * (-1 * value)) / 0.777);

    return newValue;
  }
}

```

## Additional information

If you like this package and find it usefull, please give it a like.
