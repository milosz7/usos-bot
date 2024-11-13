import 'package:flutter/material.dart';
import 'package:frontend_flutter/styles.dart';
import 'chat_state_dto.dart';

class ChatWindow extends StatelessWidget {
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> currentChatHistory;
  final ThemeData theme;
  final double screenWidth;

  ChatWindow({
    super.key,
    required this.currentChatHistory,
    required this.theme,
    required this.screenWidth,
  }) {
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(_scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200), curve: Curves.ease);
    }
  }

  @override
  Widget build(BuildContext context) {
    var chatMessages = [
      for (var chat in currentChatHistory)
        ChatMessageBox(chat: chat, theme: theme, screenWidth: screenWidth)
    ];
    return Expanded(
      child: ListView(controller: _scrollController, children: chatMessages),
    );
  }
}

class ChatMessageBox extends StatelessWidget {
  const ChatMessageBox({
    super.key,
    required this.chat,
    required this.theme,
    required this.screenWidth,
  });

  final ChatMessage chat;
  final ThemeData theme;
  final double screenWidth;
  final String aiPlaceholder = "UsosBot";
  final String humanPlaceholder = "Ty";
  final double maxWidthMobileDevices = 600.0;

  @override
  Widget build(BuildContext context) {
    var maxMessageWidth = screenWidth * 0.8;
    return SelectionArea(
      // TO DO: change cursor on text
      child: ListTile(
          contentPadding: EdgeInsets.all(screenWidth >= maxWidthMobileDevices
              ? PaddingSize.large
              : PaddingSize.small),
          title: Row(
            mainAxisAlignment: chat.author == MessageAuthor.ai
                ? MainAxisAlignment.start
                : MainAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: chat.author == MessageAuthor.ai
                    ? CrossAxisAlignment.start
                    : CrossAxisAlignment.end,
                children: [
                  Text(
                    chat.author == MessageAuthor.ai
                        ? aiPlaceholder
                        : humanPlaceholder,
                    style: TextStyle(
                        color: theme.colorScheme.onSurface,
                        fontSize: FontSize.small),
                  ),
                  Container(
                    constraints: BoxConstraints(maxWidth: maxMessageWidth),
                    child: Card(
                      margin: const EdgeInsets.all(0),
                      color: theme.colorScheme.primary,
                      child: Padding(
                        padding: const EdgeInsets.all(PaddingSize.medium),
                        child: Text(
                          chat.content,
                          style: TextStyle(
                              color: theme.colorScheme.onPrimary,
                              fontSize: screenWidth >= maxWidthMobileDevices
                                  ? FontSize.large
                                  : FontSize.small),
                          softWrap: true,
                        ),
                      ),
                    ),
                  )
                ],
              )
            ],
          )),
    );
  }
}
