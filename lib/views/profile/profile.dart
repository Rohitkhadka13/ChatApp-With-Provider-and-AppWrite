// ignore_for_file: use_build_context_synchronously, unnecessary_null_comparison

part of 'profile_import.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Consumer<UserDataProvider>(builder: (context, value, child) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Profile"),
          centerTitle: true,
        ),
        body: ListView(
          children: [
            ListTile(
              onTap: () => Navigator.pushNamed(context, "/update",
                  arguments: {"title": "edit"}),
              leading: CircleAvatar(
                backgroundImage: value.getUserProfile != null ||
                        value.getUserProfile != ""
                    ? CachedNetworkImageProvider(
                        "https://cloud.appwrite.io/v1/storage/buckets/672b869d003847f5570b/files/${value.getUserProfile}/view?project=672ae4ec00014c5b3400&mode=admin")
                    : const Image(image: AssetImage("assets/user.png")).image,
              ),
              title: Text(value.getUserName),
              subtitle: Text(value.getUserPhone),
              trailing: const Icon(Icons.edit_outlined),
            ),
            const Divider(),
            const ListTile(
              leading: Icon(Icons.info_outline),
              title: Text("About"),
              trailing: Icon(Icons.arrow_forward_ios),
            ),
            const Divider(),
            const ListTile(
              leading: Icon(Icons.policy_rounded),
              title: Text("Privacy and Policy"),
              trailing: Icon(Icons.arrow_forward_ios),
            ),
            const Divider(),
            ListTile(
              onTap: () async {
                await LocalSavedData.clearAllData();
                Provider.of<UserDataProvider>(context, listen: false)
                    .clearAllProvider();
                Provider.of<ChatProvider>(context, listen: false).clearChats();
                updateOnlineStatus(
                    userId:
                        Provider.of<UserDataProvider>(context, listen: false)
                            .getUserId,
                    status: false);
                await logoutUser();
                Navigator.pushNamedAndRemoveUntil(
                    context, "/login", (route) => false);
              },
              leading: const Icon(Icons.logout_sharp),
              title: const Text("Log Out"),
              trailing: const Icon(Icons.arrow_forward_ios),
            ),
          ],
        ),
      );
    });
  }
}
