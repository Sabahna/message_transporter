import "dart:async";
import "dart:convert";

import "package:flutter/cupertino.dart";
import "package:message_transporter/models/client_abstract.dart";
import "package:mqtt_client/mqtt_client.dart";
import "package:mqtt_client/mqtt_server_client.dart";

class MessageBrokerService extends MessageBrokerServiceAbstract {
  factory MessageBrokerService() {
    return I;
  }

  MessageBrokerService._();

  static final MessageBrokerService I = MessageBrokerService._();

  /// Client info
  late MqttServerClient _client;
  final Map<String, dynamic> _userIdentifier = {};

  /// handler
  ///
  final Map<String, FutureOr<void> Function(QueueMessage message)> _handlers =
      {};

  List<String> get getSubscribeList {
    return _handlers.keys.toList();
  }

  @override
  Future<MqttServerClient> connect({
    required String server,
    required String userIdentifier,
    bool showLog = false,
    String? userName,
    String? password,
  }) async {
    if (isConnected) {
      throw "Service can connect once!";
    }

    _userIdentifier["id"] = userIdentifier;
    _client = MqttServerClient.withPort(
      server,
      userIdentifier,
      1883,
      maxConnectionAttempts: 10,
    );
    _client
      ..logging(on: showLog)
      ..onConnected = _onConnected
      ..onDisconnected = _onDisconnected
      ..onUnsubscribed = _onUnsubscribed
      ..onSubscribed = _onSubscribed
      ..onSubscribeFail = _onSubscribeFail
      ..pongCallback = _pong
      ..connectTimeoutPeriod = 5000
      ..keepAlivePeriod = 20
      ..autoReconnect = true;

    final connMessage = MqttConnectMessage()
        .authenticateAs(userName, password)
        .startClean()
        .withWillQos(MqttQos.atLeastOnce)
        .withWillTopic("connection")
        .withWillMessage(
          _userStatus(),
        );

    _client.connectionMessage = connMessage;
    try {
      await _client.connect();
      isConnected = true;
    } catch (e) {
      debugPrint("Exception: $e");
      _client.disconnect();
      isConnected = false;
    }

    _client.updates?.listen((c) async {
      for (final i in c) {
        final MqttPublishMessage message = i.payload as MqttPublishMessage;
        final payload =
            MqttPublishPayload.bytesToStringAsString(message.payload.message);

        debugPrint("Received message:$payload from topic: ${i.topic}>");
        final queueMessage = QueueMessage(topic: i.topic, message: payload);

        _handlers[queueMessage.topic]?.call(queueMessage);
      }
    });

    return _client;
  }

  @override
  void subscribe(
    String topic, {
    required FutureOr<void> Function(QueueMessage message) handler,
  }) {
    _client.subscribe(topic, MqttQos.atLeastOnce);
    _handlers.putIfAbsent(topic, () => handler);
  }

  @override
  void unSubscribe(String topic) {
    _client.unsubscribe(topic);
    _handlers.remove(topic);
  }

  @override
  void publish(String pubTopic, {required String data}) {
    if (isConnected) {
      final builder = MqttClientPayloadBuilder()..addString(data);
      _client.publishMessage(pubTopic, MqttQos.atLeastOnce, builder.payload!);
    }
  }

  @override
  void disconnect() {
    _handlers.clear();
    _client.disconnect();
  }

  // connection succeeded
  void _onConnected() {
    debugPrint("Connected");
    isConnected = true;

    publish("connection", data: _userStatus(isConnected: true));
  }

  // unconnected
  void _onDisconnected() {
    debugPrint("Disconnected");
    isConnected = false;
  }

  // subscribe to topic succeeded
  void _onSubscribed(String topic) {
    debugPrint("Subscribed topic: $topic");
  }

  // subscribe to topic failed
  void _onSubscribeFail(String topic) {
    debugPrint("Failed to subscribe $topic");
  }

  // unsubscribe succeeded
  void _onUnsubscribed(String? topic) {
    debugPrint("Unsubscribed topic: $topic");
  }

  // PING response received
  void _pong() {
    // debugPrint("Message Transporter, Ping response client callback invoked");
  }

  String _userStatus({bool isConnected = false}) {
    _userIdentifier["status"] = isConnected;

    return json.encode(_userIdentifier);
  }
}
