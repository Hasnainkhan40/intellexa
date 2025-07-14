import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:intellexa/message.dart';
import 'package:intellexa/themeNotifier.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Message> _message = [];
  bool isloading = false;

  Future<void> sendMessage() async {
    final prompt = _controller.text.trim();
    if (prompt.isEmpty) return;

    setState(() {
      _message.add(Message(text: _controller.text, isUser: true));
      _controller.clear();
      isloading = true;
    });

    final response = await chatWithOpenRouter(prompt);
    setState(() {
      _message.add(Message(text: response, isUser: false));
      isloading = false;
    });
  }

  Future<String> chatWithOpenRouter(String prompt) async {
    final apiKey = dotenv.env['OPENROUTER_API_KEY'];
    final uri = Uri.parse("https://openrouter.ai/api/v1/chat/completions");

    final headers = {
      'Authorization': 'Bearer $apiKey',
      'Content-Type': 'application/json',
      'HTTP-Referer': 'https://your-app.com', // Optional
      'X-Title': 'My Flutter Chatbot', // Optional
    };

    final body = jsonEncode({
      "model": "mistralai/mistral-7b-instruct",
      "messages": [
        {"role": "user", "content": prompt},
      ],
    });

    final res = await http.post(uri, headers: headers, body: body);

    if (res.statusCode == 200) {
      final json = jsonDecode(res.body);

      if (json['choices'] != null &&
          json['choices'].isNotEmpty &&
          json['choices'][0]['message'] != null) {
        return json['choices'][0]['message']['content'];
      } else {
        return '⚠️ No valid response from AI.';
      }
    } else {
      print('❌ API Error ${res.statusCode}: ${res.body}');
      return '⚠️ Failed to get response from AI.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentTheme = ref.watch(themeProvider);
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        backgroundColor: Theme.of(context).colorScheme.background,
        elevation: 1,

        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Image.asset('assets/gpt-robot.png'),
                SizedBox(width: 10),
                Text('intellxa', style: Theme.of(context).textTheme.titleLarge),
              ],
            ),
            GestureDetector(
              child:
                  (currentTheme == ThemeMode.dark)
                      ? Icon(
                        Icons.light_mode,
                        color: Theme.of(context).colorScheme.secondary,
                      )
                      : Icon(
                        Icons.dark_mode,
                        color: Theme.of(context).colorScheme.primary,
                      ),
              onTap: () {
                ref.read(themeProvider.notifier).toggleTheme();
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _message.length,
              itemBuilder: (context, index) {
                final message = _message[index];
                return ListTile(
                  title: Align(
                    alignment:
                        message.isUser
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                    child: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color:
                            message.isUser
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.secondary,
                        borderRadius:
                            message.isUser
                                ? BorderRadius.only(
                                  topLeft: Radius.circular(20),
                                  bottomRight: Radius.circular(20),
                                  bottomLeft: Radius.circular(20),
                                )
                                : BorderRadius.only(
                                  topRight: Radius.circular(20),
                                  bottomRight: Radius.circular(20),
                                  bottomLeft: Radius.circular(20),
                                ),
                      ),
                      child: Text(
                        message.text,
                        style:
                            message.isUser
                                ? Theme.of(context).textTheme.bodyMedium
                                : Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          //user input
          Padding(
            padding: EdgeInsets.only(
              bottom: 32,
              top: 16.0,
              left: 16.0,
              right: 16,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      style: Theme.of(context).textTheme.titleSmall,
                      decoration: InputDecoration(
                        hintText: 'Write your message',
                        hintStyle: Theme.of(
                          context,
                        ).textTheme.titleLarge!.copyWith(color: Colors.grey),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 20),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  isloading
                      ? Padding(
                        padding: EdgeInsets.all(8),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(),
                        ),
                      )
                      : Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: GestureDetector(
                          child: Image.asset('assets/send.png'),
                          onTap: sendMessage,
                        ),
                      ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
