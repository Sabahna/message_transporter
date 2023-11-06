import "dart:async";

import "package:mqtt_client/mqtt_server_client.dart";

abstract class MessageBrokerServiceAbstract {
  bool isConnected = false;

  /// Get all of the topic you subscribed
  List<String> get getSubscribeList;

  /// [server] is the host name. Eg- transporter.jackwill.com
  ///
  /// [userIdentifier] must be unique
  ///
  /// [userName] is for authenticating server
  ///
  /// [password] is for authenticating server
  Future<MqttServerClient> connect({
    required String server,
    required String userIdentifier,
    bool showLog = false,
    String? userName,
    String? password,
  });

  void disconnect();

  /// Listen all of the topics changes or updates
  // void listen(FutureOr<void> Function(QueueMessage message)? handler);

  /// Subscribe(listen) the topic with handler
  void subscribe(
    String topic, {
    required FutureOr<void> Function(QueueMessage message) handler,
  });

  /// Un-Subscribe(remove listen) from the topic
  void unSubscribe(String topic);

  /// Publish(send) the topic to the subscribers
  void publish(String pubTopic, {required String data});
}

class QueueMessage {
  QueueMessage({
    required this.topic,
    required this.message,
  });

  final String topic;
  final dynamic message;
}
