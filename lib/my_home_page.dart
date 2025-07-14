import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:intellexa/message.dart';
import 'package:intellexa/themeNotifier.dart';

class MyHomePage extends ConsumerStatefulWidget {
  const MyHomePage({super.key});

  @override
  ConsumerState<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends ConsumerState<MyHomePage> {
  final TextEditingController _controller = TextEditingController();
  final List<Message> _message = [
    Message(text: "Hi", isUser: true),
    Message(text: "Hello what's up", isUser: false),
    Message(text: "Great and you ?", isUser: true),
    Message(text: "I,m exellent", isUser: false),
  ];

  callGeminiModel() async {
    try {
      if (_controller.text.isNotEmpty) {
        _message.add(Message(text: _controller.text, isUser: true));
      }
      final model = GenerativeModel(
        model: 'models/gemini-pro', // ✅ Correct
        apiKey: dotenv.env['GOOGLE_API_KEY']!,
      );
      final prompt = _controller.text.trim();
      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);

      setState(() {
        _message.add(Message(text: response.text!, isUser: false));
      });
      print("Loaded API KEY: ${dotenv.env['GOOGLE_API_KEY']}");

      _controller.clear();
    } catch (e) {
      if (e.toString().contains("quota")) {
        setState(() {
          _message.add(
            Message(
              text:
                  "⚠️ You've reached your quota. Please try again later or check your billing settings.",
              isUser: false,
            ),
          );
        });
      } else {
        print('Error: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentTheme = ref.watch(themeProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
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
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: GestureDetector(
                      child: Image.asset('assets/send.png'),
                      onTap: callGeminiModel,
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
