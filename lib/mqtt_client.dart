import 'dart:async';

import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';


class MqttController {
  final StreamController<String> _statuses = StreamController<String>();
  final mqttClient = MqttServerClient('public.mqtthq.com', '');
  static const clientUpdateTopic = 'brew_controller/client_update';
  static const hostUpdateTopic = 'brew_controller/host_update';
  final String clientId;
  MqttController(this.clientId);

  Future<void> connectMqtt() async {
    final client = mqttClient;
    final connMess = MqttConnectMessage()
        .withClientIdentifier(clientId)
        .withWillTopic(
        'brew_controller/failure_update') // If you set this you must set a will message
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
    const topic = hostUpdateTopic;
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

  void sendData(int setPoint, bool pumpOn) {
    final builder = MqttClientPayloadBuilder();
    builder.addString('{"setPointTemp":$setPoint, "pumpOn":$pumpOn}');
    if(MqttConnectionState.connected == mqttClient.connectionStatus!.state) {
      mqttClient.publishMessage(
          clientUpdateTopic, MqttQos.exactlyOnce, builder.payload!);
    } else {
      //TODO: handle this case better (when connection fails it's hardly established again) - need further investigation
      print('ERROR Client connection failed - disconnecting, status is ${mqttClient.connectionStatus}');
      mqttClient.disconnect();
      connectMqtt();
    }
  }

  StreamController<String> getStream() {
    return _statuses;
  }
}