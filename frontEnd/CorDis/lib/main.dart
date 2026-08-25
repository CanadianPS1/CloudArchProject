import 'package:flutter/material.dart';

import 'package:cordis/views/login_page.dart';
import 'package:cordis/views/signup_page.dart';
import 'package:cordis/views/friends_page.dart';
import 'package:cordis/views/messages_page.dart';
import 'package:cordis/views/profile_view_page.dart';
import 'package:cordis/views/settings_page.dart';

void main() {
  runApp(const MyApp());
}

const _wineAccent = Color(0xFF7A1F2D);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CorDis',

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: _wineAccent),
        useMaterial3: true,
      ),

      initialRoute: '/login',

      routes: {
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignupPage(),

        // treating friends as the main/home page
        '/home': (context) => const FriendsPage(),
        '/friends': (context) => const FriendsPage(),

        '/messages': (context) => const MessagesPage(),
        '/profile': (context) => const ProfileViewPage(),
        '/settings': (context) => const SettingsPage(),
      },
    );
  }
}
