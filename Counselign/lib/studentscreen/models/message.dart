class Message {
  final int id;
  final String senderId;
  final String receiverId;
  final String messageText;
  final DateTime createdAt;
  final String? senderName;
  final String? senderProfilePicture;
  late bool _isSent;

  Message({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.messageText,
    required this.createdAt,
    this.senderName,
    this.senderProfilePicture,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: _parseInt(json['message_id'] ?? json['id']) ?? 0,
      senderId: json['sender_id']?.toString() ?? '',
      receiverId: json['receiver_id']?.toString() ?? '',
      messageText: json['message_text'] ?? json['message'] ?? '',
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      senderName: json['sender_name'] ?? json['counselor_name'],
      senderProfilePicture:
          json['sender_profile_picture'] ?? json['counselor_profile_picture'],
    );
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

  void setCurrentUser(String currentUserId) {
    _isSent = senderId == currentUserId;
  }

  bool get isSent => _isSent;
  bool get isReceived => !_isSent;
}
