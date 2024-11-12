// ignore_for_file: avoid_print

import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:chat_app/main.dart';
import 'package:chat_app/models/message_model.dart';
import 'package:chat_app/providers/user_data_provider.dart';
import 'package:provider/provider.dart';

import '../constants/appwrite_consts.dart';
import '../models/chat_data_model.dart';
import '../models/user_data.dart';
import '../providers/chat_provider.dart';

Account account = Account(client);
final Databases databases = Databases(client);
final Storage storage = Storage(client);
final Realtime realtime = Realtime(client);
RealtimeSubscription? subscription;

//realtime changes subscribe
subscribeToRealTime({required String userId}) {
  subscription = realtime.subscribe([
    "databases.$db.collections.$chatCollection.documents",
    "databases.$db.collections.$userCollection.documents",
  ]);
  print("subscribed to real time");
  subscription!.stream.listen((data) {
    print("some event occured");
    // print(data.events);
    // print(data.payload);
    final firstItem = data.events[0].split(".");
    final eventType = firstItem[firstItem.length - 1];
    print("event type :$eventType");
    if (eventType == "create") {
      Provider.of<ChatProvider>(navigatorKey.currentState!.context,
              listen: false)
          .loadChats(userId);
    } else if (eventType == "update") {
      Provider.of<ChatProvider>(navigatorKey.currentState!.context,
              listen: false)
          .loadChats(userId);
    } else if (eventType == "delete") {
      Provider.of<ChatProvider>(navigatorKey.currentState!.context,
              listen: false)
          .loadChats(userId);
    }
  });
}

// save phone no to datbase
Future<bool> savePhoneToDb({
  required String phoneno,
  required String userId,
}) async {
  try {
    final response = await databases.createDocument(
      databaseId: db,
      collectionId: userCollection,
      documentId: userId,
      data: {
        "phone_no": phoneno,
        "userId": userId,
      },
    );
    print(response);
    return true;
  } on AppwriteException catch (e) {
    print(" cannot save to database : $e");
    // throw "Cannot save to user Database $e";
    return false;
  }
}

//check phone no in db
Future<String> checkPhoneNumber({required String phoneNo}) async {
  try {
    final DocumentList matchUser = await databases.listDocuments(
        databaseId: db,
        collectionId: userCollection,
        queries: [Query.equal("phone_no", phoneNo)]);
    if (matchUser.total > 0) {
      final Document user = matchUser.documents[0];
      if (user.data["phone_no"] != null || user.data["userId"] == "") {
        return user.data['userId'];
      } else {
        print("no user exist in db");
        return "user_doesn't_exist";
      }
    } else {
      print("no user exist in db");
      return "user_doesn't_exist";
    }
  } on AppwriteException catch (e) {
    print("error on reading database :$e");
    return "user_doesn't_exist";
  }
}

// send otp to the phone
Future<String> createPhoneSession({required String phone}) async {
  try {
    final userId = await checkPhoneNumber(phoneNo: phone);
    if (userId == "user_doesn't_exist") {
      final Token data =
          await account.createPhoneToken(userId: ID.unique(), phone: phone);

      //save user to collecttion
      savePhoneToDb(phoneno: phone, userId: data.userId);
      return data.userId;
    } else {
      //create phone token for existing user
      final Token data =
          await account.createPhoneToken(userId: userId, phone: phone);
      return data.userId;
    }
  } on AppwriteException catch (e) {
    print("error on phone session : $e");
    return "login_error";
  }
}

//login with otp
Future<bool> loginWithOtp({required String userId, required String otp}) async {
  try {
    final Session session = await account.updatePhoneSession(
      userId: userId,
      secret: otp,
    );
    print(session.userId);
    return true;
  } on AppwriteException catch (e) {
    print("otp login error : $e");
    return false;
  }
}

//check session exists or not
Future<bool> checkSession() async {
  try {
    final Session session = await account.getSession(sessionId: "current");
    print("session exists");
    return true;
  } on AppwriteException catch (e) {
    print("session doesnt exist please login");
    return false;
  }
}

//logout and session clear
Future logoutUser() async {
  await account.deleteSession(sessionId: "current");
}

//load user data
Future<UserData?> getUserDetails({
  required String userId,
}) async {
  try {
    final response = await databases.getDocument(
      databaseId: db,
      collectionId: userCollection,
      documentId: userId,
    );
    print("getting user data");
    print(response.data);
    Provider.of<UserDataProvider>(navigatorKey.currentContext!, listen: false)
        .setUserName(response.data['name'] ?? "");
    Provider.of<UserDataProvider>(navigatorKey.currentContext!, listen: false)
        .setUserProfile(response.data["profile_pic"] ?? "");
    return UserData.toMap(response.data);
  } catch (e) {
    print("error while getting data");
    return null;
  }
}

//update user data
Future<bool> updateUserDetails(
  String pic, {
  required String userId,
  required String name,
}) async {
  try {
    final data = await databases.updateDocument(
      databaseId: db,
      collectionId: userCollection,
      documentId: userId,
      data: {
        "name": name,
        "profile_pic": pic,
      },
    );

    Provider.of<UserDataProvider>(navigatorKey.currentContext!, listen: false)
        .setUserName(name);
    Provider.of<UserDataProvider>(navigatorKey.currentContext!, listen: false)
        .setUserProfile(pic);
    print(data);
    return true;
  } on AppwriteException catch (e) {
    print("cannot update user data : $e");
    return false;
  }
}

// upload images in db to bucket
Future<String?> saveImageToBucket({required InputFile image}) async {
  try {
    final response = await storage.createFile(
      bucketId: storageBucket,
      fileId: ID.unique(),
      file: image,
    );
    print("save image response $response");
    return response.$id;
  } on AppwriteException catch (e) {
    print("error on saving image in db : $e");
    return null;
  }
}

//update image in bucket
Future<String?> updateImageOnBucket({
  required String oldImageId,
  required InputFile image,
}) async {
  try {
    deleteImageFromBucket(oldImageId: oldImageId);
    final newImage = saveImageToBucket(image: image);
    return newImage;
  } on AppwriteException catch (e) {
    print("cannot update image/delete : $e");
    return null;
  }
}

//delete image from bucket
Future<bool> deleteImageFromBucket({
  required String oldImageId,
}) async {
  try {
    await storage.deleteFile(bucketId: storageBucket, fileId: oldImageId);

    return true;
  } on AppwriteException catch (e) {
    print("cannot delete image : $e");
    return false;
  }
}

//search user from database
Future<DocumentList?> searchUser({
  required String searchItem,
  required String userId,
}) async {
  try {
    final DocumentList users = await databases
        .listDocuments(databaseId: db, collectionId: userCollection, queries: [
      Query.search("phone_no", searchItem),
      Query.notEqual("userId", userId),
    ]);

    print("total match user ${users.total}");
    return users;
  } on AppwriteException catch (e) {
    print("error on searching users : $e");
    return null;
  }
}

//create chat and save to database
Future createNewChat({
  required String message,
  required String senderId,
  required String receiverId,
  required bool isImage,
}) async {
  try {
    final msg = await databases.createDocument(
      databaseId: db,
      collectionId: chatCollection,
      documentId: ID.unique(),
      data: {
        "message": message,
        "senderId": senderId,
        "receiverId": receiverId,
        "timestamp": DateTime.now().toIso8601String(),
        "isSeenbyReceiver": false,
        "isImage": isImage,
        "userData": [senderId, receiverId]
      },
    );
    print("messeage sent");
    return true;
  } on AppwriteException catch (e) {
    print("failed to send message : $e");
    return false;
  }
}

//list all the users chats
Future<Map<String, List<ChatDataModel>>?> currentUserChats(
    String userId) async {
  try {
    var results = await databases
        .listDocuments(databaseId: db, collectionId: chatCollection, queries: [
      Query.or(
          [Query.equal("senderId", userId), Query.equal("receiverId", userId)]),
      Query.orderDesc("timestamp")
     
    ]);
    final DocumentList chatDocuments = results;
    print(
        "chat documents: ${chatDocuments.total} and ${chatDocuments.documents.length}");
    Map<String, List<ChatDataModel>> chats = {};

    if (chatDocuments.documents.isNotEmpty) {
      for (var i = 0; i < chatDocuments.documents.length; i++) {
        var doc = chatDocuments.documents[i];
        String sender = doc.data["senderId"];
        String receiver = doc.data["receiverId"];
        MessageModel message = MessageModel.fromMap(doc.data);
        List<UserData> users = [];
        for (var user in doc.data["userData"]) {
          users.add(UserData.toMap(user));
        }
        String key = (sender == userId) ? receiver : sender;

        if (chats[key] == null) {
          chats[key] = [];
        }
        chats[key]!.add(ChatDataModel(message: message, users: users));
      }
    }
    return chats;
  } catch (e) {
    print("error on getting current user chats : $e");
    return null;
  }
}

//delete user chats from db
Future deleteCurrentUserChat({
  required String chatId,
}) async {
  try {
    await databases.deleteDocument(
      databaseId: db,
      collectionId: chatCollection,
      documentId: chatId,
    );
  } catch (e) {
    print("error on deleting chat : $e");
  }
}

//edit chat message and update in database
Future editChat({
  required String chatId,
  required String message,
}) async {
  try {
    await databases.updateDocument(
        databaseId: db,
        collectionId: chatCollection,
        documentId: chatId,
        data: {
          "message": message,
        });
    print("message edited ");
  } catch (e) {
    print("error on editing chat : $e");
  }
}

//update message  seen status
Future updatIsSeen({
  required List<String> chatIds,
}) async {
  try {
    for (var chatid in chatIds) {
      await databases.updateDocument(
          databaseId: db,
          collectionId: chatCollection,
          documentId: chatid,
          data: {
            "isSeenbyReceiver": true,
          });
      print("updated isseen status");
    }
  } catch (e) {
    print("error in updating isseen status : $e");
  }
}

// update the online status
Future updateOnlineStatus({
  required String userId,
  required bool status,
}) async {
  try {
    await databases.updateDocument(
        databaseId: db,
        collectionId: userCollection,
        documentId: userId,
        data: {"isOnline": status});
    print("update user online status");
  } catch (e) {
    print("error on updating online status : $e");
  }
}

//