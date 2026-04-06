import 'package:flutter/material.dart';
import '../state/student_dashboard_viewmodel.dart';
import '../../api/config.dart';
import '../utils/image_url_helper.dart';
import '../models/counselor.dart';

class StudentChatPopup extends StatelessWidget {
  final StudentDashboardViewModel viewModel;
  final VoidCallback onSendMessage;

  const StudentChatPopup({
    super.key,
    required this.viewModel,
    required this.onSendMessage,
  });

  @override
  Widget build(BuildContext context) {
    // Don't show chat if no counselor is selected
    if (viewModel.selectedCounselor == null) {
      return const SizedBox.shrink();
    }

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        width: MediaQuery.of(context).size.width > 480
            ? 380
            : MediaQuery.of(context).size.width - 40,
        height: 500,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha((0.15 * 255).round()),
              blurRadius: 40,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [Color(0xFF060E57), Color(0xFF0A1875)],
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  // Counselor profile picture
                  if (viewModel.selectedCounselor != null)
                    Container(
                      width: 40,
                      height: 40,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                          width: 2,
                        ),
                      ),
                      child: ClipOval(
                        child: _buildCounselorProfileImage(
                          viewModel.selectedCounselor!,
                        ),
                      ),
                    ),

                  // Message icon and text
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            viewModel.selectedCounselor != null
                                ? 'Counselor: ${viewModel.selectedCounselor!.displayName}'
                                : 'Send a message to your Counselor',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.left,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Close button
                  IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 20,
                    ),
                    onPressed: viewModel.closeChat,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),

            // Messages area
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(20),
                color: const Color(0xFFF8FAFD),
                child: Column(
                  children: [
                    // Privacy notice
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: const Color(
                          0xFF060E57,
                        ).withAlpha((0.05 * 255).round()),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(
                            0xFF060E57,
                          ).withAlpha((0.08 * 255).round()),
                          width: 1,
                        ),
                      ),
                      child: const Text(
                        'Your conversation is private and confidential',
                        style: TextStyle(
                          color: Color(0xFF666666),
                          fontSize: 13,
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    // Messages list
                    Expanded(
                      child: viewModel.counselorMessages.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.chat_bubble_outline,
                                    color: Color(0xFF666666),
                                    size: 48,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    viewModel.selectedCounselor != null
                                        ? 'Start a conversation with ${viewModel.selectedCounselor!.displayName}'
                                        : 'Select a counselor to start messaging',
                                    style: const TextStyle(
                                      color: Color(0xFF666666),
                                      fontSize: 14,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              controller: viewModel.chatScrollController,
                              reverse: false,
                              itemCount: viewModel.counselorMessages.length,
                              itemBuilder: (context, index) {
                                final message =
                                    viewModel.counselorMessages[index];
                                return _buildMessageBubble(message);
                              },
                            ),
                    ),

                    // Typing indicator
                    if (viewModel.isTyping)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        margin: const EdgeInsets.only(top: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha((0.04 * 255).round()),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              margin: const EdgeInsets.symmetric(horizontal: 2),
                              decoration: const BoxDecoration(
                                color: Color(0xFF060E57),
                                shape: BoxShape.circle,
                              ),
                            ),
                            Container(
                              width: 6,
                              height: 6,
                              margin: const EdgeInsets.symmetric(horizontal: 2),
                              decoration: const BoxDecoration(
                                color: Color(0xFF060E57),
                                shape: BoxShape.circle,
                              ),
                            ),
                            Container(
                              width: 6,
                              height: 6,
                              margin: const EdgeInsets.symmetric(horizontal: 2),
                              decoration: const BoxDecoration(
                                color: Color(0xFF060E57),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Input area
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(
                    color: Colors.black.withAlpha((0.06 * 255).round()),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Text input
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFD),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: const Color(0xFFE4E6EB),
                          width: 1,
                        ),
                      ),
                      child: TextField(
                        controller: viewModel.messageController,
                        decoration: const InputDecoration(
                          hintText: 'Type your message here...',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 10),
                          alignLabelWithHint: true,
                        ),
                        maxLines: 3,
                        minLines: 1,
                        textAlign: TextAlign.center,
                        onSubmitted: (_) => onSendMessage(),
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  // Send button
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFF060E57),
                      borderRadius: BorderRadius.circular(50),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(
                            0xFF060E57,
                          ).withAlpha((0.08 * 255).round()),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: viewModel.isSendingMessage
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(
                              Icons.send,
                              color: Colors.white,
                              size: 18,
                            ),
                      onPressed: viewModel.isSendingMessage
                          ? null
                          : onSendMessage,
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(dynamic message) {
    final isSent = message.isSent;
    final alignment = isSent
        ? CrossAxisAlignment.end
        : CrossAxisAlignment.start;
    final margin = isSent
        ? const EdgeInsets.only(left: 60, bottom: 8)
        : const EdgeInsets.only(right: 60, bottom: 8);

    return Container(
      margin: margin,
      child: Column(
        crossAxisAlignment: alignment,
        children: [
          // Sender info for received messages
          if (!isSent && message.senderName != null)
            Container(
              margin: const EdgeInsets.only(bottom: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (message.senderProfilePicture != null)
                    Container(
                      width: 20,
                      height: 20,
                      margin: const EdgeInsets.only(right: 6),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFE4E6EB),
                          width: 1,
                        ),
                      ),
                      child: ClipOval(
                        child: _buildSenderImage(message.senderProfilePicture!),
                      ),
                    ),
                  Text(
                    message.senderName!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSent ? const Color(0xFF060E57) : Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(18),
                topRight: const Radius.circular(18),
                bottomLeft: isSent
                    ? const Radius.circular(18)
                    : const Radius.circular(4),
                bottomRight: isSent
                    ? const Radius.circular(4)
                    : const Radius.circular(18),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha((0.06 * 255).round()),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  message.messageText,
                  style: TextStyle(
                    color: isSent ? Colors.white : const Color(0xFF1A1A1A),
                    fontSize: 14,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  viewModel.formatMessageTime(message.createdAt),
                  style: TextStyle(
                    color: isSent
                        ? Colors.white.withAlpha((0.7 * 255).round())
                        : const Color(0xFF666666),
                    fontSize: 11,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSenderImage(String profilePicture) {
    final imageUrl = ImageUrlHelper.getProfileImageUrl(profilePicture);

    // If it's the default profile image, use asset
    if (imageUrl == 'Photos/profile.png') {
      return Image.asset(
        'Photos/profile.png',
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.person, color: Color(0xFF64748B), size: 12);
        },
      );
    }

    // Otherwise, use network image
    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return const Icon(Icons.person, color: Color(0xFF64748B), size: 12);
      },
    );
  }

  Widget _buildCounselorProfileImage(Counselor counselor) {
    final imageUrl = ImageUrlHelper.getProfileImageUrl(
      counselor.profileImageUrl,
    );

    // If it's the default profile image, use asset
    if (imageUrl == 'Photos/profile.png') {
      return Image.asset(
        'Photos/profile.png',
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.person, color: Colors.white, size: 20);
        },
      );
    }

    // Otherwise, use network image
    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return const Icon(Icons.person, color: Colors.white, size: 20);
      },
    );
  }
}
