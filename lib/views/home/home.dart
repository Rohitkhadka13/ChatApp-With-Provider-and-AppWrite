part of 'home_imports.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late String currentUserId = "";
  @override
  void initState() {
    currentUserId =
        Provider.of<UserDataProvider>(context, listen: false).getUserId;
    Provider.of<ChatProvider>(context, listen: false).loadChats(currentUserId);
    updateOnlineStatus(userId: currentUserId, status: true);

    subscribeToRealTime(userId: currentUserId);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: kBackgroundColor,
        scrolledUnderElevation: 0,
        title: const Text(
          "Chats",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: InkWell(
              onTap: () {
                Navigator.pushNamed(context, "/profile");
              },
              child: Consumer<UserDataProvider>(
                builder: (context, value, child) {
                  return CircleAvatar(
                    backgroundImage: value.getUserProfile != null &&
                            value.getUserProfile != ""
                        ? CachedNetworkImageProvider(
                            "https://cloud.appwrite.io/v1/storage/buckets/672b869d003847f5570b/files/${value.getUserProfile}/view?project=672ae4ec00014c5b3400&mode=admin")
                        : const AssetImage("assets/user.png"),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<ChatProvider>(
              builder: (context, value, child) {
                if (value.getAllChats.isEmpty) {
                  return const Center(
                    child: Text('No chats'),
                  );
                } else {
                  List<String> otherUsers = value.getAllChats.keys.toList();
                  return ListView.builder(
                    itemCount: otherUsers.length,
                    itemBuilder: (context, index) {
                      List<ChatDataModel> chatData =
                          value.getAllChats[otherUsers[index]]!;
                      int totalChats = chatData.length;

                      UserData otherUser =
                          chatData[0].users[0].userId == currentUserId
                              ? chatData[0].users[1]
                              : chatData[0].users[0];

                      int unreadMsg = 0;
                      chatData.fold(unreadMsg, (previousValue, element) {
                        if (element.message.isSeenByReceiver == false) {
                          unreadMsg++;
                        }
                        return unreadMsg;
                      });

                      return ListTile(
                        onTap: () {
                          Navigator.pushNamed(context, "/chat",
                              arguments: otherUser);
                        },
                        leading: Stack(
                          children: [
                            CircleAvatar(
                                backgroundImage: otherUser.profilePic == "" ||
                                        otherUser.profilePic == null
                                    ? const AssetImage("assets/user.png")
                                    : CachedNetworkImageProvider(
                                        "https://cloud.appwrite.io/v1/storage/buckets/672b869d003847f5570b/files/${otherUser.profilePic}/view?project=672ae4ec00014c5b3400&mode=admin")),
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: CircleAvatar(
                                radius: 6,
                                backgroundColor: otherUser.isOnline == true
                                    ? kGreen
                                    : Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            chatData[totalChats - 1].message.sender !=
                                    currentUserId
                                ? unreadMsg != 0
                                    ? CircleAvatar(
                                        backgroundColor: kPrimaryColor,
                                        radius: 10,
                                        child: Text(
                                          unreadMsg.toString(),
                                          style: const TextStyle(
                                              fontSize: 11,
                                              color: kBackgroundColor),
                                        ),
                                      )
                                    : const SizedBox()
                                : const SizedBox(),
                            const SizedBox(height: 8),
                            Text(
                              formatDate(
                                  chatData[totalChats - 1].message.timeStamp),
                            ),
                          ],
                        ),
                        title: Text(otherUser.name!),
                        subtitle: Text(
                          "${chatData[totalChats - 1].message.sender == currentUserId ? "You:" : ""}  ${chatData[totalChats - 1].message.isImage == true ? "sent an image" : chatData[totalChats - 1].message.message}",
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, "/search");
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
