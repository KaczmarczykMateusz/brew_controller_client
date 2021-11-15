import 'package:brew_controller_client/parameter_row_field.dart';
import 'package:brew_controller_client/parameter_row_toggle.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

enum TemperatureSeleection {
  none,
  kettle,
  mash
}

class _MyHomePageState extends State<MyHomePage> {
  int _mashTemp = 25;
  String _setPointTempStr = "76";
  String _kettleTempStr = "25";
  String _mashTempStr = "25";

  TemperatureSeleection selection = TemperatureSeleection.kettle;

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

    TextField setPointField = TextField(
      decoration: InputDecoration(hintText: _setPointTempStr),
      keyboardType: TextInputType.number,
      onSubmitted: _onSetPointModified,
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.digitsOnly
      ], // Only numbers can be entered
    );
    bool pumpOn = false;
    final ValueSetter<bool> onSwitched = (newState) {
      newState = newState;
      pumpOn = newState;
      //TODO: send to backend
    };

    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Column (
          children: [
            ParameterRowField("Set Point", 'System-wide temperature', tempIcon, _kettleTempStr, setPointField).build(context),
            ParameterRowValue('Kettle', 'Kettle temperature', tempIcon, _kettleTempStr).build(context),
            ParameterRowValue('Mash', 'Bucket temperature', tempIcon, _mashTempStr).build(context),
            ParameterRowToggle('Pump', 'Turn on/ off wort pump', tempIcon, onSwitched).build(context),
          ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createProfile,
        tooltip: 'Create profile',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
