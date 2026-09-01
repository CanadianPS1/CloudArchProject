import 'package:flutter/material.dart';

import 'package:cordis/models/user_profile.dart';
import 'package:cordis/services/api_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _apiService = ApiService.instance;
  bool _isSubmitting = false;

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate() || _isSubmitting) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final result = await _apiService.loginUser(
        emailOrUsername: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) {
        return;
      }

      userProfileNotifier.value = UserProfile(
        displayName: _displayNameFor(result.user),
        handle: _handleFor(result.user),
        bio: _profileText(result.user.bio, 'No bio yet.'),
        status: _formatStatus(result.user.status),
        memberSince: _memberSince(result.user.createdAt),
        interests: const [],
      );

      Navigator.pushReplacementNamed(context, '/home');
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }

      _showLoginError(error.message);
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  String _displayNameFor(BackendUser user) {
    final username = user.username.trim();

    if (username.isNotEmpty) {
      return username;
    }

    final emailName = user.email.trim().split('@').first;

    if (emailName.isNotEmpty) {
      return emailName;
    }

    return 'User';
  }

  String _handleFor(BackendUser user) {
    final rawHandle = user.username.trim().isNotEmpty
        ? user.username
        : user.email.trim().split('@').first;
    final cleanHandle = rawHandle
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9_]+'), '')
        .trim();

    if (cleanHandle.isEmpty) {
      return '@user';
    }

    return '@$cleanHandle';
  }

  String _profileText(String? value, String fallback) {
    final trimmedValue = value?.trim() ?? '';

    if (trimmedValue.isEmpty) {
      return fallback;
    }

    return trimmedValue;
  }

  String _formatStatus(String status) {
    final trimmedStatus = status.trim();

    if (trimmedStatus.isEmpty) {
      return 'Active';
    }

    return '${trimmedStatus.substring(0, 1).toUpperCase()}'
        '${trimmedStatus.substring(1)}';
  }

  String _memberSince(String? createdAt) {
    final rawDate = createdAt?.trim() ?? '';

    if (rawDate.isEmpty) {
      return 'Now';
    }

    final normalizedDate = rawDate.replaceFirst(' ', 'T');
    final parsedDate = DateTime.tryParse(normalizedDate);

    if (parsedDate != null) {
      return parsedDate.year.toString();
    }

    final yearMatch = RegExp(r'^\d{4}').firstMatch(rawDate);
    return yearMatch?.group(0) ?? 'Now';
  }

  void _showLoginError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Log In')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(
                  labelText: 'Email or username',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email or username';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _handleLogin,
                child: _isSubmitting
                    ? const SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Log In'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/signup');
                },
                child: const Text("Don't have an account? Sign Up"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
