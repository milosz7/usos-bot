import 'package:flutter/material.dart';
import 'package:frontend_flutter/styles.dart';
import 'chat_state_dto.dart';
import 'chat_window.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  var _currentIndex = 0;
  var historyCaptions = <HistoryCaption>[
    HistoryCaption("Chat 1", "1"),
    HistoryCaption("Chat 2", "2"),
    HistoryCaption("Chat 3", "3"),
  ];

  var currentChatHistory = <ChatMessage>[
    ChatMessage("human", "Hello"),
    ChatMessage("ai", "Hi"),
  ];

  void _fetchCurrentChatHistory(String id) {
    currentChatHistory[0].content = id;
  }

  void _changeIndex(int selectedIndex) {
    _fetchCurrentChatHistory(historyCaptions[selectedIndex].uuid);
    setState(() {
      _currentIndex = selectedIndex;
    });
  }

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _textController = TextEditingController();
  final double maxWidthMobileDevices = 600.0;

  void _processSubmit() {
    setState(() {
      if (!_formKey.currentState!.validate()) {
        return;
      }

      var input = _textController.text;
      currentChatHistory.add(ChatMessage("human", input));

      print("User input: $input");
    });
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var screenWidth = MediaQuery.of(context).size.width;
    const drawerHeaderHeight = 75.0;

    return Scaffold(
        appBar: AppBar(
          title: const Text("Usos Bot"),
          leading: Builder(builder: (context) {
            return IconButton(
                onPressed: () => Scaffold.of(context).openDrawer(),
                icon: const Icon(Icons.menu));
          }),
        ),
        body: Column(
          children: [
            ChatWindow(
                currentChatHistory: currentChatHistory,
                theme: theme,
                screenWidth: screenWidth),
            Material(
              color: theme.colorScheme.primary.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(PaddingSize.large),
                child: Form(
                    key: _formKey,
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Column(children: [
                            TextFormField(
                              decoration: InputDecoration(
                                hintText: "Zadaj pytanie:",
                                errorStyle: const TextStyle(fontSize: 0),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30.0),
                                  borderSide: BorderSide(
                                    color: theme.colorScheme.primary,
                                    width: 2.0,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30.0),
                                  borderSide: BorderSide(
                                    color: theme.colorScheme.secondary,
                                    width: 2.0,
                                  ),
                                ),
                              ),
                              controller: _textController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "";
                                }
                                return null;
                              },
                              style:
                                  TextStyle(color: theme.colorScheme.onPrimary),
                            ),
                          ]),
                        ),
                        Padding(
                          padding:
                              const EdgeInsets.only(left: PaddingSize.large),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.colorScheme.primary,
                              shadowColor: theme.colorScheme.secondary,
                              elevation: 5,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 30, vertical: 15),
                            ),
                            onPressed: _processSubmit,
                            child: Text(
                              "Wyślij",
                              style: TextStyle(
                                  color: theme.colorScheme.onPrimary,
                                  fontSize: screenWidth >= maxWidthMobileDevices
                                      ? FontSize.large
                                      : FontSize.small),
                            ),
                          ),
                        )
                      ],
                    )),
              ),
            ),
          ],
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              SizedBox(
                height: drawerHeaderHeight,
                child: DrawerHeader(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                  ),
                  child: Text(
                    "Historia czatów",
                    style: TextStyle(
                        color: theme.colorScheme.onPrimary,
                        fontSize: FontSize.large),
                  ),
                ),
              ),
              for (var i = 0; i < historyCaptions.length; i++)
                ListTile(
                  title: Text(historyCaptions[i].caption),
                  selected: _currentIndex == i,
                  onTap: () {
                    _changeIndex(i);
                    Navigator.pop(context);
                  },
                )
            ],
          ),
        ));
  }
}
