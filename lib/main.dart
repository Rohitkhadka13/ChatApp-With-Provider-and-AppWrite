import 'package:flutter/material.dart';
import 'controllers/appwrite_controllers.dart';
import 'controllers/local_saved_data.dart';
import 'providers/chat_provider.dart';
import 'providers/user_data_provider.dart';
import 'views/chat/chat_page_imports.dart';
import 'views/home/home_imports.dart';
import 'views/login/login_import.dart';
import 'views/profile/profile_import.dart';
import 'package:provider/provider.dart';

import 'views/search/search_import.dart';

final navigatorKey = GlobalKey<NavigatorState>();

class LifecycleEventHandler extends WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.resumed:
        updateOnlineStatus(
            userId: Provider.of<UserDataProvider>(navigatorKey.currentContext!,
                    listen: false)
                .getUserId,
            status: true);
      case AppLifecycleState.detached:
        updateOnlineStatus(
            userId: Provider.of<UserDataProvider>(navigatorKey.currentContext!,
                    listen: false)
                .getUserId,
            status: false);

      case AppLifecycleState.inactive:
        updateOnlineStatus(
            userId: Provider.of<UserDataProvider>(navigatorKey.currentContext!,
                    listen: false)
                .getUserId,
            status: false);
      case AppLifecycleState.hidden:
        updateOnlineStatus(
            userId: Provider.of<UserDataProvider>(navigatorKey.currentContext!,
                    listen: false)
                .getUserId,
            status: false);
      case AppLifecycleState.paused:
        updateOnlineStatus(
            userId: Provider.of<UserDataProvider>(navigatorKey.currentContext!,
                    listen: false)
                .getUserId,
            status: false);
    }
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  WidgetsBinding.instance.addObserver(LifecycleEventHandler());

  await LocalSavedData.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (context) => UserDataProvider(),
          ),
          ChangeNotifierProvider(
            create: (context) => ChatProvider(),
          ),
        ],
        child: MaterialApp(
          navigatorKey: navigatorKey,
          debugShowCheckedModeBanner: false,
          title: 'Chat App',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
            useMaterial3: true,
          ),
          routes: {
            "/": (context) => const CheckUserSession(),
            "/home": (context) => const HomeScreen(),
            "/login": (context) => const PhoneLogin(),
            "/chat": (context) => const ChatPage(),
            "/profile": (context) => const ProfilePage(),
            "/update": (context) => const UpdateProfile(),
            "/search": (context) => const SearchUser(),
          },
        ));
  }
}

class CheckUserSession extends StatefulWidget {
  const CheckUserSession({super.key});

  @override
  State<CheckUserSession> createState() => _CheckUserSessionState();
}

class _CheckUserSessionState extends State<CheckUserSession> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkSession());
  }

  // Async method to check session after loading local data
  Future<void> _checkSession() async {
    Provider.of<UserDataProvider>(context, listen: false).loadLocalData();

    final userName =
        Provider.of<UserDataProvider>(context, listen: false).getUserName;
    bool isSessionValid = await checkSession();

    if (isSessionValid) {
      if (userName != null && userName.isNotEmpty) {
        Navigator.pushNamedAndRemoveUntil(context, "/home", (route) => false);
      } else {
        Navigator.pushNamedAndRemoveUntil(context, "/update", (route) => false,
            arguments: {"title": "add"});
      }
    } else {
      Navigator.pushNamedAndRemoveUntil(context, "/login", (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
