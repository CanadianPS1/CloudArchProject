import 'package:flutter/material.dart';

class FriendsPage extends StatefulWidget {
  const FriendsPage({super.key});

  @override
  State<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Friends"),
      ),

      body: const SafeArea(
        child: Placeholder(),
      ),

      
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,

        onTap: (index) {
          if (index == 0) {
            
            return;
          } else if (index == 1) {
            Navigator.pushReplacementNamed(context, '/messages');
          } else if (index == 2) {
            Navigator.pushReplacementNamed(context, '/profile');
          }
        },

        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Friends',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            label: 'Messages',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
