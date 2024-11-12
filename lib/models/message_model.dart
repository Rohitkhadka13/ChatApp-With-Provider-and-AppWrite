class MessageModel {
  final String message;
  final String sender;
  final String receiver;
  final String? messageId;
  final DateTime timeStamp;
  final bool isSeenByReceiver;
  final bool? isImage;

  MessageModel({
    required this.message,
    required this.sender,
    required this.receiver,
    this.messageId,
    required this.timeStamp,
    required this.isSeenByReceiver,
    this.isImage,
  });

  // convert Document Model to message model
  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
        message: map["message"],
        sender: map["senderId"],
        receiver: map["receiverId"],
        timeStamp: DateTime.parse(map["timestamp"]),
        isSeenByReceiver: map["isSeenbyReceiver"],
        isImage: map["isImage"],
        messageId: map["\$id"]);
  }
}
