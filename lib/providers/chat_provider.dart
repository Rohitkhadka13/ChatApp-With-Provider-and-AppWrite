import 'dart:async';

import 'package:chat_app/controllers/appwrite_controllers.dart';
import 'package:chat_app/models/chat_data_model.dart';
import 'package:flutter/foundation.dart';

import '../models/message_model.dart';
import '../models/user_data.dart';

class ChatProvider extends ChangeNotifier {
  Map<String, List<ChatDataModel>> _chats = {};

//get all user chats

  Map<String, List<ChatDataModel>> get getAllChats => _chats;

  Timer? _debounce;

// to load current user chats
  void loadChats(String currentUser) async {
    if(_debounce?.isActive?? false) {
      _debounce?.cancel();
    }else{
_debounce = Timer(Duration(seconds: 1), () async{
   Map<String, List<ChatDataModel>>? loadChats =
        await currentUserChats(currentUser);
    if (loadChats != null) {
      _chats = loadChats;

      _chats.forEach((key, value) {
        value
            .sort((a, b) => a.message.timeStamp.compareTo(b.message.timeStamp));
      });
      print("Loaded chats: $_chats");
      print("chats updated in provider");
      notifyListeners();
    }
});
    }
   
  }

  //add chat message when user send a new message (outgoing)
  void addMessage(
      MessageModel message, String currentUser, List<UserData> users) {
    try {
      if (message.sender == currentUser) {
        if (_chats[message.receiver] == null) {
          _chats[message.receiver] = [];
        }
        _chats[message.receiver]!
            .add(ChatDataModel(message: message, users: users));
      } else {
        if (_chats[message.sender] == null) {
          _chats[message.sender] = [];
        }
        _chats[message.sender]!
            .add(ChatDataModel(message: message, users: users));
      }
      notifyListeners();
    } catch (e) {
      print("error on adding message using chatProvider: $e");
    }
  }

  //delete message from chats data
  void deleteMessage(
      MessageModel message, String currentUser, String? imageId) async {
    try {
      if (message.sender == currentUser) {
        _chats[message.receiver]!
            .removeWhere((element) => element.message == message);

        // Only delete the image if it's an image message and imageId is provided
        if (imageId != null && message.isImage == true) {
          deleteImageFromBucket(oldImageId: imageId);
          print("chat image deleted from bucket");
        }

        deleteCurrentUserChat(chatId: message.messageId!);
      } else {
        _chats[message.sender]!
            .removeWhere((element) => element.message == message);
        print("message deleted");
      }
      notifyListeners();
    } catch (e) {
      print("error on deleting message using chatProvider: $e");
    }
  }

  // clear all chats
  void clearChats() {
    _chats = {};
    notifyListeners();
  }
}
