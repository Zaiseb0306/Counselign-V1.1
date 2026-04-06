import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'state/student_dashboard_viewmodel.dart';
import 'models/counselor.dart';
import 'utils/image_url_helper.dart';
import 'widgets/navigation_drawer.dart';

class ConversationScreen extends StatelessWidget {
  const ConversationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Counselor? initialCounselor =
        ModalRoute.of(context)?.settings.arguments as Counselor?;
    return ChangeNotifierProvider(
      create: (context) {
        final viewModel = StudentDashboardViewModel();
        viewModel.initialize();
        if (initialCounselor != null) {
          viewModel.selectCounselor(initialCounselor);
        }
        return viewModel;
      },
      child: const _ConversationContent(),
    );
  }
}

class _ConversationContent extends StatelessWidget {
  const _ConversationContent();

  @override
  Widget build(BuildContext context) {
    return Consumer<StudentDashboardViewModel>(
      builder: (context, viewModel, child) {
        // Mark messages as read when conversation is opened
        if (viewModel.selectedCounselor != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            viewModel.markMessagesAsRead(
              viewModel.selectedCounselor!.counselorId,
            );
          });
        }

        return Stack(
          children: [
            Scaffold(
              backgroundColor: Colors.white,
              body: Column(
                children: [
                  _buildHeader(context, viewModel),
                  Expanded(child: _buildMessagesArea(context, viewModel)),
                  _buildInputArea(context, viewModel),
                ],
              ),
            ),
            if (viewModel.isDrawerOpen)
              GestureDetector(
                onTap: viewModel.closeDrawer,
                child: Container(
                  color: Colors.black.withAlpha(128),
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
            StudentNavigationDrawer(
              isOpen: viewModel.isDrawerOpen,
              onClose: viewModel.closeDrawer,
              onNavigateToAnnouncements: () =>
                  viewModel.navigateToAnnouncements(context),
              onNavigateToScheduleAppointment: () =>
                  viewModel.navigateToScheduleAppointment(context),
              onNavigateToMyAppointments: () =>
                  viewModel.navigateToMyAppointments(context),
              onNavigateToProfile: () => viewModel.navigateToProfile(context),
              onLogout: () => viewModel.logout(context),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHeader(
    BuildContext context,
    StudentDashboardViewModel viewModel,
  ) {
    final counselor = viewModel.selectedCounselor;
    return Container(
      padding: const EdgeInsets.fromLTRB(2, 48, 16, 2),
      decoration: BoxDecoration(
        color: const Color(0xFF191970),
        border: Border(bottom: BorderSide(color: Colors.grey[300]!, width: 1)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              } else {
                Navigator.of(
                  context,
                ).pushReplacementNamed('/student/counselor-selection');
              }
            },
          ),
          if (counselor != null)
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              child: ClipOval(child: _buildCounselorProfileImage(counselor)),
            ),
          const SizedBox(width: 5),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  counselor != null ? counselor.displayName : 'Messages',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                if (counselor != null)
                  Text(
                    counselor.onlineStatus.text,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 12,
                    ),
                  )
                else
                  Text(
                    'Select a conversation to start messaging',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesArea(
    BuildContext context,
    StudentDashboardViewModel viewModel,
  ) {
    if (viewModel.selectedCounselor == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No Messages Yet',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Select a conversation from the list to view messages.',
              style: TextStyle(color: Colors.grey[500], fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    if (viewModel.counselorMessages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No Messages Yet',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start the conversation by sending a message.',
              style: TextStyle(color: Colors.grey[500], fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: viewModel.chatScrollController,
      padding: const EdgeInsets.all(16),
      itemCount: viewModel.counselorMessages.length,
      itemBuilder: (context, index) {
        final message = viewModel.counselorMessages[index];
        return _MessageBubble(
          text: message.messageText,
          createdAt: viewModel.formatMessageTime(message.createdAt),
          isSent: message.isSent,
          senderName: message.senderName,
          senderProfilePicture: message.senderProfilePicture,
          counselorProfilePicture: viewModel.selectedCounselor?.profileImageUrl,
        );
      },
    );
  }

  Widget _buildInputArea(
    BuildContext context,
    StudentDashboardViewModel viewModel,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[300]!, width: 1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Material(
              child: TextField(
                controller: viewModel.messageController,
                enabled: viewModel.selectedCounselor != null,
                decoration: InputDecoration(
                  hintText: viewModel.selectedCounselor != null
                      ? 'Type your message...'
                      : 'Select a conversation to reply...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: const BorderSide(color: Color(0xFF191970)),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.send,
                autocorrect: false,
                enableSuggestions: false,
                spellCheckConfiguration:
                    const SpellCheckConfiguration.disabled(),
                onSubmitted: (value) {
                  if (value.trim().isNotEmpty &&
                      viewModel.selectedCounselor != null) {
                    viewModel.sendMessage(context);
                  }
                },
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: viewModel.selectedCounselor != null
                  ? const Color(0xFF191970)
                  : Colors.grey[400],
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed:
                  viewModel.isSendingMessage ||
                      viewModel.selectedCounselor == null
                  ? null
                  : () => viewModel.sendMessage(context),
              icon: viewModel.isSendingMessage
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.send, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCounselorProfileImage(Counselor counselor) {
    final imageUrl = ImageUrlHelper.getProfileImageUrl(
      counselor.profileImageUrl,
    );
    if (imageUrl == 'Photos/profile.png') {
      return Image.asset(
        'Photos/profile.png',
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.person, color: Colors.white, size: 20);
        },
      );
    }
    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return const Icon(Icons.person, color: Colors.white, size: 20);
      },
    );
  }
}

class _MessageBubble extends StatefulWidget {
  final String text;
  final String createdAt;
  final bool isSent;
  final String? senderName;
  final String? senderProfilePicture;
  final String? counselorProfilePicture;

  const _MessageBubble({
    required this.text,
    required this.createdAt,
    required this.isSent,
    required this.senderName,
    required this.senderProfilePicture,
    this.counselorProfilePicture,
  });

  @override
  State<_MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<_MessageBubble> {
  bool _showTimestamp = false;

  @override
  Widget build(BuildContext context) {
    final isSent = widget.isSent;
    final isTimeVisible = _showTimestamp;

    return Container(
      margin: const EdgeInsets.fromLTRB(0, 0, 0, 10),
      child: Column(
        crossAxisAlignment: isSent
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: isSent
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            children: [
              if (!isSent) ...[
                CircleAvatar(
                  radius: 16,
                  backgroundColor: const Color(
                    0xFF191970,
                  ).withValues(alpha: 0.1),
                  backgroundImage: widget.counselorProfilePicture != null
                      ? NetworkImage(
                          ImageUrlHelper.getProfileImageUrl(
                            widget.counselorProfilePicture!,
                          ),
                        )
                      : null,
                  child: widget.counselorProfilePicture == null
                      ? const Icon(
                          Icons.person,
                          color: Color(0xFF191970),
                          size: 16,
                        )
                      : null,
                ),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _showTimestamp = !_showTimestamp;
                    });
                  },
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.7,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: isSent
                          ? const Color(0xFF191970)
                          : Colors.grey[200],
                      borderRadius: BorderRadius.circular(20).copyWith(
                        bottomLeft: isSent
                            ? const Radius.circular(20)
                            : const Radius.circular(4),
                        bottomRight: isSent
                            ? const Radius.circular(4)
                            : const Radius.circular(20),
                      ),
                    ),
                    child: Text(
                      widget.text,
                      style: TextStyle(
                        color: isSent ? Colors.white : Colors.black87,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
              if (isSent) ...[
                const SizedBox(width: 8),
                CircleAvatar(
                  radius: 16,
                  backgroundColor: const Color(
                    0xFF191970,
                  ).withValues(alpha: 0.1),
                  child: const Icon(
                    Icons.person,
                    color: Color(0xFF191970),
                    size: 16,
                  ),
                ),
              ],
            ],
          ),
          if (isTimeVisible)
            Padding(
              padding: EdgeInsets.only(
                top: 4,
                left: isSent ? 0 : 40,
                right: isSent ? 40 : 0,
              ),
              child: Text(
                widget.createdAt,
                style: TextStyle(color: Colors.grey[600], fontSize: 10),
              ),
            ),
        ],
      ),
    );
  }
}
