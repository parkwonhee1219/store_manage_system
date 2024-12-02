import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:store_management_system/Gpio/device_controller.dart';

class Mqtt {
  final client = MqttServerClient('broker.hivemq.com', '');

  Future<void> connect(String topic,String token) async {
    client.port = 1883;
    client.logging(on: true);
    client.keepAlivePeriod = 20;

    //콜백함수
    client.onConnected = _onConnected;
    client.onDisconnected = _onDisconnected;
    client.onSubscribed = _onSubscribed;
    client.onSubscribeFail = _onSubscribeFail;
    client.pongCallback = _pong;

    final connMessage = MqttConnectMessage()
        .withClientIdentifier('ESTeam3/control') // 클라이언트 식별자
        .withWillTopic('willtopic') // 유언 주제
        .withWillMessage('My Will message') // 유언 메세지
        .startClean()
        .withWillQos(MqttQos.atLeastOnce); // 유언 메시지의 QoS 수준

    client.connectionMessage = connMessage;

    try {
      await client.connect(); // 브로커와 연결 시도
    } catch (e) {
      print('Exception: $e');
      client.disconnect();
    }
    subscribeToTopic(topic,'');
    publishMessage(topic, 'connect success!!!!!!');
    print('connect finish!!!!!!!!!');
  }

  void _onConnected() {
    print('Connected');
  }

  void _onDisconnected() {
    print('Disconnected');
  }

  void _onSubscribed(String topic) {
    print('Subscribed to $topic');
  }

  void _onSubscribeFail(String topic) {
    print('Failed to subscribe $topic');
  }

  void _pong() {
    print('Ping response client callback invoked');
  }

  void subscribeToTopic(String topic, String token) {
    if (client.connectionStatus!.state != MqttConnectionState.connected) {
      print('Client is not connected. Trying to reconnect...');
      connect(topic,''); // 연결이 안 되어 있으면 재연결 시도
    }

    //'topic'을 구독하고 구독한 주제로부터 받은 메세지를 출력하는 메서드.
    client.subscribe(
        topic, MqttQos.atLeastOnce); // topic을 구독한다. QoS : atLeastOnce
    client.updates!.listen((List<MqttReceivedMessage<MqttMessage?>> c) async {
      // 콜백 함수
      final MqttPublishMessage message = c[0].payload
          as MqttPublishMessage; // 구독한 주제로 부터 받은 메세지 리스트의 첫번째 요소 내용을 message 변수에 저장.
      final payload = MqttPublishPayload.bytesToStringAsString(
          message.payload.message); // 데이터를 문자열로 변환하여 변수 payload에 저장.

      print(
          'Received message:$payload from topic: ${c[0].topic}>'); // 수신된 데이터의 첫 번째 메시지 내용과 주제를 출력한다.
      // Firestore에서 해당 name을 가진 문서 검색
      CollectionReference gpio_collection =
          FirebaseFirestore.instance.collection('gpio');
      final QuerySnapshot querySnapshot =
          await gpio_collection.where('name', isEqualTo: payload).get();
      if (querySnapshot.docs.isNotEmpty) {
        final DocumentSnapshot documentSnapshot = querySnapshot.docs[0];
        final String status = documentSnapshot['status']; // status 필드 값 가져오기
        final newState = status == 'on' ? 'off' : 'on';
        // Firestore 문서 업데이트
        await controlDevice(documentSnapshot['id'], newState, token);
        print("Updated status of device '$payload' to: $newState");
      } else {
        print("Device with name '$payload' not found in Firestore.");
      }
    });
  }

  void publishMessage(String topic, String message) {
    if (client.connectionStatus!.state != MqttConnectionState.connected) {
      print('Client is not connected. Trying to reconnect...');
      connect(topic,''); // 연결이 안 되어 있으면 재연결 시도
    }

    //특정 주제로 메세지를 발행하는 메서드
    final builder =
        MqttClientPayloadBuilder(); // MqttClientPayloadBuilder 객체를 생성. 메세지 페이로드를 구성하는데 사용된다.
    builder.addString(message); // builder 객체에 발행할 문자열 메세지를 추가한다.

    client.publishMessage(
        topic, MqttQos.atLeastOnce, builder.payload!); //메세지를 발행한다.
  }
}
