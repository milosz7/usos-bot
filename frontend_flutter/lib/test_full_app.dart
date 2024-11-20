import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:sign_in_button/sign_in_button.dart';
import 'package:frontend_flutter/styles.dart';
import 'package:frontend_flutter/src/chat/chat_state_dto.dart';
import 'package:frontend_flutter/src/chat/chat_window.dart';

class FullPage extends StatefulWidget {
  const FullPage({super.key});

  @override
  State<FullPage> createState() => _FullPage();
}

class _FullPage extends State<FullPage> {
  var _currentIndex = 0;
  var historyCaptions = <HistoryCaption>[
    HistoryCaption("Chat 1", "1"),
    HistoryCaption("Chat 2", "2"),
    HistoryCaption("Chat 3", "3"),
  ];

  var currentChatHistory = <ChatMessage>[
    ChatMessage(MessageAuthor.human, "Hello"),
    ChatMessage(MessageAuthor.ai, "Hi"),
    ChatMessage(MessageAuthor.human,
        "Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor. Aenean massa. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Donec quam felis, ultricies nec, pellentesque eu, pretium quis, sem. Nulla consequat massa quis enim. Donec pede justo, fringilla vel, aliquet nec, vulputate eget, arcu. In enim justo, rhoncus ut, imperdiet a, venenatis vitae, justo. Nullam dictum felis eu pede mollis pretium. Integer tincidunt. Cras dapibus. Vivamus elementum semper nisi. Aenean vulputate eleifend tellus. Aenean leo ligula, porttitor eu, consequat vitae, eleifend ac, enim. Aliquam lorem ante, dapibus in, viverra quis, feugiat a, tellus. Phasellus viverra nulla ut metus varius laoreet. Quisque rutrum. Aenean imperdiet. Etiam ultricies nisi vel augue. Curabitur ullamcorper ultricies nisi. Nam eget dui. Etiam rhoncus. Maecenas tempus, tellus eget condimentum rhoncus, sem quam semper libero, sit amet adipiscing sem neque sed ipsum. Nam quam nunc, blandit vel, luctus pulvinar, hendrerit id, lorem. Maecenas nec odio et ante tincidunt tempus. Donec vitae sapien ut libero venenatis faucibus. Nullam quis ante. Etiam sit amet orci eget eros faucibus tincidunt. Duis leo. Sed fringilla mauris sit amet nibh. Donec sodales sagittis magna. Sed consequat, leo eget bibendum sodales, augue velit cursus nunc,"),
    ChatMessage(MessageAuthor.ai, "Hi"),
    ChatMessage(MessageAuthor.human, "Hello"),
    ChatMessage(MessageAuthor.ai, "Hi"),
    ChatMessage(MessageAuthor.human, "Hello"),
    ChatMessage(MessageAuthor.ai, "Hi"),
    ChatMessage(MessageAuthor.human, "Hello"),
    ChatMessage(MessageAuthor.ai, "Hi"),
    ChatMessage(MessageAuthor.human, "Hello"),
    ChatMessage(MessageAuthor.ai, "Hi"),
    ChatMessage(MessageAuthor.human, "Hello"),
    ChatMessage(MessageAuthor.ai, "Hi"),
    ChatMessage(MessageAuthor.human, "Hello"),
    ChatMessage(MessageAuthor.ai, "Hi"),
    ChatMessage(MessageAuthor.human, "Hello"),
    ChatMessage(MessageAuthor.ai, "Hi"),
    ChatMessage(MessageAuthor.human, "Hello"),
    ChatMessage(MessageAuthor.ai, "Hi"),
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
      currentChatHistory.add(ChatMessage(MessageAuthor.human, input));

      print("User input: $input");
    });
  }

  User? _currentUser;

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      setState(() {
        _currentUser = user;
      });
    });
  }

  void _logout() async {
    await FirebaseAuth.instance.signOut();
  }

  Future<void> _handleSignIn() async {
    try {
      FirebaseAuth.instance.signInWithPopup(GoogleAuthProvider());
    } catch (error) {
      print(error);
    }
  }

  Widget _loadImage(String url) {
    try {
      return Image.network(url);
    } catch (_) {
      return const Placeholder();
    }
  }

  Widget _buildBody(BuildContext context) {
    var theme = Theme.of(context);
    var screenWidth = MediaQuery.of(context).size.width;
    const drawerHeaderHeight = 75.0;

    final User? user = _currentUser;
    if (user != null) {
      return Scaffold(
          appBar: AppBar(
            title: const Text("Usos Bot"),
            leading: Builder(builder: (context) {
              return IconButton(
                  onPressed: () => Scaffold.of(context).openDrawer(),
                  icon: const Icon(Icons.menu));
            }),
            actions: [
              Column(
                children: [
                  Text(user.displayName ?? ''),
                  Text(user.email!),
                ],
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(9999),
                child: _loadImage(user.photoURL!),
              ),
              IconButton(onPressed: _logout, icon: const Icon(Icons.logout)),
            ],
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
                                style: TextStyle(
                                    color: theme.colorScheme.onPrimary),
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
                                    fontSize:
                                        screenWidth >= maxWidthMobileDevices
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
    } else {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Card(
                color: theme.colorScheme.primary,
                shadowColor: theme.colorScheme.secondary,
                elevation: ElevationSize.medium,
                child: Padding(
                    padding: const EdgeInsets.all(PaddingSize.large),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                              0, 0, 0, PaddingSize.medium),
                          child: SelectableText(
                            "Usos Bot",
                            style: TextStyle(
                                color: theme.colorScheme.onPrimary,
                                fontSize: FontSize.large,
                                fontWeight: FontWeight.w700),
                          ),
                        ),
                        SignInButton(
                          Buttons.google,
                          onPressed: _handleSignIn,
                        )
                      ],
                    )),
              )
            ],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(context),
    );
  }
}
