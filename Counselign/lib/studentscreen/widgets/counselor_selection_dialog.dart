import 'package:flutter/material.dart';
import '../state/student_dashboard_viewmodel.dart';
import '../models/counselor.dart';
import '../../api/config.dart';
import '../utils/image_url_helper.dart';
import '../../utils/online_status.dart';

class CounselorSelectionDialog extends StatelessWidget {
  final StudentDashboardViewModel viewModel;

  const CounselorSelectionDialog({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        width: MediaQuery.of(context).size.width > 480
            ? 400
            : MediaQuery.of(context).size.width - 40,
        constraints: const BoxConstraints(maxHeight: 500),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFD),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                border: Border(
                  bottom: BorderSide(color: const Color(0xFFEEF2F7), width: 1),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.people, color: Color(0xFF003366), size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'Select a Counselor',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF003366),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: viewModel.hideCounselorSelection,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),

            // Counselors list
            Flexible(
              child: viewModel.isLoadingCounselors
                  ? const Padding(
                      padding: EdgeInsets.all(40),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : viewModel.counselors.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(40),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.people_outline,
                              color: Color(0xFF64748B),
                              size: 48,
                            ),
                            SizedBox(height: 12),
                            Text(
                              'No counselors available',
                              style: TextStyle(
                                color: Color(0xFF64748B),
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: viewModel.counselors.length,
                      itemBuilder: (context, index) {
                        final counselor = viewModel.counselors[index];
                        return _buildCounselorItem(context, counselor);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCounselorItem(BuildContext context, Counselor counselor) {
    return InkWell(
      onTap: () => viewModel.selectCounselor(counselor),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(color: const Color(0xFFF0F4F8), width: 1),
          ),
        ),
        child: Row(
          children: [
            // Profile picture
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFE4E6EB), width: 2),
              ),
              child: ClipOval(child: _buildCounselorImage(counselor)),
            ),

            const SizedBox(width: 12),

            // Counselor info
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
                  // Only show specialization if it's not "General Counseling"
                  if (counselor.specialization != 'General Counseling') ...[
                    Text(
                      counselor.specialization,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 2),
                  ],
                  // Online status indicator
                  Row(
                    children: [
                      Icon(
                        counselor.onlineStatus.statusIcon,
                        size: 8,
                        color: counselor.onlineStatus.statusColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        counselor.onlineStatus.text,
                        style: TextStyle(
                          fontSize: 12,
                          color: counselor.onlineStatus.statusColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
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

            const SizedBox(width: 8),

            // Arrow icon
            const Icon(
              Icons.arrow_forward_ios,
              color: Color(0xFF94A3B8),
              size: 16,
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

    // If it's the default profile image, use asset
    if (imageUrl == 'Photos/profile.png') {
      return Image.asset(
        'Photos/profile.png',
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.person, color: Color(0xFF64748B), size: 24);
        },
      );
    }

    // Otherwise, use network image
    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return const Icon(Icons.person, color: Color(0xFF64748B), size: 24);
      },
    );
  }
}
