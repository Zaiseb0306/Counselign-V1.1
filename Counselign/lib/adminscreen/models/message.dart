class Message {
  final int id;
  final String senderName;
  final String senderEmail;
  final String subject;
  final String content;
  final bool isRead;
  final DateTime sentAt;
  final String? priority;

  Message({
    required this.id,
    required this.senderName,
    required this.senderEmail,
    required this.subject,
    required this.content,
    required this.isRead,
    required this.sentAt,
    this.priority,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] ?? 0,
      senderName: json['sender_name'] ?? '',
      senderEmail: json['sender_email'] ?? '',
      subject: json['subject'] ?? '',
      content: json['content'] ?? '',
      isRead: json['is_read'] == 1 || json['is_read'] == true,
      sentAt: json['sent_at'] != null
          ? DateTime.tryParse(json['sent_at']) ?? DateTime.now()
          : DateTime.now(),
      priority: json['priority'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sender_name': senderName,
      'sender_email': senderEmail,
      'subject': subject,
      'content': content,
      'is_read': isRead ? 1 : 0,
      'sent_at': sentAt.toIso8601String(),
      'priority': priority,
    };
  }

  Message copyWith({
    int? id,
    String? senderName,
    String? senderEmail,
    String? subject,
    String? content,
    bool? isRead,
    DateTime? sentAt,
    String? priority,
  }) {
    return Message(
      id: id ?? this.id,
      senderName: senderName ?? this.senderName,
      senderEmail: senderEmail ?? this.senderEmail,
      subject: subject ?? this.subject,
      content: content ?? this.content,
      isRead: isRead ?? this.isRead,
      sentAt: sentAt ?? this.sentAt,
      priority: priority ?? this.priority,
    );
  }
}