class Message {
  final int id;
  final String senderId;
  final String senderName;
  final String receiverId;
  final String messageText;
  final bool isRead;
  final DateTime createdAt;
  final String? lastActivity;
  final String? lastLogin;
  final String? logoutTime;

  Message({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.receiverId,
    required this.messageText,
    required this.isRead,
    required this.createdAt,
    this.lastActivity,
    this.lastLogin,
    this.logoutTime,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] ?? 0,
      senderId: json['sender_id'] ?? '',
      senderName: json['sender_name'] ?? '',
      receiverId: json['receiver_id'] ?? '',
      messageText: json['message_text'] ?? '',
      isRead: json['is_read'] == 1 || json['is_read'] == true,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at']) ?? DateTime.now()
          : DateTime.now(),
      lastActivity: json['last_activity']?.toString(),
      lastLogin: json['last_login']?.toString(),
      logoutTime: json['logout_time']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sender_id': senderId,
      'sender_name': senderName,
      'receiver_id': receiverId,
      'message_text': messageText,
      'is_read': isRead ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'last_activity': lastActivity,
      'last_login': lastLogin,
      'logout_time': logoutTime,
    };
  }

  Message copyWith({
    int? id,
    String? senderId,
    String? senderName,
    String? receiverId,
    String? messageText,
    bool? isRead,
    DateTime? createdAt,
    String? lastActivity,
    String? lastLogin,
    String? logoutTime,
  }) {
    return Message(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      receiverId: receiverId ?? this.receiverId,
      messageText: messageText ?? this.messageText,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      lastActivity: lastActivity ?? this.lastActivity,
      lastLogin: lastLogin ?? this.lastLogin,
      logoutTime: logoutTime ?? this.logoutTime,
    );
  }
}
