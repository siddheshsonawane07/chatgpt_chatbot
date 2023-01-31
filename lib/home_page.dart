// ignore_for_file: avoid_print

import 'dart:async';

import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:chatgpt/chat_message.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:velocity_x/velocity_x.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _controller = TextEditingController();

  final List<Chat_Message> _messages = [];

  ChatGPT? chatGPT;
  int index = 0;

  StreamSubscription? _subscription;

  @override
  void initState() {
    super.initState();
    chatGPT = ChatGPT.instance
        .builder("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");
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void _sendMessage() {
    if (_controller.text.isEmpty) {
      Fluttertoast.showToast(msg: "Write something");
      return;
    }

    Chat_Message message = Chat_Message(
      text: _controller.text,
      sender: "user",
    );

    if (_messages.isNotEmpty) {
      if (message.text == _messages[0].text) {
        Fluttertoast.showToast(msg: "Same Query");
        return;
      }
    }

    setState(() {
      _messages.insert(0, message);
      index++;
    });

    _controller.clear();

    final request = CompleteReq(
        prompt: message.text, model: kTranslateModelV3, max_tokens: 200);

    _subscription = chatGPT!
        .onCompleteStream(request: request)
        .asBroadcastStream()
        .listen((response) {
      if (response == null) {
        Fluttertoast.showToast(msg: "API dead ! ");
        return;
      }

      if (response.choices[0].text == _messages[index].text) {
        Fluttertoast.showToast(msg: "Same Query");
        return;
      }

      Vx.log(response!.choices[0].text);

      insertNewData(response!.choices[0].text);
    });

    if (request == null) {
      Fluttertoast.showToast(msg: "NULL ");
    }
  }

  void insertNewData(String response) {
    Chat_Message botMessage = Chat_Message(
      text: response,
      sender: "bot",
    );

    // ignore: unnecessary_null_comparison
    if (botMessage.text == null || response == _messages[0].text) {
      print("empty response || same response");
      return;
    }

    setState(() {
      _messages.insert(0, botMessage);
    });
  }

  Widget _buildTextComposer() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              onSubmitted: (value) => _sendMessage(),
              decoration:
                  const InputDecoration.collapsed(hintText: "Write your query"),
            ),
          ),
          ButtonBar(
            children: [
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: () {
                  _sendMessage();
                },
              ),
            ],
          ),
        ],
      ).px16(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0.0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.white,
        title: Text(
          "ChatGPT Chatbot",
          style: GoogleFonts.lato(color: Colors.black),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Flexible(
              child: ListView.builder(
                reverse: true,
                padding: Vx.m8,
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  return _messages[index];
                },
              ),
            ),
            const Divider(
              height: 1.0,
            ),
            Container(
              decoration: BoxDecoration(color: context.cardColor),
              child: _buildTextComposer(),
            ),
          ],
        ),
      ),
    );
  }
}
