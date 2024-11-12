part of 'chat_page_imports.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  TextEditingController messageController = TextEditingController();
  TextEditingController editmessageController = TextEditingController();
  late String currentUserId;
  late String currentUserName;
  FilePickerResult? _filePickerResult;

  @override
  void initState() {
    currentUserId =
        Provider.of<UserDataProvider>(context, listen: false).getUserId;
    currentUserName =
        Provider.of<UserDataProvider>(context, listen: false).getUserName;
    Provider.of<ChatProvider>(context, listen: false).loadChats(currentUserId);
    super.initState();
  }

//send text message
  void _sendMessage({
    required UserData receiver,
  }) {
    if (messageController.text.isNotEmpty) {
      setState(() {
        createNewChat(
                message: messageController.text,
                senderId: currentUserId,
                receiverId: receiver.userId,
                isImage: false)
            .then((value) {
          if (value) {
            Provider.of<ChatProvider>(context, listen: false).addMessage(
                MessageModel(
                  message: messageController.text,
                  sender: currentUserId,
                  receiver: receiver.userId,
                  timeStamp: DateTime.now(),
                  isSeenByReceiver: false,
                ),
                currentUserId,
                [UserData(phone: "", userId: currentUserId), receiver]);
            messageController.clear();
          }
        });
      });
    }
  }

  void _openFilePicker(UserData receiver) async {
    FilePickerResult? result = await FilePicker.platform
        .pickFiles(type: FileType.image, allowMultiple: true);
    setState(() {
      _filePickerResult = result;
      uploadAllImages(receiver);
    });
  }

// to upload file in db
  void uploadAllImages(UserData receiver) async {
    if (_filePickerResult != null) {
      _filePickerResult!.paths.forEach((path) {
        if (path != null) {
          var file = File(path);
          final fileBytes = file.readAsBytesSync();
          final inputFile = InputFile.fromBytes(
              bytes: fileBytes, filename: file.path.split("/").last);

          //saving images to storage
          saveImageToBucket(image: inputFile).then((imageId) {
            if (imageId != null) {
              createNewChat(
                      message: imageId,
                      senderId: currentUserId,
                      receiverId: receiver.userId,
                      isImage: true)
                  .then((value) {
                if (value) {
                  Provider.of<ChatProvider>(context, listen: false).addMessage(
                      MessageModel(
                          message: imageId,
                          sender: currentUserId,
                          receiver: receiver.userId,
                          timeStamp: DateTime.now(),
                          isSeenByReceiver: false),
                      currentUserId,
                      [UserData(phone: "", userId: currentUserId), receiver]);
                }
              });
            }
          });
        } else {
          print("path is null");
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    UserData receiver = ModalRoute.of(context)!.settings.arguments as UserData;
    return Consumer<ChatProvider>(
      builder: (context, value, child) {
        final userAndOtherChats = value.getAllChats[receiver.userId] ?? [];

        bool? otherUserOnline = userAndOtherChats.isNotEmpty
            ? userAndOtherChats[0].users[0].userId == receiver.userId
                ? userAndOtherChats[0].users[0].isOnline
                : userAndOtherChats[0].users[1].isOnline
            : false;

        List<String> receiveMsgList = [];
        for (var chat in userAndOtherChats) {
          if (chat.message.receiver == currentUserId) {
            if (chat.message.isSeenByReceiver == false) {
              receiveMsgList.add(chat.message.messageId!);
            }
          }
        }
        updatIsSeen(chatIds: receiveMsgList);
        return Scaffold(
          backgroundColor: kBackgroundColor,
          appBar: AppBar(
            backgroundColor: kBackgroundColor,
            leadingWidth: 40,
            scrolledUnderElevation: 0,
            elevation: 0,
            title: Row(
              children: [
                CircleAvatar(
                  backgroundImage: receiver.profilePic == "" ||
                          receiver.profilePic == null
                      ? const Image(image: AssetImage("assets/user.png")).image
                      : CachedNetworkImageProvider(
                          "https://cloud.appwrite.io/v1/storage/buckets/672b869d003847f5570b/files/${receiver.profilePic}/view?project=672ae4ec00014c5b3400&mode=admin"),
                ),
                const SizedBox(
                  width: 10,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      receiver.name!,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      otherUserOnline == true ? "Online" : "Offline",
                      style: const TextStyle(
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          body: Column(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: ListView.builder(
                    reverse: true,
                    itemCount: userAndOtherChats.length,
                    itemBuilder: (context, index) {
                      final msg = userAndOtherChats[
                              userAndOtherChats.length - 1 - index]
                          .message;
                      return GestureDetector(
                        onLongPress: () {
                          showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: msg.isImage == true
                                      ? const Text("Delete Image")
                                      : const Text("Delete Message"),
                                  content: msg.isImage == true
                                      ? Text(msg.sender == currentUserId
                                          ? "Delete this image"
                                          : "This image can't be deleted")
                                      : Text(msg.sender == currentUserId
                                          ? "Confirm to delete this message"
                                          : "This message can't be deleted"),
                                  actions: [
                                    TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: const Text(
                                          "Cancel",
                                          style:
                                              TextStyle(color: kPrimaryColor),
                                        )),
                                    msg.sender == currentUserId
                                        ? TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                              editmessageController.text =
                                                  msg.message;
                                              showDialog(
                                                  context: context,
                                                  builder: (context) {
                                                    return AlertDialog(
                                                      title: const Text(
                                                          "Edit Message"),
                                                      content: TextFormField(
                                                        controller:
                                                            editmessageController,
                                                        maxLines: 10,
                                                      ),
                                                      actions: [
                                                        TextButton(
                                                            onPressed: () {
                                                              editChat(
                                                                chatId: msg
                                                                    .messageId!,
                                                                message:
                                                                    editmessageController
                                                                        .text,
                                                              );
                                                              Navigator.pop(
                                                                  context);
                                                              editmessageController
                                                                  .text = "";
                                                            },
                                                            child: const Text(
                                                                "Ok")),
                                                        TextButton(
                                                            onPressed: () {
                                                              Navigator.pop(
                                                                  context);
                                                            },
                                                            child:
                                                                Text("Cancel")),
                                                      ],
                                                    );
                                                  });
                                            },
                                            child: Text("Edit"))
                                        : const SizedBox(),
                                    msg.sender == currentUserId
                                        ? TextButton(
                                            onPressed: () {
                                              Provider.of<ChatProvider>(context,
                                                      listen: false)
                                                  .deleteMessage(
                                                msg,
                                                currentUserId,
                                                msg.isImage == true
                                                    ? msg.message
                                                    : null, // Pass null if not an image
                                              );
                                              Navigator.pop(context);
                                            },
                                            child: const Text(
                                              "Delete",
                                              style:
                                                  TextStyle(color: Colors.red),
                                            ),
                                          )
                                        : const SizedBox(),
                                  ],
                                );
                              });
                        },
                        child: ChatsMessage(
                          msg: msg,
                          currentUser: currentUserId,
                          isImage: msg.isImage ?? false,
                        ),
                      );
                    },
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.all(10),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: kSecondaryColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        onSubmitted: (value) =>
                            _sendMessage(receiver: receiver),
                        controller: messageController,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: "Type a message",
                        ),
                      ),
                    ),
                    IconButton(
                        onPressed: () {
                          _openFilePicker(receiver);
                        },
                        icon: const Icon(Icons.image)),
                    IconButton(
                        onPressed: () {
                          _sendMessage(receiver: receiver);
                        },
                        icon: const Icon(Icons.send))
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
