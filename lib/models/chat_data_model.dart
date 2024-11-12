import 'package:chat_app/models/message_model.dart';
import 'package:chat_app/models/user_data.dart';

class ChatDataModel {
  final MessageModel message;
  final List<UserData> users;

  ChatDataModel({
    required this.message,
    required this.users,
  });
}
