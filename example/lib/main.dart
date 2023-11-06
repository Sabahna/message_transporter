import 'package:flutter/material.dart';
import 'package:message_transporter/message_transporter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final messageTransporter = MessageTransporter().service;

  void _subscribe() {
    messageTransporter.subscribe(
      "topic_test_1",
      handler: (QueueMessage message) {
        debugPrint(
            "------subscribe----------------${message.topic}-----${message.message}-----------------");
      },
    );
  }

  @override
  void initState() {
    initiative();
    super.initState();
  }

  Future<void> initiative() async {
    // mqtts://coturn.telemed.sabahna.com:8883
    // Username - telemedicine
    // Password - Welcome9TT
    await messageTransporter.connect(
      server: "mqtt.telemed.sabahna.com",
      userIdentifier: "mqttx_aer234",
      userName: "telemedicine",
      password: "Welcome9TT",
    );

    messageTransporter.subscribe(
      "topic_test",
      handler: (QueueMessage message) {
        debugPrint(
            "------init state----------------${message.topic}-----${message.message}-----------------");
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Message Transporter',
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _subscribe,
        tooltip: 'Subscribe',
        child: const Icon(Icons.add),
      ),
    );
  }
}
