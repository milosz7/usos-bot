import 'package:flutter/material.dart';
import 'package:frontend_flutter/styles.dart';
import 'chat_state_dto.dart';

class ChatWindow extends StatelessWidget {
  const ChatWindow({
    super.key,
    required this.currentChatHistory,
    required this.theme,
    required this.maxWidth,
  });

  final List<ChatMessage> currentChatHistory;
  final ThemeData theme;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView(children: [
        for (var chat in currentChatHistory)
          ChatMessageBox(chat: chat, theme: theme, maxWidth: maxWidth)
      ]),
    );
  }
}

class ChatMessageBox extends StatelessWidget {
  const ChatMessageBox({
    super.key,
    required this.chat,
    required this.theme,
    required this.maxWidth,
  });

  final ChatMessage chat;
  final ThemeData theme;
  final double maxWidth;
  final String aiPlaceholder = "UsosBot";
  final String humanPlaceholder = "Ty";

  @override
  Widget build(BuildContext context) {
    return SelectionArea(
      // TO DO: change cursor on text
      child: ListTile(
          contentPadding: const EdgeInsets.all(PaddingSize.small),
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
                    constraints: BoxConstraints(maxWidth: maxWidth),
                    child: Card(
                      margin: const EdgeInsets.all(0),
                      color: theme.colorScheme.primary,
                      child: Padding(
                        padding: const EdgeInsets.all(PaddingSize.medium),
                        child: Text(
                          chat.content,
                          style: TextStyle(color: theme.colorScheme.onPrimary),
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
