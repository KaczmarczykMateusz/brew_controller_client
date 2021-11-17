import 'dart:async';
import 'dart:convert';

import 'package:brew_controller_client/parameter_row_field.dart';
import 'package:brew_controller_client/parameter_row_toggle.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'parameter_row_value.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Brew Controller',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Brew Controller'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

enum TemperatureSelection {
  none,
  kettle,
  mash
}

class _MyHomePageState extends State<MyHomePage> {
  final mqttClient = MqttServerClient('public.mqtthq.com', '');
  static const mqttTopic = "brew_controller";
  final StreamController<String> _statuses = StreamController<String>();

  TemperatureSelection selection = TemperatureSelection.kettle;

  @override
  void initState() {
    super.initState();
    connectMqtt();
  }

  Future<void> connectMqtt() async {
    const String clientId = 'Mqtt_brew_client_1';
    final client = mqttClient;
    final connMess = MqttConnectMessage()
        .withClientIdentifier(clientId)
        .withWillTopic(
        'brew_controller') // If you set this you must set a will message
        .withWillMessage(clientId + ' unexpected exit')
        .startClean() // Non persistent session for testing
        .withWillQos(MqttQos.atLeastOnce);

    client.connectionMessage = connMess;

    await client.connect();

    // 1. go to https://mqtthq.com/client
    // 2. enter brew_controller
    // 3. publish the following json
    /*
    {
      "kettleTemp":13.0,
      "mashTemp":16.0
     }
    */
    const topic = mqttTopic;
    client.subscribe(topic, MqttQos.atMostOnce);

    client.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
      final recMess = c![0].payload as MqttPublishMessage;
      final pt =
      MqttPublishPayload.bytesToStringAsString(recMess.payload.message);

      /// The above may seem a little convoluted for users only interested in the
      /// payload, some users however may be interested in the received publish message,
      /// lets not constrain ourselves yet until the package has been in the wild
      /// for a while.
      /// The payload is a byte buffer, this will be specific to the topic
      // print('EXAMPLE: payload is <-- $pt -->');
      // print('');
      _statuses.add(pt);
    });
  }

  void _createProfile() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      showDialog<void>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Create profile'),
              content: const Text("In future this button will take you to profile creator."),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _createProfile method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    Icon tempIcon = Icon(
      Icons.star,
      color: Colors.red[500],
    );

    double setPoint = 25.0;
    void _onSetPointModified(String setPointStr) {
      setPoint = double.parse(setPointStr);
      //TODO: send to backend
    }

    bool pumpOn = false;
    final ValueSetter<bool> onPumpSwitched = (newState) {
      newState = newState;
      pumpOn = newState;
      //TODO: send to backend
    };

    Widget buildMainPage(String setPointTemp, String kettleTempStr, String mashTempStr) {
      TextField setPointField = TextField(
        decoration: InputDecoration(hintText: setPointTemp),
        keyboardType: TextInputType.number,
        onSubmitted: _onSetPointModified,
        inputFormatters: <TextInputFormatter>[
          FilteringTextInputFormatter.digitsOnly
        ], // Only numbers can be entered
      );
      return Scaffold(
        appBar: AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Text(widget.title),
        ),
        body: Column(
          children: [
            ParameterRowField("Set Point", 'System-wide temperature', tempIcon,
                setPointTemp, setPointField).build(context),
            ParameterRowValue(
                'Kettle', 'Kettle temperature', tempIcon, kettleTempStr).build(
                context),
            ParameterRowValue(
                'Mash', 'Bucket temperature', tempIcon, mashTempStr).build(
                context),
            ParameterRowToggle(
                'Pump', 'Turn on/ off wort pump', tempIcon, onPumpSwitched)
                .build(context),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _createProfile,
          tooltip: 'Create profile',
          child: const Icon(Icons.add),
        ), // This trailing comma makes auto-formatting nicer for build methods.
      );
    }
    return StreamBuilder<String>(
        stream: _statuses.stream,
        builder: (context, snapshot) {

          AcData acData = AcData(65.0, 10.0, 11.0, false);

          if (snapshot.hasData) {
            Map<String, dynamic> decoded = jsonDecode(snapshot.data!);
            acData = AcData.fromJson(decoded);
          }
          return buildMainPage(
              acData.setPointTemp.toString(), acData.kettleTemp.toString(), acData.mashTemp.toString());
        });
  }
}

class AcData {
  double setPointTemp = 65.0;
  final double kettleTemp;
  final double mashTemp;
  bool pumpOn = false;

  AcData(this.setPointTemp, this.kettleTemp, this.mashTemp, this.pumpOn);

  AcData.fromJson(Map<String, dynamic> json)
      : kettleTemp = json['kettleTemp'],
        mashTemp = json['mashTemp'];

  Map<String, dynamic> toJson() => {
    'setPointTemp': setPointTemp,
    'kettleTemp': kettleTemp,
    'mashTemp': mashTemp,
    'pumpOn': pumpOn,
  };
}
