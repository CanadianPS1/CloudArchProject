import 'package:flutter/foundation.dart';

class UserProfile {
  const UserProfile({
    required this.displayName,
    required this.handle,
    required this.bio,
    required this.status,
    required this.memberSince,
    required this.interests,
  });

  final String displayName;
  final String handle;
  final String bio;
  final String status;
  final String memberSince;
  final List<String> interests;

  String get initials {
    final parts = displayName
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();

    if (parts.isEmpty) {
      return 'UN';
    }

    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }

    return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'
        .toUpperCase();
  }

  UserProfile copyWith({
    String? displayName,
    String? handle,
    String? bio,
    String? status,
    String? memberSince,
    List<String>? interests,
  }) {
    return UserProfile(
      displayName: displayName ?? this.displayName,
      handle: handle ?? this.handle,
      bio: bio ?? this.bio,
      status: status ?? this.status,
      memberSince: memberSince ?? this.memberSince,
      interests: interests ?? this.interests,
    );
  }
}

//test user data so we dont gotta restart yay
final userProfileNotifier = ValueNotifier<UserProfile>(
  const UserProfile(
    displayName: 'UserName',
    handle: '@username',
    bio: 'mow mow',
    status:
        'Active', //not real... sadly we can delete this after i just want to be happy for now
    memberSince: '2026',
    interests: ['Sleep'],
  ),
);
