import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'widgets/navigation_drawer.dart';
import 'widgets/notifications_dropdown.dart';
import '../../widgets/app_header.dart';
import '../widgets/bottom_navigation_bar.dart';
import 'state/student_dashboard_viewmodel.dart';
import 'models/counselor.dart';
import 'utils/image_url_helper.dart';
import '../../utils/online_status.dart';
import 'models/message.dart';

class CounselorSelectionScreen extends StatelessWidget {
  const CounselorSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) {
        final viewModel = StudentDashboardViewModel();
        viewModel.initialize();
        return viewModel;
      },
      child: const _CounselorSelectionContent(),
    );
  }
}

class _CounselorSelectionContent extends StatefulWidget {
  const _CounselorSelectionContent();

  @override
  State<_CounselorSelectionContent> createState() =>
      _CounselorSelectionContentState();
}

class _CounselorSelectionContentState
    extends State<_CounselorSelectionContent> {
  String _query = '';
  final TextEditingController _searchController = TextEditingController();
  bool _loadedMessages = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<StudentDashboardViewModel>(
      builder: (context, viewModel, child) {
        if (!_loadedMessages) {
          _loadedMessages = true;
          // Load messages once so we can show latest message per counselor
          viewModel.loadMessages();
        }
        final Map<String, _LatestMeta> latestByCounselor =
            _computeLatestByCounselor(viewModel.messages);
        final List<Counselor> list = _filterCounselors(viewModel.counselors);
        final List<Counselor> sorted = List<Counselor>.from(list)
          ..sort((a, b) {
            // Online first
            final aOnline =
                a.onlineStatus.statusClass == OnlineStatus.statusOnline ? 1 : 0;
            final bOnline =
                b.onlineStatus.statusClass == OnlineStatus.statusOnline ? 1 : 0;
            if (aOnline != bOnline) return bOnline.compareTo(aOnline);
            // Then by latest message datetime desc
            final aMeta = latestByCounselor[a.counselorId];
            final bMeta = latestByCounselor[b.counselorId];
            final aTime = aMeta?.createdAt;
            final bTime = bMeta?.createdAt;
            if (aTime != null && bTime != null) {
              return bTime.compareTo(aTime);
            } else if (aTime == null && bTime == null) {
              return a.displayName.compareTo(b.displayName);
            } else {
              return bTime != null ? 1 : -1; // non-null first
            }
          });
        return Stack(
          children: [
            Scaffold(
              backgroundColor: const Color(0xFFF0F4F8),
              appBar: AppHeader(onMenu: viewModel.toggleDrawer),
              body: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFF060E57), Color(0xFF3B82F6)],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF060E57).withValues(alpha: 0.2),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.people,
                                  color: Colors.white,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Select a Counselor',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      'Find and connect with available counselors',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      const Color(0xFF060E57).withValues(alpha: 0.06),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
                                  child: _buildSearchField(),
                                ),
                                Expanded(
                                  child: viewModel.isLoadingCounselors
                                      ? const Center(
                                          child: CircularProgressIndicator(),
                                        )
                                      : sorted.isEmpty
                                          ? const _EmptyCounselors()
                                          : ListView.builder(
                                              itemCount: sorted.length,
                                              itemBuilder: (context, index) {
                                                final counselor = sorted[index];
                                                final meta = latestByCounselor[
                                                  counselor.counselorId
                                                ];
                                                final hasUnread =
                                                    viewModel.hasUnreadMessages(
                                                  counselor.counselorId,
                                                );
                                                return _CounselorListItem(
                                                  counselor: counselor,
                                                  latestText: meta?.text,
                                                  isIncomingLatest:
                                                      meta?.isIncoming ?? false,
                                                  hasUnreadMessages: hasUnread,
                                                  createdAt: meta?.createdAt,
                                                  onTap: () {
                                                    viewModel.selectCounselor(
                                                      counselor,
                                                    );
                                                    if (context.mounted) {
                                                      Navigator.of(context)
                                                          .pushNamed(
                                                        '/student/conversation',
                                                        arguments: counselor,
                                                      );
                                                    }
                                                  },
                                                );
                                              },
                                            ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (viewModel.showNotifications)
                    StudentNotificationsDropdown(viewModel: viewModel),
                ],
              ),
              bottomNavigationBar: ModernBottomNavigationBar(
                currentIndex: 0,
                onTap: (index) {
                  switch (index) {
                    case 0:
                      Navigator.of(context).pushNamed('/student/dashboard');
                      break;
                    case 1:
                      viewModel.navigateToScheduleAppointment(context);
                      break;
                    case 2:
                      viewModel.navigateToMyAppointments(context);
                      break;
                    case 3:
                      viewModel.navigateToFollowUpSessions(context);
                      break;
                  }
                },
                isStudent: true,
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

  Widget _buildSearchField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF060E57).withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => setState(() => _query = value.trim()),
        decoration: InputDecoration(
          hintText: 'Search counselor by name',
          hintStyle: const TextStyle(
            color: Color(0xFF64748B),
            fontSize: 14,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: Color(0xFF64748B),
            size: 20,
          ),
          suffixIcon: _query.isNotEmpty
              ? IconButton(
                  icon: const Icon(
                    Icons.clear_rounded,
                    size: 18,
                    color: Color(0xFF94A3B8),
                  ),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _query = '');
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  List<Counselor> _filterCounselors(List<Counselor> source) {
    if (_query.isEmpty) return source;
    final String q = _query.toLowerCase();
    return source.where((c) {
      final name = c.displayName.toLowerCase();
      final spec = c.specialization.toLowerCase();
      final email = (c.email ?? '').toLowerCase();
      return name.contains(q) || spec.contains(q) || email.contains(q);
    }).toList();
  }

  Map<String, _LatestMeta> _computeLatestByCounselor(List<Message> messages) {
    final Map<String, _LatestMeta> map = {};
    for (final m in messages) {
      // Counselor can be either sender or receiver
      final String counselorId = _extractCounselorId(m);
      if (counselorId.isEmpty) continue;
      final existing = map[counselorId];
      if (existing == null || m.createdAt.isAfter(existing.createdAt)) {
        map[counselorId] = _LatestMeta(
          text: m.messageText,
          createdAt: m.createdAt,
          isIncoming: m.isReceived,
        );
      }
    }
    return map;
  }

  String _extractCounselorId(Message m) {
    // Heuristic: counselor id is the one that is not the current user id; we don't have user id here,
    // but in practice counselor ids differ from student ids prefix; fallback to receiverId when received, else senderId
    return m.isReceived ? m.senderId : m.receiverId;
  }
}

class _LatestMeta {
  final String text;
  final DateTime createdAt;
  final bool isIncoming;
  _LatestMeta({
    required this.text,
    required this.createdAt,
    required this.isIncoming,
  });
}

class _EmptyCounselors extends StatelessWidget {
  const _EmptyCounselors();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, color: Color(0xFF64748B), size: 48),
            SizedBox(height: 12),
            Text(
              'No counselors available',
              style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _CounselorListItem extends StatelessWidget {
  final Counselor counselor;
  final VoidCallback onTap;
  final String? latestText;
  final bool isIncomingLatest;
  final bool hasUnreadMessages;
  final DateTime? createdAt;

  const _CounselorListItem({
    required this.counselor,
    required this.onTap,
    this.latestText,
    this.isIncomingLatest = false,
    this.hasUnreadMessages = false,
    this.createdAt,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border.symmetric(
            horizontal: BorderSide(
              color: Color(0xFFF0F4F8),
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFE4E6EB),
                      width: 2,
                    ),
                  ),
                  child: ClipOval(child: _buildCounselorImage(counselor)),
                ),
                Positioned(
                  top: -2,
                  right: -2,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: counselor.onlineStatus.statusColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
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
                    counselor.displayName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF003366),
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (counselor.specialization != 'General Counseling')
                    Text(
                      counselor.specialization,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  const SizedBox(height: 2),
                  _buildLatestMessage(),
                  if (counselor.email != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      counselor.email!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            
          ],
        ),
      ),
    );
  }

  Widget _buildCounselorImage(Counselor counselor) {
    final imageUrl = ImageUrlHelper.getProfileImageUrl(
      counselor.profileImageUrl,
    );
    if (imageUrl == 'Photos/profile.png') {
      return Image.asset(
        'Photos/profile.png',
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.person, color: Color(0xFF64748B), size: 24);
        },
      );
    }
    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return const Icon(Icons.person, color: Color(0xFF64748B), size: 24);
      },
    );
  }

  Widget _buildLatestMessage() {
    final String text = latestText ?? 'No messages yet';
    final TextStyle baseStyle = const TextStyle(
      fontSize: 13,
      color: Color(0xFF64748B),
      height: 1.2,
    );
    // Bold text if incoming AND has unread messages
    final TextStyle style = (isIncomingLatest && hasUnreadMessages)
        ? baseStyle.copyWith(
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1E293B),
          )
        : baseStyle;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: style,
          ),
        ),
        if (createdAt != null) ...[
          const SizedBox(width: 8),
          Text(
            _formatShortTime(createdAt!),
            style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
          ),
        ],
      ],
    );
  }

  String _formatShortTime(DateTime t) {
    final DateTime localTime = t.toLocal();
    final DateTime now = DateTime.now();
    final Duration diff = now.difference(localTime);
    final String time12Hour = _formatTime12Hour(localTime);

    // If today
    if (localTime.day == now.day &&
        localTime.month == now.month &&
        localTime.year == now.year) {
      return time12Hour;
    }

    // If yesterday
    final DateTime yesterday = now.subtract(const Duration(days: 1));
    if (localTime.day == yesterday.day &&
        localTime.month == yesterday.month &&
        localTime.year == yesterday.year) {
      return 'Yesterday at $time12Hour';
    }

    // If 1 day ago (more than yesterday but less than 2 days ago)
    if (diff.inDays >= 1 && diff.inDays < 2) {
      return '1 day ago at $time12Hour';
    }

    // If within the week (2-7 days ago)
    if (diff.inDays >= 2 && diff.inDays <= 7) {
      return '${diff.inDays} days ago at $time12Hour';
    }

    // If more than a week, show full date with time
    return '${_getMonthName(localTime.month)} ${localTime.day}, ${localTime.year} at $time12Hour';
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }

  String _formatTime12Hour(DateTime dateTime) {
    final int hour = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
    final String minute = dateTime.minute.toString().padLeft(2, '0');
    final String period = dateTime.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }
}
