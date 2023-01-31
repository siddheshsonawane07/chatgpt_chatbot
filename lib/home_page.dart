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

  StreamSubscription? _subscription;

  bool _isImageSearch = false;

  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    chatGPT = ChatGPT.instance
        .builder("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");
  }

  @override
  void dispose() {
    chatGPT!.genImgClose();
    _subscription?.cancel();
    super.dispose();
  }

  void _sendMessage() {
    if (_controller.text.isEmpty) {
      Fluttertoast.showToast(msg: "Write something");
    }

    Chat_Message message = Chat_Message(
      text: _controller.text,
      sender: "user",
      isImage: false,
    );

    setState(() {
      _messages.insert(0, message);
      _isTyping = true;
    });

    _controller.clear();

    final request = CompleteReq(
        prompt: message.text, model: kTranslateModelV3, max_tokens: 200);

    // ignore: non_constant_identifier_names
    _subscription = chatGPT!
        .builder("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",
            orgId: "")
        .onCompleteStream(request: request)
        .listen((response) {
      Vx.log(response!.choices[0].text);
      // ignore: non_constant_identifier_names
      Chat_Message bot_message =
          Chat_Message(text: response.choices[0].text, sender: "bot");

      setState(() {
        _messages.insert(0, bot_message);
      });
    });
  }

  Widget _buildTextComposer() {
    return Padding(
      padding: const EdgeInsets.all(14),
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
          IconButton(
            onPressed: () => {_sendMessage()},
            icon: const Icon(Icons.send),
          )
        ],
      ),
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
