import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:sign_in_button/sign_in_button.dart';
import 'package:frontend_flutter/styles.dart';
import 'package:frontend_flutter/src/error/flash_error.dart';
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
  var _historyCaptions = <HistoryCaption>[];
  var _currentChatHistory = <ChatMessage>[];
  final TextEditingController _textController = TextEditingController();
  final double _maxWidthMobileDevices = 600.0;
  final _formKey = GlobalKey<FormState>();
  bool _isFetching = false;
  var _currentIndex = 0;
  User? _currentUser;

  void _logger(String error) {
    print(error);
  }

  void _changeIndex(int selectedIndex) {
    if (selectedIndex == 0) {
      setState(() {
        _currentChatHistory.clear();
        _currentIndex = selectedIndex;
      });
      return;
    }
    _fetchChatHistory(_historyCaptions[selectedIndex - 1].uuid)
        .then((List<ChatMessage> currentChatResponse) => {
              setState(() {
                _currentChatHistory = currentChatResponse;
              })
            });
    setState(() {
      _currentIndex = selectedIndex;
    });
  }

  void _processSubmit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    var input = _textController.text;
    _textController.text = "";
    setState(() {
      _currentChatHistory.add(ChatMessage("human", input));
    });

    if (_currentIndex != 0) {
      var threadId = _getCurrentThreadId();
      _postAskModel(input, threadId).then((bool response) {
        if (response) {
          _processChunks(threadId);
        }
      });
    } else {
      _postInitChat(input).then((String? threadId) {
        if (threadId != null) {
          _createNewHistoryCaption(input, threadId);
          _processChunks(threadId);
        }
      });
    }
  }

  void _createNewHistoryCaption(String input, String threadId) {
    setState(() {
      _historyCaptions.insert(0, HistoryCaption(input, threadId));
      _currentIndex = 1;
    });
  }

  Future<void> _processChunks(String threadId) async {
    setState(() {
      _isFetching = true;
      _currentChatHistory.add(ChatMessage("ai", ""));
    });

    bool isFinished = false;
    while (!isFinished) {
      await _fetchNextChunk(threadId).then((ChunkResponse? chunkResponse) {
        if (chunkResponse != null) {
          setState(() {
            _currentChatHistory.last.content =
                _currentChatHistory.last.content + chunkResponse.chunk;
          });
          isFinished = chunkResponse.isFinished;
        } else {
          isFinished = true;
        }
      });
    }

    setState(() {
      _isFetching = false;
    });
  }

  String _getCurrentThreadId() {
    return _historyCaptions[_currentIndex - 1].uuid;
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
                  _historyCaptions = captions;
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

      if (response.statusCode == HttpResponseCodes.ok) {
        String responseBody = utf8.decode(response.bodyBytes);
        List<dynamic> jsonList = json.decode(responseBody);
        List<HistoryCaption> captionsResponse = jsonList.map((jsonItem) {
          return HistoryCaption.fromJson(jsonItem);
        }).toList();
        return captionsResponse;
      } else {
        if (mounted) {
          FlashError.showFlashError(context, response.statusCode);
        }
        _logger(
            "Failed to authenticate with server. Status: ${response.statusCode}");
      }
    } catch (error) {
      if (mounted) {
        FlashError.showFlashError(
            context, HttpResponseCodes.serviceUnavailable);
      }
      _logger("Error 1: $error");
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

      if (response.statusCode == HttpResponseCodes.ok) {
        String responseBody = utf8.decode(response.bodyBytes);
        List<dynamic> jsonList = json.decode(responseBody);
        List<ChatMessage> currentChatResponse = jsonList.map((jsonItem) {
          return ChatMessage.fromJson(jsonItem);
        }).toList();
        return currentChatResponse;
      } else {
        if (mounted) {
          FlashError.showFlashError(context, response.statusCode);
        }
        _logger(
            "Failed to authenticate with server. Status: ${response.statusCode}");
      }
    } catch (error) {
      if (mounted) {
        FlashError.showFlashError(
            context, HttpResponseCodes.serviceUnavailable);
      }
      _logger("Error 2: $error");
    }
    return [];
  }

  Future<ChunkResponse?> _fetchNextChunk(String threadId) async {
    try {
      var idToken = await _getIdTokenWithRefresh();
      final response =
          await http.get(Uri.parse("$_baseUri/chat/next/$threadId"), headers: {
        "Authorization": "Bearer $idToken",
      });

      if (response.statusCode == HttpResponseCodes.ok) {
        String responseBody = utf8.decode(response.bodyBytes);
        final Map<String, dynamic> json = jsonDecode(responseBody);
        ChunkResponse chunkResponse = ChunkResponse.fromJson(json);
        return chunkResponse;
      } else {
        if (mounted) {
          FlashError.showFlashError(context, response.statusCode);
        }
        _logger(
            "Failed to authenticate with server. Status: ${response.statusCode}");
      }
    } catch (error) {
      if (mounted) {
        FlashError.showFlashError(
            context, HttpResponseCodes.serviceUnavailable);
      }
      _logger("Error 5: $error");
    }
    return null;
  }

  Future<bool> _postAskModel(String message, String threadId) async {
    try {
      var idToken = await _getIdTokenWithRefresh();
      final response = await http.post(Uri.parse("$_baseUri/chat/$threadId"),
          headers: {
            "Authorization": "Bearer $idToken",
            "Content-Type": "application/json",
          },
          body: jsonEncode({"message": message}));

      if (response.statusCode == 200) {
        return true;
      } else {
        if (mounted) {
          FlashError.showFlashError(context, response.statusCode);
        }
        _logger(
            "Failed to authenticate with server. Status: ${response.statusCode}");
      }
    } catch (error) {
      if (mounted) {
        FlashError.showFlashError(
            context, HttpResponseCodes.serviceUnavailable);
      }
      _logger("Error 4: $error");
    }

    return false;
  }

  Future<String?> _postInitChat(String message) async {
    try {
      var idToken = await _getIdTokenWithRefresh();
      final response = await http.post(Uri.parse("$_baseUri/chat"),
          headers: {
            "Authorization": "Bearer $idToken",
            "Content-Type": "application/json",
          },
          body: jsonEncode({"message": message}));

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        final threadId = responseBody["thread_id"] as String;
        return threadId;
      } else {
        if (mounted) {
          FlashError.showFlashError(context, response.statusCode);
        }
        _logger(
            "Failed to authenticate with server. Status: ${response.statusCode}");
      }
    } catch (error) {
      if (mounted) {
        FlashError.showFlashError(
            context, HttpResponseCodes.serviceUnavailable);
      }
      _logger("Error 4: $error");
    }
    return null;
  }

  Future<void> _handleSignIn() async {
    try {
      FirebaseAuth.instance.signInWithPopup(GoogleAuthProvider());
    } catch (error) {
      if (mounted) {
        FlashError.showFlashError(
            context, HttpResponseCodes.serviceUnavailable);
      }
      _logger("Error 3: $error");
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
                borderRadius: BorderRadius.circular(BorderRadiusSize.max),
                child: _loadImage(user.photoURL!),
              ),
              IconButton(onPressed: _logout, icon: const Icon(Icons.logout)),
            ],
          ),
          body: Column(
            children: [
              ChatWindow(
                  currentChatHistory: _currentChatHistory,
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
                                onFieldSubmitted: (_) =>
                                    _isFetching ? null : _processSubmit(),
                                decoration: InputDecoration(
                                  hintText: "Zadaj pytanie",
                                  errorStyle: const TextStyle(fontSize: 0),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                        BorderRadiusSize.rounded),
                                    borderSide: BorderSide(
                                      color: theme.colorScheme.primary,
                                      width: 2.0,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                        BorderRadiusSize.rounded),
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
                                elevation: ElevationSize.medium,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 30, vertical: 15),
                              ),
                              onPressed: _isFetching ? null : _processSubmit,
                              child: Text(
                                "Wyślij",
                                style: TextStyle(
                                    color: theme.colorScheme.onPrimary,
                                    fontSize:
                                        screenWidth >= _maxWidthMobileDevices
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
                ListTile(
                  title: const Text(
                    "Nowy Czat",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  selected: _currentIndex == 0,
                  onTap: () {
                    _changeIndex(0);
                    Navigator.pop(context);
                  },
                ),
                for (var i = 0; i < _historyCaptions.length; i++)
                  ListTile(
                    title: Text(_historyCaptions[i].caption),
                    selected: _currentIndex == i + 1,
                    onTap: () {
                      _changeIndex(i + 1);
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
