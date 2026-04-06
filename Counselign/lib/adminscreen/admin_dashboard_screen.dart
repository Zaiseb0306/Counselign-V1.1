import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'state/admin_dashboard_viewmodel.dart';
import 'widgets/admin_header.dart';
import 'widgets/admin_footer.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with TickerProviderStateMixin {
  late AdminDashboardViewModel _viewModel;
  late TabController _tabController;
  String _selectedTimeRange = 'weekly';

  @override
  void initState() {
    super.initState();
    _viewModel = AdminDashboardViewModel();
    _viewModel.initialize();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _viewModel.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: Column(
          children: [
            const AdminHeader(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildProfileSection(context),
                    _buildAppointmentReportsSection(context),
                    _buildStatisticsSection(context),
                    _buildChartsSection(context),
                    _buildAppointmentTablesSection(context),
                    const AdminFooter(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 1024;
    final isDesktop = screenWidth >= 1024;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: isMobile ? 10 : 16),
      padding: EdgeInsets.symmetric(
        horizontal: isMobile
            ? 15
            : isTablet
            ? 20
            : 25,
        vertical: isMobile ? 10 : 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: const Color(0xFF003366).withValues(alpha: 0.08),
        ),
      ),
      child: Consumer<AdminDashboardViewModel>(
        builder: (context, viewModel, child) {
          return Column(
            children: [
              // Profile Row with Action Buttons
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Profile Avatar - matches CSS: width: 70px; height: 70px;
                  GestureDetector(
                    onTap: () => _navigateToAdminManagement(context),
                    child: Container(
                      width: isMobile
                          ? 50
                          : isTablet
                          ? 60
                          : 70,
                      height: isMobile
                          ? 50
                          : isTablet
                          ? 60
                          : 70,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFF0F0F0),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.12),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                        color: Colors.white,
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'Photos/UGC-Logo.png',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[200],
                              child: Icon(
                                Icons.person,
                                size: isMobile
                                    ? 30
                                    : isTablet
                                    ? 35
                                    : 40,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: isMobile
                        ? 15
                        : isTablet
                        ? 20
                        : 30,
                  ),
                  // Profile Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Hello! ${viewModel.adminProfile?.name ?? 'Admin'}',
                          style: TextStyle(
                            fontSize: isMobile
                                ? 14
                                : isTablet
                                ? 18
                                : 20,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF003366),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Login at: ${viewModel.lastLogin ?? 'Loading...'}',
                          style: TextStyle(
                            fontSize: isMobile
                                ? 10
                                : isTablet
                                ? 12
                                : 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Action Buttons - matches CSS: padding: 8px 16px; font-size: 0.875rem;
                  if (isDesktop) ...[
                    SizedBox(width: isTablet ? 15 : 20),
                    ElevatedButton.icon(
                      onPressed: () => _navigateToAdminManagement(context),
                      icon: const Icon(Icons.people_alt, size: 14),
                      label: const Text(
                        'Management',
                        style: TextStyle(fontSize: 14),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF060E57),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        elevation: 1,
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () => _navigateToViewAllAppointments(context),
                      icon: const Icon(Icons.list_alt, size: 14),
                      label: const Text(
                        'All Appointments',
                        style: TextStyle(fontSize: 14),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF059669),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        elevation: 1,
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () => _navigateToFollowUpSessions(context),
                      icon: const Icon(Icons.calendar_today, size: 14),
                      label: const Text(
                        'Follow-up Sessions',
                        style: TextStyle(fontSize: 14),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFC107),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        elevation: 1,
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => _navigateToAnnouncements(context),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFFE3EAFC)),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(
                                0xFF0D6EFD,
                              ).withValues(alpha: 0.08),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.campaign,
                          color: Color(0xFF073C8A),
                          size: 18,
                        ),
                      ),
                    ),
                  ] else ...[
                    // Mobile/Tablet Action Buttons - matches CSS responsive design
                    SizedBox(width: isMobile ? 10 : 15),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _navigateToAdminManagement(context),
                        icon: Icon(Icons.people_alt, size: isMobile ? 14 : 15),
                        label: Text(
                          'Management',
                          style: TextStyle(fontSize: isMobile ? 12 : 13),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF060E57),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            vertical: isMobile ? 10 : 12,
                            horizontal: isMobile ? 8 : 12,
                          ),
                          elevation: 1,
                        ),
                      ),
                    ),
                    SizedBox(width: isMobile ? 6 : 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () =>
                            _navigateToViewAllAppointments(context),
                        icon: Icon(Icons.list_alt, size: isMobile ? 14 : 15),
                        label: Text(
                          'All Appointments',
                          style: TextStyle(fontSize: isMobile ? 12 : 13),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF059669),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            vertical: isMobile ? 10 : 12,
                            horizontal: isMobile ? 8 : 12,
                          ),
                          elevation: 1,
                        ),
                      ),
                    ),
                    SizedBox(width: isMobile ? 6 : 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _navigateToFollowUpSessions(context),
                        icon: Icon(
                          Icons.calendar_today,
                          size: isMobile ? 14 : 15,
                        ),
                        label: Text(
                          'Follow-up Sessions',
                          style: TextStyle(fontSize: isMobile ? 12 : 13),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFC107),
                          foregroundColor: Colors.black,
                          padding: EdgeInsets.symmetric(
                            vertical: isMobile ? 10 : 12,
                            horizontal: isMobile ? 8 : 12,
                          ),
                          elevation: 1,
                        ),
                      ),
                    ),
                    SizedBox(width: isMobile ? 6 : 10),
                    GestureDetector(
                      onTap: () => _navigateToAnnouncements(context),
                      child: Container(
                        width: isMobile ? 40 : 44,
                        height: isMobile ? 40 : 44,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFFE3EAFC)),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(
                                0xFF0D6EFD,
                              ).withValues(alpha: 0.08),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.campaign,
                          color: const Color(0xFF073C8A),
                          size: isMobile ? 18 : 20,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAppointmentReportsSection(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: EdgeInsets.all(isMobile ? 20 : 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Page Header
          Row(
            children: [
              const Icon(Icons.show_chart, color: Color(0xFF0D6EFD)),
              const SizedBox(width: 8),
              const Text(
                'Appointment Reports',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF212529),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'View and analyze appointment statistics',
            style: TextStyle(fontSize: 16, color: Color(0xFF6C757D)),
          ),
          const SizedBox(height: 24),
          // Filter Section
          Row(
            children: [
              Expanded(
                flex: isMobile ? 1 : 2,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: const BoxDecoration(
                          color: Color(0xFFF8F9FA),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(8),
                            bottomLeft: Radius.circular(8),
                          ),
                        ),
                        child: const Icon(Icons.calendar_today, size: 16),
                      ),
                      Expanded(
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedTimeRange,
                            isExpanded: true,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            items: const [
                              DropdownMenuItem(
                                value: 'daily',
                                child: Text('Daily Report'),
                              ),
                              DropdownMenuItem(
                                value: 'weekly',
                                child: Text('Weekly Report'),
                              ),
                              DropdownMenuItem(
                                value: 'monthly',
                                child: Text('Monthly Report'),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _selectedTimeRange = value!;
                              });
                              _viewModel.updateTimeRange(value!);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              SizedBox(
                width: isMobile ? 120 : 200,
                child: ElevatedButton.icon(
                  onPressed: () => _navigateToHistoryReports(context),
                  icon: const Icon(Icons.history, size: 16),
                  label: const Text('View Past Reports'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C757D),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsSection(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Consumer<AdminDashboardViewModel>(
        builder: (context, viewModel, child) {
          final stats = viewModel.getStatistics();
          return Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  FontAwesomeIcons.circleCheck,
                  stats['completed'] ?? 0,
                  'Completed',
                  const Color(0xFF28A745),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  context,
                  FontAwesomeIcons.thumbsUp,
                  stats['approved'] ?? 0,
                  'Approved',
                  const Color(0xFF007BFF),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  context,
                  FontAwesomeIcons.circleXmark,
                  stats['rejected'] ?? 0,
                  'Rejected',
                  const Color(0xFFDC3545),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  context,
                  FontAwesomeIcons.clock,
                  stats['pending'] ?? 0,
                  'Pending',
                  const Color(0xFFFFC107),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  context,
                  FontAwesomeIcons.ban,
                  stats['cancelled'] ?? 0,
                  'Cancelled',
                  const Color(0xFF6C757D),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    IconData icon,
    int count,
    String label,
    Color color,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FaIcon(icon, color: color, size: isMobile ? 20 : 24),
          SizedBox(width: isMobile ? 8 : 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                count.toString(),
                style: TextStyle(
                  fontSize: isMobile ? 18 : 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: isMobile ? 10 : 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChartsSection(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Trend Chart
          Expanded(
            flex: isMobile ? 1 : 2,
            child: Container(
              padding: EdgeInsets.all(isMobile ? 16 : 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.show_chart, color: Color(0xFF0D6EFD)),
                      const SizedBox(width: 8),
                      const Text(
                        'Appointment Trends',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: isMobile ? 300 : 400,
                    child: Consumer<AdminDashboardViewModel>(
                      builder: (context, viewModel, child) {
                        final lineData = viewModel.getLineChartData(
                          'completed',
                        );
                        return LineChart(
                          LineChartData(
                            gridData: FlGridData(show: true),
                            titlesData: FlTitlesData(
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: true),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: true),
                              ),
                              topTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              rightTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                            ),
                            borderData: FlBorderData(show: true),
                            lineBarsData: [
                              LineChartBarData(
                                spots: lineData
                                    .map(
                                      (data) => FlSpot(data['x']!, data['y']!),
                                    )
                                    .toList(),
                                isCurved: true,
                                color: const Color(0xFF0D6EFD),
                                barWidth: 3,
                                dotData: FlDotData(show: true),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Pie Chart
          Expanded(
            child: Container(
              padding: EdgeInsets.all(isMobile ? 16 : 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.pie_chart, color: Color(0xFF0D6EFD)),
                      const SizedBox(width: 8),
                      const Text(
                        'Status Distribution',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: isMobile ? 250 : 300,
                    child: Consumer<AdminDashboardViewModel>(
                      builder: (context, viewModel, child) {
                        final pieData = viewModel.getPieChartData();
                        return PieChart(
                          PieChartData(
                            sections: pieData
                                .map(
                                  (data) => PieChartSectionData(
                                    value: data['value'] as double,
                                    title: data['title'] as String,
                                    color: data['color'] as Color,
                                    radius: 60,
                                  ),
                                )
                                .toList(),
                            centerSpaceRadius: 40,
                            sectionsSpace: 2,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentTablesSection(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          const Center(
            child: Text(
              'All Appointment Lists',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0D6EFD),
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Tabs
          TabBar(
            controller: _tabController,
            isScrollable: isMobile,
            tabs: const [
              Tab(icon: Icon(Icons.list), text: 'All Appointments'),
              Tab(icon: Icon(Icons.thumb_up), text: 'Approved'),
              Tab(icon: Icon(Icons.cancel), text: 'Rejected'),
              Tab(icon: Icon(Icons.check_circle), text: 'Completed'),
              Tab(icon: Icon(Icons.block), text: 'Cancelled'),
            ],
          ),
          const SizedBox(height: 16),
          // Filter Options
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: const BoxDecoration(
                          color: Color(0xFFF8F9FA),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(8),
                            bottomLeft: Radius.circular(8),
                          ),
                        ),
                        child: const Icon(Icons.search, size: 16),
                      ),
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(
                            hintText: 'Search appointments...',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                            ),
                          ),
                          onChanged: (value) {
                            _viewModel.updateSearchQuery(value);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: const BoxDecoration(
                          color: Color(0xFFF8F9FA),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(8),
                            bottomLeft: Radius.circular(8),
                          ),
                        ),
                        child: const Icon(Icons.calendar_today, size: 16),
                      ),
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(
                            hintText: 'Select month',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                            ),
                          ),
                          onChanged: (value) {
                            _viewModel.updateMonthFilter(value);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _exportToPDF(),
                    icon: const Icon(Icons.picture_as_pdf, size: 16),
                    label: const Text('Export PDF'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D6EFD),
                      foregroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () => _exportToExcel(),
                    icon: const Icon(Icons.table_chart, size: 16),
                    label: const Text('Export Excel'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF28A745),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Tab Content
          SizedBox(
            height: 500,
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAppointmentsTable(context, 'all'),
                _buildAppointmentsTable(context, 'approved'),
                _buildAppointmentsTable(context, 'rejected'),
                _buildAppointmentsTable(context, 'completed'),
                _buildAppointmentsTable(context, 'cancelled'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentsTable(BuildContext context, String status) {
    return Consumer<AdminDashboardViewModel>(
      builder: (context, viewModel, child) {
        final appointments = viewModel.getFilteredAppointments(status);

        if (appointments.isEmpty) {
          return const Center(
            child: Text(
              'No appointments found',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: const [
              DataColumn(label: Text('User ID')),
              DataColumn(label: Text('Full Name')),
              DataColumn(label: Text('Date')),
              DataColumn(label: Text('Time')),
              DataColumn(label: Text('Consultation Type')),
              DataColumn(label: Text('Purpose')),
              DataColumn(label: Text('Counselor')),
              DataColumn(label: Text('Status')),
              DataColumn(label: Text('Actions')),
            ],
            rows: appointments.map((appointment) {
              return DataRow(
                cells: [
                  DataCell(Text(appointment.userId.toString())),
                  DataCell(Text(appointment.userName)),
                  DataCell(Text(appointment.preferredDate)),
                  DataCell(Text(appointment.preferredTime ?? 'N/A')),
                  DataCell(Text(appointment.consultationType ?? 'N/A')),
                  DataCell(Text(appointment.description ?? 'N/A')),
                  DataCell(Text('N/A')), // counselorName not available in model
                  DataCell(
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(
                          appointment.status,
                        ).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _getStatusColor(appointment.status),
                        ),
                      ),
                      child: Text(
                        appointment.status,
                        style: TextStyle(
                          color: _getStatusColor(appointment.status),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  DataCell(
                    PopupMenuButton<String>(
                      onSelected: (value) =>
                          _handleAppointmentAction(appointment.id, value),
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'view',
                          child: Text('View Details'),
                        ),
                        const PopupMenuItem(
                          value: 'approve',
                          child: Text('Approve'),
                        ),
                        const PopupMenuItem(
                          value: 'complete',
                          child: Text('Mark Completed'),
                        ),
                        const PopupMenuItem(
                          value: 'cancel',
                          child: Text('Cancel'),
                        ),
                        const PopupMenuItem(
                          value: 'reschedule',
                          child: Text('Reschedule'),
                        ),
                      ],
                      child: const Icon(Icons.more_vert),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return const Color(0xFF28A745);
      case 'approved':
        return const Color(0xFF007BFF);
      case 'pending':
        return const Color(0xFFFFC107);
      case 'rejected':
        return const Color(0xFFDC3545);
      case 'cancelled':
        return const Color(0xFF6C757D);
      default:
        return Colors.grey;
    }
  }

  void _handleAppointmentAction(int appointmentId, String action) {
    // Handle appointment actions
    switch (action) {
      case 'view':
        _viewAppointmentDetails(appointmentId);
        break;
      case 'approve':
        _updateAppointmentStatus(appointmentId, 'Approved');
        break;
      case 'complete':
        _updateAppointmentStatus(appointmentId, 'Completed');
        break;
      case 'cancel':
        _updateAppointmentStatus(appointmentId, 'Cancelled');
        break;
      case 'reschedule':
        _updateAppointmentStatus(appointmentId, 'Rescheduled');
        break;
    }
  }

  void _viewAppointmentDetails(int appointmentId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Appointment Details'),
        content: const Text('Appointment details will be shown here'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _updateAppointmentStatus(int appointmentId, String status) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Status'),
        content: Text(
          'Are you sure you want to change this appointment status to "$status"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final dialogContext = context;
              // Capture the ScaffoldMessenger BEFORE the async gap
              final scaffoldMessenger = ScaffoldMessenger.of(context);

              Navigator.pop(dialogContext);

              // Perform the async operation
              final success = await _viewModel.updateAppointmentStatus(
                appointmentId,
                status,
              );

              // Check if widget is still mounted before showing snackbar
              if (!mounted) return;

              // Now safe to use the captured ScaffoldMessenger
              if (success) {
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: Text('Appointment status updated to $status'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                scaffoldMessenger.showSnackBar(
                  const SnackBar(
                    content: Text('Failed to update appointment status'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  void _exportToPDF() {
    // Show export filters dialog like JavaScript
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export to PDF'),
        content: const Text(
          'PDF export functionality will be implemented with proper filtering options.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('PDF export feature coming soon!'),
                  backgroundColor: Colors.blue,
                ),
              );
            },
            child: const Text('Export'),
          ),
        ],
      ),
    );
  }

  void _exportToExcel() {
    // Show export filters dialog like JavaScript
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export to Excel'),
        content: const Text(
          'Excel export functionality will be implemented with proper filtering options.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Excel export feature coming soon!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Export'),
          ),
        ],
      ),
    );
  }

  void _navigateToAdminManagement(BuildContext context) {
    Navigator.of(context).pushNamed('/admin/admins-management');
  }

  void _navigateToAnnouncements(BuildContext context) {
    Navigator.of(context).pushNamed('/admin/announcements');
  }

  void _navigateToViewAllAppointments(BuildContext context) {
    Navigator.of(context).pushNamed('/admin/view-all-appointments');
  }

  void _navigateToFollowUpSessions(BuildContext context) {
    Navigator.of(context).pushNamed('/admin/follow-up-sessions');
  }

  void _navigateToHistoryReports(BuildContext context) {
    Navigator.of(context).pushNamed('/admin/history-reports');
  }
}
