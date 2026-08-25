import 'package:flutter/material.dart';

import 'package:cordis/models/user_profile.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _displayNameController = TextEditingController();
  final _handleController = TextEditingController();
  final _bioController = TextEditingController();
  final _statusController = TextEditingController();
  final _interestsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final profile = userProfileNotifier.value;

    _displayNameController.text = profile.displayName;
    _handleController.text = profile.handle;
    _bioController.text = profile.bio;
    _statusController.text = profile.status;
    _interestsController.text = profile.interests.join(', ');
  }

  void _handleSaveProfile() {
    final currentProfile = userProfileNotifier.value;
    final interests = _interestsController.text
        .split(',')
        .map((interest) => interest.trim())
        .where((interest) => interest.isNotEmpty)
        .toList();

    userProfileNotifier.value = currentProfile.copyWith(
      displayName: _fallbackText(
        _displayNameController.text,
        currentProfile.displayName,
      ),
      handle: _formatHandle(_handleController.text),
      bio: _fallbackText(_bioController.text, currentProfile.bio),
      status: _fallbackText(_statusController.text, currentProfile.status),
      interests: interests,
    );

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Profile updated')));
  }

  String _fallbackText(String value, String fallback) {
    final trimmedValue = value.trim();

    if (trimmedValue.isEmpty) {
      return fallback;
    }

    return trimmedValue;
  }

  String _formatHandle(String value) {
    final cleanHandle = value
        .trim()
        .replaceFirst(RegExp(r'^@+'), '')
        .replaceAll(RegExp(r'\s+'), '');

    if (cleanHandle.isEmpty) {
      return userProfileNotifier.value.handle;
    }

    return '@$cleanHandle';
  }

  void _handleLogout() {
    _showConfirmDialog(
      context: context,
      message:
          "Logging out will remove your current sign in and send you back to the login screen.",
      confirmationMessage: "log me out",
      onConfirm: () {
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('/login', (route) => false);
      },
    );
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _handleController.dispose();
    _bioController.dispose();
    _statusController.dispose();
    _interestsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings"), centerTitle: true),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Profile',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _displayNameController,
              decoration: const InputDecoration(
                labelText: 'Display name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _handleController,
              decoration: const InputDecoration(
                labelText: 'Handle',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _bioController,
              minLines: 3,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Bio',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _statusController,
              decoration: const InputDecoration(
                labelText: 'Status',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _interestsController,
              decoration: const InputDecoration(
                labelText: 'Interests',
                hintText: 'Study, Music, Gaming',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _handleSaveProfile,
              icon: const Icon(Icons.save_outlined),
              label: const Text('Save Profile'),
            ),
            const SizedBox(height: 28),
            Text(
              'Account',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () {
                _showPasswordDialog(context);
              },
              icon: const Icon(Icons.lock_outline),
              label: const Text("Change Password"),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _handleLogout,
              icon: const Icon(Icons.logout),
              label: const Text("Log Out"),
            ),
            const SizedBox(height: 8),
            FilledButton.tonalIcon(
              onPressed: () {
                _showConfirmDialog(
                  context: context,
                  message:
                      "This will permanently delete your account. This CANNOT be recovered",
                  confirmationMessage: "delete my account",
                );
              },
              icon: const Icon(Icons.delete_outline),
              label: const Text("Delete Account"),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showConfirmDialog({
    required BuildContext context,
    required String message,
    required String confirmationMessage,
    VoidCallback? onConfirm,
  }) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Are you sure?'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(dialogContext).textTheme.labelLarge,
              ),
              child: Text("Yes, $confirmationMessage"),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                onConfirm?.call();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(dialogContext).textTheme.labelLarge,
              ),
              child: const Text('No'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showPasswordDialog(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Update Password'),
          content: Form(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Old Password'),
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'New Password'),
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Repeat New Password',
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text("Update"),
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
