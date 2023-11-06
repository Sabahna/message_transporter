import "package:message_transporter/models/client_abstract.dart";
import "package:message_transporter/src/client.dart";

class MessageTransporter {
  final MessageBrokerServiceAbstract service = MessageBrokerService();
}
