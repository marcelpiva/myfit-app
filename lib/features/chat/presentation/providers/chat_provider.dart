import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/api_exceptions.dart';
import '../../../../core/services/chat_service.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

// Service provider
final chatServiceProvider = Provider<ChatService>((ref) {
  return ChatService();
});

// ==================== Conversation Model ====================

class Conversation {
  final String id;
  final String name;
  final String? avatarUrl;
  final String? lastMessage;
  final String? lastMessageTime;
  final int unreadCount;
  final bool isOnline;
  final String participantId;
  final String participantRole; // trainer, student, staff

  const Conversation({
    required this.id,
    required this.name,
    this.avatarUrl,
    this.lastMessage,
    this.lastMessageTime,
    this.unreadCount = 0,
    this.isOnline = false,
    required this.participantId,
    this.participantRole = 'student',
  });

  Conversation copyWith({
    String? id,
    String? name,
    String? avatarUrl,
    String? lastMessage,
    String? lastMessageTime,
    int? unreadCount,
    bool? isOnline,
    String? participantId,
    String? participantRole,
  }) {
    return Conversation(
      id: id ?? this.id,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      unreadCount: unreadCount ?? this.unreadCount,
      isOnline: isOnline ?? this.isOnline,
      participantId: participantId ?? this.participantId,
      participantRole: participantRole ?? this.participantRole,
    );
  }

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'] as String,
      name: json['name'] as String? ?? json['participant_name'] as String? ?? 'Conversa',
      avatarUrl: json['avatar_url'] as String? ?? json['participant_avatar'] as String?,
      lastMessage: json['last_message'] as String?,
      lastMessageTime: json['last_message_time'] as String?,
      unreadCount: json['unread_count'] as int? ?? 0,
      isOnline: json['is_online'] as bool? ?? false,
      participantId: json['participant_id'] as String? ?? '',
      participantRole: json['participant_role'] as String? ?? 'student',
    );
  }
}

// ==================== Message Model ====================

class ChatMessage {
  final String id;
  final String conversationId;
  final String senderId;
  final String text;
  final DateTime timestamp;
  final bool isFromMe;
  final bool isRead;
  final String? attachmentUrl;
  final String? attachmentType;

  const ChatMessage({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.text,
    required this.timestamp,
    this.isFromMe = false,
    this.isRead = false,
    this.attachmentUrl,
    this.attachmentType,
  });

  ChatMessage copyWith({
    String? id,
    String? conversationId,
    String? senderId,
    String? text,
    DateTime? timestamp,
    bool? isFromMe,
    bool? isRead,
    String? attachmentUrl,
    String? attachmentType,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      senderId: senderId ?? this.senderId,
      text: text ?? this.text,
      timestamp: timestamp ?? this.timestamp,
      isFromMe: isFromMe ?? this.isFromMe,
      isRead: isRead ?? this.isRead,
      attachmentUrl: attachmentUrl ?? this.attachmentUrl,
      attachmentType: attachmentType ?? this.attachmentType,
    );
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json, {String? currentUserId}) {
    final senderId = json['sender_id'] as String? ?? '';
    return ChatMessage(
      id: json['id'] as String,
      conversationId: json['conversation_id'] as String? ?? '',
      senderId: senderId,
      text: json['text'] as String? ?? json['content'] as String? ?? '',
      timestamp: DateTime.tryParse(json['timestamp'] as String? ?? json['created_at'] as String? ?? '') ?? DateTime.now(),
      isFromMe: currentUserId != null ? senderId == currentUserId : (json['is_from_me'] as bool? ?? false),
      isRead: json['is_read'] as bool? ?? false,
      attachmentUrl: json['attachment_url'] as String?,
      attachmentType: json['attachment_type'] as String?,
    );
  }
}

// ==================== Conversations State ====================

class ConversationsState {
  final List<Conversation> conversations;
  final bool isLoading;
  final String? error;

  const ConversationsState({
    this.conversations = const [],
    this.isLoading = false,
    this.error,
  });

  ConversationsState copyWith({
    List<Conversation>? conversations,
    bool? isLoading,
    String? error,
  }) {
    return ConversationsState(
      conversations: conversations ?? this.conversations,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  int get totalUnread => conversations.fold(0, (sum, c) => sum + c.unreadCount);
}

class ConversationsNotifier extends StateNotifier<ConversationsState> {
  final ChatService _chatService;

  ConversationsNotifier(this._chatService) : super(const ConversationsState()) {
    loadConversations();
  }

  Future<void> loadConversations() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final data = await _chatService.getConversations();
      final conversations = data.map((json) => Conversation.fromJson(json)).toList();
      state = state.copyWith(conversations: conversations, isLoading: false);
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Erro ao carregar conversas');
    }
  }

  void updateLastMessage(String conversationId, String message, String time) {
    state = state.copyWith(
      conversations: state.conversations.map((c) {
        if (c.id == conversationId) {
          return c.copyWith(lastMessage: message, lastMessageTime: time);
        }
        return c;
      }).toList(),
    );
  }

  void markAsRead(String conversationId) {
    state = state.copyWith(
      conversations: state.conversations.map((c) {
        if (c.id == conversationId) {
          return c.copyWith(unreadCount: 0);
        }
        return c;
      }).toList(),
    );
  }

  void incrementUnread(String conversationId) {
    state = state.copyWith(
      conversations: state.conversations.map((c) {
        if (c.id == conversationId) {
          return c.copyWith(unreadCount: c.unreadCount + 1);
        }
        return c;
      }).toList(),
    );
  }

  void refresh() => loadConversations();
}

final conversationsNotifierProvider =
    StateNotifierProvider<ConversationsNotifier, ConversationsState>((ref) {
  final chatService = ref.watch(chatServiceProvider);
  return ConversationsNotifier(chatService);
});

// Simple provider for backward compatibility
final conversationsProvider = Provider<List<Conversation>>((ref) {
  return ref.watch(conversationsNotifierProvider).conversations;
});

// ==================== Messages State ====================

class MessagesState {
  final List<ChatMessage> messages;
  final bool isLoading;
  final String? error;

  const MessagesState({
    this.messages = const [],
    this.isLoading = false,
    this.error,
  });

  MessagesState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    String? error,
  }) {
    return MessagesState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class MessagesNotifier extends StateNotifier<MessagesState> {
  final ChatService _chatService;
  final String conversationId;
  final String? currentUserId;

  MessagesNotifier(this._chatService, this.conversationId, this.currentUserId) : super(const MessagesState()) {
    loadMessages();
  }

  Future<void> loadMessages() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final data = await _chatService.getMessages(conversationId);
      final messages = data.map((json) => ChatMessage.fromJson(json, currentUserId: currentUserId)).toList();
      state = state.copyWith(messages: messages, isLoading: false);
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Erro ao carregar mensagens');
    }
  }

  Future<void> sendMessage(String text) async {
    // Optimistically add message to state
    final tempMessage = ChatMessage(
      id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
      conversationId: conversationId,
      senderId: currentUserId ?? 'me',
      text: text,
      timestamp: DateTime.now(),
      isFromMe: true,
    );
    state = state.copyWith(messages: [...state.messages, tempMessage]);

    try {
      final data = await _chatService.sendMessage(conversationId, text);
      // Replace temp message with real one from API
      final realMessage = ChatMessage.fromJson(data, currentUserId: currentUserId);
      state = state.copyWith(
        messages: state.messages.map((m) => m.id == tempMessage.id ? realMessage : m).toList(),
      );
    } catch (e) {
      // Remove temp message on failure
      state = state.copyWith(
        messages: state.messages.where((m) => m.id != tempMessage.id).toList(),
        error: 'Erro ao enviar mensagem',
      );
    }
  }

  void addMessage(ChatMessage message) {
    state = state.copyWith(messages: [...state.messages, message]);
  }

  void refresh() => loadMessages();
}

final messagesNotifierProvider =
    StateNotifierProvider.family<MessagesNotifier, MessagesState, String>((ref, conversationId) {
  final chatService = ref.watch(chatServiceProvider);
  final currentUser = ref.watch(currentUserProvider);
  return MessagesNotifier(chatService, conversationId, currentUser?.id);
});

// Simple provider for backward compatibility
final messagesProvider = Provider.family<List<ChatMessage>, String>((ref, conversationId) {
  return ref.watch(messagesNotifierProvider(conversationId)).messages;
});

// ==================== Active Conversation ====================

final activeConversationIdProvider = StateProvider<String?>((ref) => null);

final activeConversationProvider = Provider<Conversation?>((ref) {
  final id = ref.watch(activeConversationIdProvider);
  if (id == null) return null;

  final conversations = ref.watch(conversationsProvider);
  return conversations.where((c) => c.id == id).firstOrNull;
});

// ==================== Unread Count ====================

final totalUnreadCountProvider = Provider<int>((ref) {
  return ref.watch(conversationsNotifierProvider).totalUnread;
});

// ==================== Search ====================

final chatSearchQueryProvider = StateProvider<String>((ref) => '');

final filteredConversationsProvider = Provider<List<Conversation>>((ref) {
  final conversations = ref.watch(conversationsProvider);
  final query = ref.watch(chatSearchQueryProvider).toLowerCase();

  if (query.isEmpty) return conversations;

  return conversations.where((c) {
    return c.name.toLowerCase().contains(query) ||
        (c.lastMessage?.toLowerCase().contains(query) ?? false);
  }).toList();
});
