part of 'search_import.dart';





class SearchUser extends StatefulWidget {
  const SearchUser({super.key});

  @override
  State<SearchUser> createState() => _SearchUserState();
}

class _SearchUserState extends State<SearchUser> {
  TextEditingController _searchController = TextEditingController();
  late DocumentList searchUsers = DocumentList(documents: [], total: -1);

  //handle the serach
  void _handleSearch() {
    searchUser(
            searchItem: _searchController.text,
            userId:
                Provider.of<UserDataProvider>(context, listen: false).getUserId)
        .then((value) {
      if (value != null) {
        setState(() {
          searchUsers = value;
        });
      } else {
        setState(() {
          DocumentList(documents: [], total: 0);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            "Search User",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          bottom: PreferredSize(
              preferredSize: const Size.fromHeight(50),
              child: Container(
                decoration: BoxDecoration(
                  color: kSecondaryColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                margin: const EdgeInsets.all(8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: Row(
                  children: [
                    Expanded(
                        child: TextField(
                      controller: _searchController,
                      onSubmitted: (value) => _handleSearch(),
                      decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: "Enter a Phone Number"),
                    )),
                    IconButton(
                      onPressed: () {
                        _handleSearch();
                      },
                      icon: const Icon(
                        Icons.search,
                      ),
                    )
                  ],
                ),
              )),
        ),
        body: searchUsers.total == -1
            ? const Center(
                child: Text("Search Users above"),
              )
            : searchUsers.total == 0
                ? const Center(
                    child: Text("No User Found"),
                  )
                : ListView.builder(
                    itemCount: searchUsers.documents.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            "/chat",
                            arguments: UserData.toMap(
                                searchUsers.documents[index].data),
                          );
                        },
                        title: Text(searchUsers.documents[index].data["name"] ??
                            "Unknown Name"),
                        subtitle: Text(
                            searchUsers.documents[index].data["phone_no"] ??
                                "No Phone Number"),
                        leading: CircleAvatar(
                          backgroundImage: (searchUsers.documents[index]
                                          .data["profile_pic"] !=
                                      null &&
                                  searchUsers.documents[index]
                                          .data["profile_pic"] !=
                                      "")
                              ? NetworkImage(
                                  "https://cloud.appwrite.io/v1/storage/buckets/672b869d003847f5570b/files/${searchUsers.documents[index].data["profile_pic"]}/view?project=672ae4ec00014c5b3400&mode=admin")
                              : const AssetImage("assets/user.png"),
                        ),
                      );
                    },
                  ));
  }
}
