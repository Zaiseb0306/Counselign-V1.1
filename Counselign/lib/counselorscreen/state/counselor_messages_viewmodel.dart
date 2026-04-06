import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/conversation.dart';
import '../models/counselor_message.dart';
import '../../api/config.dart';
import '../../utils/session.dart';

class CounselorMessagesViewModel extends ChangeNotifier {
  final Session _session = Session();

  // State variables
  List<Conversation> _conversations = [];
  List<CounselorMessage> _messages = [];
  String? _selectedUserId;
  String? _selectedUserName;
  String? _selectedUserAvatar;
  String? _selectedUserLastActivity;
  String? _selectedUserLastLogin;
  String? _selectedUserLogoutTime;
  bool _isLoadingConversations = false;
  bool _isLoadingMessages = false;
  String? _conversationsError;
  String? _messagesError;
  bool _isSearching = false;
  String _searchQuery = '';

  // Getters
  List<Conversation> get conversations => _conversations;
  List<CounselorMessage> get messages => _messages;
  String? get selectedUserId => _selectedUserId;
  String? get selectedUserName => _selectedUserName;
  String? get selectedUserAvatar => _selectedUserAvatar;
  String? get selectedUserLastActivity => _selectedUserLastActivity;
  String? get selectedUserLastLogin => _selectedUserLastLogin;
  String? get selectedUserLogoutTime => _selectedUserLogoutTime;
  bool get isLoadingConversations => _isLoadingConversations;
  bool get isLoadingMessages => _isLoadingMessages;
  String? get conversationsError => _conversationsError;
  String? get messagesError => _messagesError;
  bool get isSearching => _isSearching;
  String get searchQuery => _searchQuery;

  // Filtered conversations based on search
  List<Conversation> get filteredConversations {
    if (_searchQuery.isEmpty) return _conversations;
    return _conversations.where((conv) {
      final name = conv.userName.toLowerCase();
      final message = conv.lastMessage.toLowerCase();
      final query = _searchQuery.toLowerCase();
      return name.contains(query) || message.contains(query);
    }).toList();
  }

  // Initialize the viewmodel
  void initialize() {
    debugPrint('🔄 Initializing counselor messages viewmodel');
    loadConversations();
  }

  // Load conversations from backend
  Future<void> loadConversations() async {
    try {
      _isLoadingConversations = true;
      _conversationsError = null;
      notifyListeners();

      final url =
          '${ApiConfig.currentBaseUrl}/counselor/message/operations?action=get_conversations';
      debugPrint('🔍 Loading conversations from: $url');

      final response = await _session.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      debugPrint(
        '📡 Conversations API Response Status: ${response.statusCode}',
      );
      debugPrint('📡 Conversations API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        debugPrint('📊 Parsed conversations data: $data');

        if (data['success'] == true) {
          final conversationsList = data['conversations'] as List?;
          debugPrint('📋 Raw conversations list: $conversationsList');
          debugPrint(
            '📋 Conversations list type: ${conversationsList.runtimeType}',
          );
          debugPrint(
            '📋 Conversations list length: ${conversationsList?.length ?? 0}',
          );

          _conversations = [];
          if (conversationsList != null) {
            for (int i = 0; i < conversationsList.length; i++) {
              try {
                final conversation = Conversation.fromJson(
                  conversationsList[i],
                );
                _conversations.add(conversation);
              } catch (e) {
                debugPrint('❌ Error parsing conversation at index $i: $e');
                debugPrint('❌ Raw conversation data: ${conversationsList[i]}');
              }
            }
          }

          debugPrint(
            '✅ Successfully loaded ${_conversations.length} conversations',
          );
        } else {
          _conversationsError =
              data['message'] ?? 'Failed to load conversations';
          debugPrint('❌ API returned error: $_conversationsError');
        }
      } else {
        _conversationsError =
            'Failed to load conversations (HTTP ${response.statusCode})';
        debugPrint('❌ HTTP Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('💥 Exception loading conversations: $e');
      _conversationsError = 'Unable to load conversations: $e';
    } finally {
      _isLoadingConversations = false;
      notifyListeners();
    }
  }

  // Load messages for a specific user
  Future<void> loadMessages(String userId) async {
    try {
      _isLoadingMessages = true;
      _messagesError = null;
      notifyListeners();

      final url =
          '${ApiConfig.currentBaseUrl}/counselor/message/operations?action=get_messages&user_id=$userId';
      debugPrint('🔍 Loading messages from: $url');

      // Add timeout to prevent hanging
      final response = await _session
          .get(url, headers: {'Content-Type': 'application/json'})
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              debugPrint('⏰ Messages API request timed out');
              throw Exception('Request timed out');
            },
          );

      debugPrint('📡 Messages API Response Status: ${response.statusCode}');
      debugPrint('📡 Messages API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        debugPrint('📊 Parsed messages data: $data');

        if (data['success'] == true) {
          final messagesList = data['messages'] as List?;
          debugPrint('📋 Raw messages list: $messagesList');
          debugPrint('📋 Messages list type: ${messagesList.runtimeType}');
          debugPrint('📋 Messages list length: ${messagesList?.length ?? 0}');

          _messages = [];
          if (messagesList != null) {
            for (int i = 0; i < messagesList.length; i++) {
              try {
                final message = CounselorMessage.fromJson(messagesList[i]);
                _messages.add(message);
              } catch (e) {
                debugPrint('❌ Error parsing message at index $i: $e');
                debugPrint('❌ Raw message data: ${messagesList[i]}');
              }
            }
          }

          // Sort messages by timestamp
          _messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));

          debugPrint('✅ Successfully loaded ${_messages.length} messages');
        } else {
          _messagesError = data['message'] ?? 'Failed to load messages';
          debugPrint('❌ API returned error: $_messagesError');
        }
      } else {
        _messagesError =
            'Failed to load messages (HTTP ${response.statusCode})';
        debugPrint('❌ HTTP Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('💥 Exception loading messages: $e');
      _messagesError = 'Unable to load messages: $e';
    } finally {
      _isLoadingMessages = false;
      notifyListeners();
      debugPrint(
        '🔄 Loading messages completed. isLoadingMessages: $_isLoadingMessages',
      );
    }
  }

  // Select a conversation
  void selectConversation(String userId) {
    debugPrint('🔄 Selecting conversation for user: $userId');
    _selectedUserId = userId;

    // Find the conversation to get user details
    final conversation = _conversations.firstWhere(
      (conv) => conv.userId == userId,
      orElse: () => Conversation(
        userId: userId,
        userName: 'Unknown',
        lastMessage: '',
        lastMessageTime: '',
        lastMessageType: 'received',
        unreadCount: 0,
      ),
    );

    _selectedUserName = conversation.userName;
    _selectedUserAvatar = conversation.profilePicture;
    _selectedUserLastActivity = conversation.lastActivity;
    _selectedUserLastLogin = conversation.lastLogin;
    _selectedUserLogoutTime = conversation.logoutTime;

    // Load messages for this user
    loadMessages(userId);

    // Mark messages as read
    markMessagesAsRead(userId);

    notifyListeners();
  }

  // Send a message
  Future<bool> sendMessage(String messageText) async {
    if (_selectedUserId == null || messageText.trim().isEmpty) {
      return false;
    }

    try {
      debugPrint('📤 Sending message to $_selectedUserId: $messageText');

      final url =
          '${ApiConfig.currentBaseUrl}/counselor/message/operations?action=send_message';
      final response = await _session.post(
        url,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body:
            'receiver_id=$_selectedUserId&message=${Uri.encodeComponent(messageText)}',
      );

      debugPrint('📡 Send message API Response Status: ${response.statusCode}');
      debugPrint('📡 Send message API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          debugPrint('✅ Message sent successfully');
          // Reload messages to get the new message
          await loadMessages(_selectedUserId!);
          // Reload conversations to update the last message
          await loadConversations();
          return true;
        } else {
          debugPrint('❌ Failed to send message: ${data['message']}');
          return false;
        }
      } else {
        debugPrint('❌ HTTP Error sending message: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('💥 Exception sending message: $e');
      return false;
    }
  }

  // Mark messages as read
  Future<void> markMessagesAsRead(String userId) async {
    try {
      debugPrint('📖 Marking messages as read for user: $userId');

      final url = '${ApiConfig.currentBaseUrl}/counselor/message/operations';
      final response = await _session.post(
        url,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: 'action=mark_read&user_id=$userId',
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          debugPrint('✅ Messages marked as read');
          // Reload conversations to update unread counts
          await loadConversations();
        } else {
          debugPrint('❌ Failed to mark messages as read: ${data['message']}');
        }
      }
    } catch (e) {
      debugPrint('💥 Exception marking messages as read: $e');
    }
  }

  // Search conversations
  void searchConversations(String query) {
    _searchQuery = query;
    _isSearching = query.isNotEmpty;
    notifyListeners();
  }

  // Clear search
  void clearSearch() {
    _searchQuery = '';
    _isSearching = false;
    notifyListeners();
  }

  // Refresh data
  Future<void> refresh() async {
    await loadConversations();
    if (_selectedUserId != null) {
      await loadMessages(_selectedUserId!);
    }
  }

  // Force clear loading state (emergency fallback)
  void forceClearLoadingState() {
    debugPrint('🔄 Force clearing loading states');
    _isLoadingMessages = false;
    _isLoadingConversations = false;
    notifyListeners();
  }

  // Reset messages for current user
  void resetMessages() {
    debugPrint('🔄 Resetting messages for user: $_selectedUserId');
    _messages = [];
    _messagesError = null;
    _isLoadingMessages = false;
    notifyListeners();
  }
}
