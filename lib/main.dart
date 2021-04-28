import 'dart:async';

import 'package:battery_plus/battery_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:soundpool/soundpool.dart';

Soundpool _soundpool;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Battery Alert'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final Battery _battery = Battery();
  int _batteryPercent = 0;

  StreamSubscription<BatteryState> _batteryStateSubscription;

  Future<int> _cheeringId;

  @override
  void initState() {
    super.initState();
    _loadSounds();
  }

  Future<void> startBatterySub() async {
    if (_batteryStateSubscription == null) {
      int batLevel = await _battery.batteryLevel;

      _batteryStateSubscription =
          _battery.onBatteryStateChanged.listen((BatteryState state) {
        setState(() {
          _batteryPercent = batLevel;
        });

        if (state == BatteryState.full || batLevel == 100) {
          _playCheering();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Click the button to start alarm when full',
            ),
            Container(
              width: 100,
              height: 100,
              margin: EdgeInsets.all(10),
              child: CircularProgressIndicator(
                value: _batteryPercent / 100,
                strokeWidth: 10,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: startBatterySub,
        tooltip: 'BatteryMonitor',
        child: Icon(Icons.alarm),
      ),
    );
  }

  Future<void> _playCheering() async {
    var _sound = await _cheeringId;
    await _soundpool.play(
      _sound,
    );
  }

  Future<int> _loadCheering() async {
    var asset = await rootBundle.load("sounds/c-c-1.mp3");
    return await _soundpool.load(asset);
  }

  Future<void> _loadSounds() async {
    _soundpool ??= Soundpool();
    _cheeringId = _loadCheering();
  }

  @override
  void dispose() {
    super.dispose();
    if (_batteryStateSubscription != null) {
      _batteryStateSubscription.cancel();
    }
    if (_soundpool != null) {
      _soundpool.dispose();
    }
  }
}
