import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Settings"), centerTitle: true),
      body: SafeArea(
        child: Center(
          child: Form(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                spacing: 12,
                children: [
                  TextFormField(
                    decoration: InputDecoration(labelText: 'UserName'),
                  ),
                  TextFormField(decoration: InputDecoration(labelText: 'Bio')),
                  ElevatedButton(
                    onPressed: () {
                      _PasswordBuilder(context);
                    },
                    child: Text("Change Password"),
                    style: ButtonStyle(),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _ConfirmBuilder(
                        context,
                        "Logging out will remove your current sign in and send you back to the login screen.",
                        "log me out",
                      );
                    },
                    child: Text("Log Out"),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _ConfirmBuilder(
                        context,
                        "This will permentantly delete your account. This CANNOT be recovered",
                        "delete my account",
                      );
                    },
                    child: Text("Delete Account"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _ConfirmBuilder(
    BuildContext context,
    String message,
    String confirmationMessage,
  ) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Are you sure?'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: Text("Yes, ${confirmationMessage}"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('No'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _PasswordBuilder(
      BuildContext context
      ) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Update Password'),
          content: Form(child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(decoration: InputDecoration(labelText: 'Old Password'),),
              TextFormField(decoration: InputDecoration(labelText: 'New Password'),),
              TextFormField(decoration: InputDecoration(labelText: 'Repeat New Password'),)
            ],
          )),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: Text("Update"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
