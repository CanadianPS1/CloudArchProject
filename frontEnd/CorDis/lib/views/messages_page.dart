import 'package:flutter/material.dart';

class MessagesPage extends StatefulWidget {
  const MessagesPage({super.key});

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  final _searchController = TextEditingController();
  final _messageController = TextEditingController();
  final Map<int, List<_ChatMessage>> _localMessages = {};
  int _selectedConversationId = _conversations.first.id;
  String _searchText = '';

  static const _conversations = [
    _Conversation(
      id: 1,
      name: 'Ari Patel',
      handle: '@ari',
      preview: 'I pushed the notes into the shared doc.',
      time: '2m',
      unreadCount: 2,
      accentColor: Color(0xFF7A1F2D),
      messages: [
        _ChatMessage(
          text: 'Are we still meeting after class?',
          time: '1:18 PM',
          isMine: false,
        ),
        _ChatMessage(
          text: 'Yep, I can hop on in ten.',
          time: '1:20 PM',
          isMine: true,
        ),
        _ChatMessage(
          text: 'I pushed the notes into the shared doc.',
          time: '1:24 PM',
          isMine: false,
        ),
      ],
    ),
    _Conversation(
      id: 2,
      name: 'Cloud Crew',
      handle: '4 members',
      preview: 'Jordan: The endpoint is finally green.',
      time: '18m',
      unreadCount: 0,
      accentColor: Color(0xFF31785E),
      messages: [
        _ChatMessage(
          text: 'The endpoint is finally green.',
          time: '12:51 PM',
          isMine: false,
        ),
        _ChatMessage(
          text: 'Amazing, I can wire the screen around that.',
          time: '12:56 PM',
          isMine: true,
        ),
      ],
    ),
    _Conversation(
      id: 3,
      name: 'Sam Rivera',
      handle: '@samr',
      preview: 'Can you look at the layout later?',
      time: '1h',
      unreadCount: 1,
      accentColor: Color(0xFF3D7C98),
      messages: [
        _ChatMessage(
          text: 'Can you look at the layout later?',
          time: '12:08 PM',
          isMine: false,
        ),
      ],
    ),
    _Conversation(
      id: 4,
      name: 'Elena Torres',
      handle: '@elena',
      preview: 'The profile page looks so much better.',
      time: 'Yesterday',
      unreadCount: 0,
      accentColor: Color(0xFF98633D),
      messages: [
        _ChatMessage(
          text: 'The profile page looks so much better.',
          time: 'Yesterday',
          isMine: false,
        ),
        _ChatMessage(
          text: 'Thank you, the wine accent helped a lot.',
          time: 'Yesterday',
          isMine: true,
        ),
      ],
    ),
  ];

  List<_Conversation> get _filteredConversations {
    final query = _searchText.trim().toLowerCase();

    if (query.isEmpty) {
      return _conversations;
    }

    return _conversations.where((conversation) {
      return conversation.name.toLowerCase().contains(query) ||
          conversation.handle.toLowerCase().contains(query) ||
          conversation.preview.toLowerCase().contains(query);
    }).toList();
  }

  _Conversation get _selectedConversation {
    return _conversations.firstWhere(
      (conversation) => conversation.id == _selectedConversationId,
      orElse: () => _conversations.first,
    );
  }

  List<_ChatMessage> _messagesFor(_Conversation conversation) {
    return [...conversation.messages, ...?_localMessages[conversation.id]];
  }

  void _handleBottomNavigation(int index) {
    if (index == 0) {
      Navigator.pushReplacementNamed(context, '/friends');
    } else if (index == 1) {
      return;
    } else if (index == 2) {
      Navigator.pushReplacementNamed(context, '/profile');
    }
  }

  void _selectConversation(_Conversation conversation) {
    setState(() {
      _selectedConversationId = conversation.id;
      _messageController.clear();
    });
  }

  void _sendDraft(_Conversation conversation) {
    final message = _messageController.text.trim();

    if (message.isEmpty) {
      return;
    }

    setState(() {
      _localMessages.update(
        conversation.id,
        (messages) => [
          ...messages,
          _ChatMessage(text: message, time: 'Now', isMine: true),
        ],
        ifAbsent: () => [
          _ChatMessage(text: message, time: 'Now', isMine: true),
        ],
      );
      _messageController.clear();
    });
  }

  void _openMobileConversation(_Conversation conversation) {
    _selectConversation(conversation);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            ),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.72,
              child: _ConversationDetail(
                conversation: conversation,
                messages: _messagesFor(conversation),
                controller: _messageController,
                onSend: () {
                  _sendDraft(conversation);
                  Navigator.pop(context);
                },
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isWide = MediaQuery.of(context).size.width >= 760;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Messages'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'New message',
            icon: const Icon(Icons.edit_square),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('New message started')),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: isWide
              ? Row(
                  children: [
                    SizedBox(width: 330, child: _buildConversationList()),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _ConversationDetail(
                        conversation: _selectedConversation,
                        messages: _messagesFor(_selectedConversation),
                        controller: _messageController,
                        onSend: () {
                          _sendDraft(_selectedConversation);
                        },
                      ),
                    ),
                  ],
                )
              : _buildConversationList(),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        onTap: _handleBottomNavigation,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Friends'),
          BottomNavigationBarItem(icon: Icon(Icons.message), label: 'Messages'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildConversationList() {
    final filteredConversations = _filteredConversations;

    return ListView(
      children: [
        TextField(
          controller: _searchController,
          onChanged: (value) {
            setState(() {
              _searchText = value;
            });
          },
          decoration: InputDecoration(
            hintText: 'Search messages',
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
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        const SizedBox(height: 14),
        for (final conversation in filteredConversations)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _ConversationTile(
              conversation: conversation,
              isSelected: conversation.id == _selectedConversationId,
              onTap: () {
                if (MediaQuery.of(context).size.width >= 760) {
                  _selectConversation(conversation);
                } else {
                  _openMobileConversation(conversation);
                }
              },
            ),
          ),
        if (filteredConversations.isEmpty)
          _EmptyMessagesState(query: _searchText),
      ],
    );
  }
}

class _ConversationTile extends StatelessWidget {
  const _ConversationTile({
    required this.conversation,
    required this.isSelected,
    required this.onTap,
  });

  final _Conversation conversation;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: isSelected ? colorScheme.primaryContainer : colorScheme.surface,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected
                  ? colorScheme.primary.withValues(alpha: 0.35)
                  : colorScheme.outlineVariant,
            ),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: conversation.accentColor,
                child: Text(
                  conversation.initials,
                  style: textTheme.labelLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            conversation.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        Text(
                          conversation.time,
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      conversation.preview,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (conversation.unreadCount > 0) ...[
                const SizedBox(width: 8),
                Container(
                  width: 24,
                  height: 24,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${conversation.unreadCount}',
                    style: textTheme.labelSmall?.copyWith(
                      color: colorScheme.onPrimary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ConversationDetail extends StatelessWidget {
  const _ConversationDetail({
    required this.conversation,
    required this.messages,
    required this.controller,
    required this.onSend,
  });

  final _Conversation conversation;
  final List<_ChatMessage> messages;
  final TextEditingController controller;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: conversation.accentColor,
                  child: Text(
                    conversation.initials,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        conversation.name,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        conversation.handle,
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Call',
                  icon: const Icon(Icons.call_outlined),
                  onPressed: () {},
                ),
              ],
            ),
          ),
          Divider(height: 1, color: colorScheme.outlineVariant),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(14),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return _MessageBubble(message: messages[index]);
              },
            ),
          ),
          Divider(height: 1, color: colorScheme.outlineVariant),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    minLines: 1,
                    maxLines: 4,
                    onSubmitted: (_) {
                      onSend();
                    },
                    decoration: InputDecoration(
                      hintText: 'Message ${conversation.name}',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  tooltip: 'Send',
                  onPressed: onSend,
                  icon: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});

  final _ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Align(
      alignment: message.isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: message.isMine
              ? colorScheme.primary
              : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: message.isMine
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Text(
              message.text,
              style: textTheme.bodyMedium?.copyWith(
                color: message.isMine
                    ? colorScheme.onPrimary
                    : colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              message.time,
              style: textTheme.labelSmall?.copyWith(
                color: message.isMine
                    ? colorScheme.onPrimary.withValues(alpha: 0.72)
                    : colorScheme.onSurfaceVariant.withValues(alpha: 0.72),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyMessagesState extends StatelessWidget {
  const _EmptyMessagesState({required this.query});

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
          Icon(
            Icons.mark_chat_unread_outlined,
            size: 34,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 8),
          Text(
            'No messages for "$query"',
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

class _Conversation {
  const _Conversation({
    required this.id,
    required this.name,
    required this.handle,
    required this.preview,
    required this.time,
    required this.unreadCount,
    required this.accentColor,
    required this.messages,
  });

  final int id;
  final String name;
  final String handle;
  final String preview;
  final String time;
  final int unreadCount;
  final Color accentColor;
  final List<_ChatMessage> messages;

  String get initials {
    final cleanName = name.replaceAll(RegExp(r'[^A-Za-z ]'), '').trim();
    final parts = cleanName.split(RegExp(r'\s+'));

    if (parts.isEmpty || parts.first.isEmpty) {
      return '?';
    }

    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }

    return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'
        .toUpperCase();
  }
}

class _ChatMessage {
  const _ChatMessage({
    required this.text,
    required this.time,
    required this.isMine,
  });

  final String text;
  final String time;
  final bool isMine;
}
