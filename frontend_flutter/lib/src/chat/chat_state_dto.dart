class ChunkResponse {
  String chunk;
  bool isFinished;
  ChunkResponse(this.chunk, this.isFinished);

  factory ChunkResponse.fromJson(Map<String, dynamic> json) {
    return ChunkResponse(
      json['chunk'] as String,
      json['is_finished'] as bool,
    );
  }
}

class ChatMessage {
  String author;
  String content;
  ChatMessage(this.author, this.content);

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      json['author'] as String,
      json['content'] as String,
    );
  }
}

class HistoryCaption {
  String caption;
  String uuid;
  HistoryCaption(this.caption, this.uuid);

  factory HistoryCaption.fromJson(Map<String, dynamic> json) {
    return HistoryCaption(
      json['caption'] as String,
      json['thread_id'] as String,
    );
  }
}
