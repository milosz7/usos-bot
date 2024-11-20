import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:sign_in_button/sign_in_button.dart';
import 'package:frontend_flutter/styles.dart';
import 'package:frontend_flutter/src/chat/chat_state_dto.dart';
import 'package:frontend_flutter/src/chat/chat_window.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FullPage extends StatefulWidget {
  const FullPage({super.key});
  @override
  State<FullPage> createState() => _FullPage();
}

class _FullPage extends State<FullPage> {
  final _baseUri = "http://localhost:8000";
  var _currentIndex = 0;
  var historyCaptions = <HistoryCaption>[];
  var currentChatHistory = <ChatMessage>[];

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _textController = TextEditingController();
  final double maxWidthMobileDevices = 600.0;

  User? _currentUser;

  void _changeIndex(int selectedIndex) {
    _fetchChatHistory(historyCaptions[selectedIndex].uuid)
        .then((List<ChatMessage> currentChatResponse) => {
              setState(() {
                currentChatHistory = currentChatResponse;
              })
            });
    setState(() {
      _currentIndex = selectedIndex;
    });
  }

  void _processSubmit() {
    setState(() {
      if (!_formKey.currentState!.validate()) {
        return;
      }
      var input = _textController.text;
      currentChatHistory.add(ChatMessage("human", input));
    });
  }

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      setState(() {
        _currentUser = user;
        if (_currentUser != null) {
          _fetchChatCaptions().then((List<HistoryCaption> captions) => {
                setState(() {
                  historyCaptions = captions;
                })
              });
        }
      });
    });
  }

  void _logout() async {
    await FirebaseAuth.instance.signOut();
  }

  Future<String?> _getIdTokenWithRefresh() async {
    return _currentUser!.getIdToken(true);
  }

  Future<List<HistoryCaption>> _fetchChatCaptions() async {
    try {
      var idToken = await _getIdTokenWithRefresh();
      final response =
          await http.get(Uri.parse("$_baseUri/chat/captions"), headers: {
        "Authorization": "Bearer $idToken",
      });

      if (response.statusCode == 200) {
        String responseBody = utf8.decode(response.bodyBytes);
        List<dynamic> jsonList = json.decode(responseBody);
        List<HistoryCaption> captionsResponse = jsonList.map((jsonItem) {
          return HistoryCaption.fromJson(jsonItem);
        }).toList();
        return captionsResponse;
      } else {
        print(
            "Failed to authenticate with server. Status: ${response.statusCode}");
      }
    } catch (error) {
      print("Error 1: $error");
    }
    return [];
  }

  Future<List<ChatMessage>> _fetchChatHistory(String threadId) async {
    try {
      var idToken = await _getIdTokenWithRefresh();
      final response =
          await http.get(Uri.parse("$_baseUri/chat/$threadId"), headers: {
        "Authorization": "Bearer $idToken",
      });

      if (response.statusCode == 200) {
        String responseBody = utf8.decode(response.bodyBytes);
        List<dynamic> jsonList = json.decode(responseBody);
        List<ChatMessage> currentChatResponse = jsonList.map((jsonItem) {
          return ChatMessage.fromJson(jsonItem);
        }).toList();
        return currentChatResponse;
      } else {
        print(
            "Failed to authenticate with server. Status: ${response.statusCode}");
      }
    } catch (error) {
      print("Error 2: $error");
    }
    return [];
  }

  Future<void> _handleSignIn() async {
    try {
      FirebaseAuth.instance.signInWithPopup(GoogleAuthProvider());
    } catch (error) {
      print("Error 3: $error");
    }
  }

  Widget _loadImage(String url) {
    return Image.network(url, errorBuilder: (context, exception, stackTrace) {
      return const Placeholder();
    });
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
                                  hintText: "Zadaj pytanie",
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
