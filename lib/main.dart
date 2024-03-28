import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_frame.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'WebSocket',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _controller = TextEditingController();
  final TextEditingController received = TextEditingController();
  late StompClient stompClient;

  @override
  void initState() {
    super.initState();
    stompClient = StompClient(
      config: StompConfig(
        url: 'ws://localhost:8080/sendMessage',
        onConnect: onConnect,
        onWebSocketError: onWebSocketError,
        onStompError: onStompError,
        stompConnectHeaders: {'Authorization': 'Bearer your_access_token'},
        webSocketConnectHeaders: {'Authorization': 'Bearer your_access_token'},
      ),
    );
    stompClient.activate();
  }

  void onConnect(StompFrame frame) {
    print('Connected: ${frame.body}');
    stompClient.subscribe(
      destination: '/topic/sendMessage',
      callback: (StompFrame frame) {
        showGreeting(frame.body);
        received.text="";
      setState(() {
        Map<String, dynamic> jsonData = json.decode(frame.body!);
        String content = jsonData['content'];
        received.text=content;
      });
      },
    );
  }

  void onWebSocketError(error) {
    print('Error with WebSocket: $error');
  }

  void onStompError(frame) {
    print('Broker reported error: ${frame.headers['message']}');
    print('Additional details: ${frame.body}');
  }

  void showGreeting(String? message) {
    print('Received message: ${message ?? 'No message received'}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WebSocket '),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _controller,
              decoration: const InputDecoration(labelText: 'Send a message'),
            ),
            const SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                stompClient.send(
                  destination: '/app/hello',
                  body: '{"name": "${_controller.text}"}',
                );
                _controller.clear();
              },
              child: const Text('Send'),
            ),
            TextField(
              readOnly: true,
              controller: received,
              decoration: const InputDecoration(labelText: 'Received  message'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    stompClient.deactivate();
    super.dispose();
  }
}
