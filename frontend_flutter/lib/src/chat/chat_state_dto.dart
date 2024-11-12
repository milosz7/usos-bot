enum MessageAuthor { human, ai }

class ChatMessage {
  MessageAuthor author;
  String content;
  ChatMessage(this.author, this.content);
}

class HistoryCaption {
  String caption;
  String uuid;
  HistoryCaption(this.caption, this.uuid);
}
