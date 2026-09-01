import 'package:flutter/material.dart';

import 'package:cordis/models/user_profile.dart';

class FriendsPage extends StatefulWidget {
  const FriendsPage({super.key});

  @override
  State<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  final _searchController = TextEditingController();
  String _searchText = '';

  static const _requests = [
    _FriendPerson(
      name: 'Maya Chen',
      handle: '@mayac',
      status: 'Wants to connect',
      isOnline: true,
      accentColor: Color(0xFF3D7C98),
    ),
    _FriendPerson(
      name: 'Jordan Lee',
      handle: '@jlee',
      status: 'Sent you a request',
      isOnline: false,
      accentColor: Color(0xFF98633D),
    ),
  ];

  static const _friends = [
    _FriendPerson(
      name: 'Ari Patel',
      handle: '@ari',
      status: 'Online',
      isOnline: true,
      accentColor: Color(0xFF7A1F2D),
    ),
    _FriendPerson(
      name: 'Sam Rivera',
      handle: '@samr',
      status: 'Studying cloud',
      isOnline: true,
      accentColor: Color(0xFF31785E),
    ),
    _FriendPerson(
      name: 'Noah Kim',
      handle: '@noahk',
      status: 'Away',
      isOnline: false,
      accentColor: Color(0xFF6750A4),
    ),
    _FriendPerson(
      name: 'Elena Torres',
      handle: '@elena',
      status: 'Building UI',
      isOnline: false,
      accentColor: Color(0xFF8A5A44),
    ),
  ];

  List<_FriendPerson> get _filteredFriends {
    final query = _searchText.trim().toLowerCase();

    if (query.isEmpty) {
      return _friends;
    }

    return _friends.where((friend) {
      return friend.name.toLowerCase().contains(query) ||
          friend.handle.toLowerCase().contains(query) ||
          friend.status.toLowerCase().contains(query);
    }).toList();
  }

  void _handleBottomNavigation(int index) {
    if (index == 0) {
      return;
    }

    if (index == 1) {
      Navigator.pushReplacementNamed(context, '/messages');
    } else if (index == 2) {
      Navigator.pushReplacementNamed(context, '/profile');
    }
  }

  void _showActionMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final filteredFriends = _filteredFriends;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Friends'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Add friend',
            icon: const Icon(Icons.person_add_alt_1_outlined),
            onPressed: () {
              _showActionMessage('Friend search coming soon');
            },
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            ValueListenableBuilder<UserProfile>(
              valueListenable: userProfileNotifier,
              builder: (context, profile, child) {
                return _FriendsSummary(profile: profile);
              },
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchText = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search friends',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchText.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Clear search',
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchText = '';
                          });
                        },
                      ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 18),
            _SectionHeader(title: 'Requests', trailing: '${_requests.length}'),
            const SizedBox(height: 10),
            for (final request in _requests)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _RequestTile(
                  person: request,
                  onAccept: () {
                    _showActionMessage('Request accepted');
                  },
                  onDismiss: () {
                    _showActionMessage('Request dismissed');
                  },
                ),
              ),
            const SizedBox(height: 8),
            _SectionHeader(
              title: 'All Friends',
              trailing: '${filteredFriends.length}',
            ),
            const SizedBox(height: 10),
            if (filteredFriends.isEmpty)
              _EmptyFriendsState(query: _searchText)
            else
              for (final friend in filteredFriends)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _FriendTile(
                    person: friend,
                    onMessage: () {
                      Navigator.pushReplacementNamed(context, '/messages');
                    },
                  ),
                ),
            const SizedBox(height: 4),
            Text(
              'Last synced just now',
              textAlign: TextAlign.center,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: _handleBottomNavigation,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Friends'),
          BottomNavigationBarItem(icon: Icon(Icons.message), label: 'Messages'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class _FriendsSummary extends StatelessWidget {
  const _FriendsSummary({required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: colorScheme.primary,
            child: Text(
              profile.initials,
              style: textTheme.titleMedium?.copyWith(
                color: colorScheme.onPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.displayName,
                  style: textTheme.titleMedium?.copyWith(
                    color: colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '2 online friends',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onPrimaryContainer.withValues(
                      alpha: 0.75,
                    ),
                  ),
                ),
              ],
            ),
          ),
          FilledButton.tonalIcon(
            onPressed: () {
              Navigator.pushNamed(context, '/profile');
            },
            icon: const Icon(Icons.person_outline),
            label: const Text('Profile'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.trailing});

  final String title;
  final String trailing;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: colorScheme.secondaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            trailing,
            style: textTheme.labelLarge?.copyWith(
              color: colorScheme.onSecondaryContainer,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _RequestTile extends StatelessWidget {
  const _RequestTile({
    required this.person,
    required this.onAccept,
    required this.onDismiss,
  });

  final _FriendPerson person;
  final VoidCallback onAccept;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return _PersonShell(
      person: person,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton.filledTonal(
            tooltip: 'Accept',
            onPressed: onAccept,
            icon: const Icon(Icons.check),
          ),
          const SizedBox(width: 6),
          IconButton(
            tooltip: 'Dismiss',
            onPressed: onDismiss,
            icon: Icon(Icons.close, color: colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _FriendTile extends StatelessWidget {
  const _FriendTile({required this.person, required this.onMessage});

  final _FriendPerson person;
  final VoidCallback onMessage;

  @override
  Widget build(BuildContext context) {
    return _PersonShell(
      person: person,
      child: IconButton(
        tooltip: 'Message',
        onPressed: onMessage,
        icon: const Icon(Icons.chat_bubble_outline),
      ),
    );
  }
}

class _PersonShell extends StatelessWidget {
  const _PersonShell({required this.person, required this.child});

  final _FriendPerson person;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: person.accentColor,
                child: Text(
                  person.initials,
                  style: textTheme.labelLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: person.isOnline
                        ? Colors.green.shade600
                        : colorScheme.outline,
                    shape: BoxShape.circle,
                    border: Border.all(color: colorScheme.surface, width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  person.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${person.handle} • ${person.status}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          child,
        ],
      ),
    );
  }
}

class _EmptyFriendsState extends StatelessWidget {
  const _EmptyFriendsState({required this.query});

  final String query;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(Icons.search_off, size: 34, color: colorScheme.onSurfaceVariant),
          const SizedBox(height: 8),
          Text(
            'No matches for "$query"',
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _FriendPerson {
  const _FriendPerson({
    required this.name,
    required this.handle,
    required this.status,
    required this.isOnline,
    required this.accentColor,
  });

  final String name;
  final String handle;
  final String status;
  final bool isOnline;
  final Color accentColor;

  String get initials {
    final parts = name.split(' ');

    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }

    return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'
        .toUpperCase();
  }
}
