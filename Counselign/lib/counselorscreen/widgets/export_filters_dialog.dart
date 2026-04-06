import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/appointment_report.dart';
import '../../utils/session.dart';
import '../../api/config.dart';

class ExportFiltersDialog extends StatefulWidget {
  final String exportType;
  final Function(ExportFilters?) onExportPDF;
  final Function(ExportFilters?) onExportExcel;
  final bool isExporting;

  const ExportFiltersDialog({
    super.key,
    required this.exportType,
    required this.onExportPDF,
    required this.onExportExcel,
    required this.isExporting,
  });

  @override
  State<ExportFiltersDialog> createState() => _ExportFiltersDialogState();
}

class _ExportFiltersDialogState extends State<ExportFiltersDialog> {
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();

  String? _selectedStudentId;
  String? _selectedCourse;
  String? _selectedYearLevel;

  List<Map<String, dynamic>> _students = [];
  bool _loadingStudents = true;

  final List<String> _courses = [
    'BSIT',
    'BSABE',
    'BSEnE',
    'BSHM',
    'BFPT',
    'BSA',
    'BTHM',
    'BSSW',
    'BSAF',
    'BTLED',
    'DAT-BAT',
  ];

  final List<String> _yearLevels = ['I', 'II', 'III', 'IV'];

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    try {
      final session = Session();
      final url = '${ApiConfig.currentBaseUrl}/counselor/filter-data/students';
      final response = await session.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          setState(() {
            _students = List<Map<String, dynamic>>.from(data['data'] ?? []);
            _loadingStudents = false;
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading students: $e');
      setState(() {
        _loadingStudents = false;
      });
    }
  }

  @override
  void dispose() {
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          const Icon(
            FontAwesomeIcons.filter,
            color: Color(0xFF0d6efd),
            size: 20,
          ),
          const SizedBox(width: 8),
          const Text('Export Filters'),
        ],
      ),
      content: SingleChildScrollView(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date Range Filters
              const Text(
                'Date Range',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _startDateController,
                      decoration: const InputDecoration(
                        labelText: 'Start Date',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      readOnly: true,
                      onTap: () =>
                          _selectDate(_startDateController, 'Start Date'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _endDateController,
                      decoration: const InputDecoration(
                        labelText: 'End Date',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      readOnly: true,
                      onTap: () => _selectDate(_endDateController, 'End Date'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    FontAwesomeIcons.circleInfo,
                    size: 12,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: const Text(
                      'Leave dates empty to export all appointments from the selected status tab.',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Additional Filters
              const Text(
                'Additional Filters',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 12),

              // Student Filter
              _loadingStudents
                  ? const Center(child: CircularProgressIndicator())
                  : DropdownButtonFormField<String>(
                      isExpanded: true,
                      initialValue: _selectedStudentId,
                      decoration: const InputDecoration(
                        labelText: 'Student',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text('All Students'),
                        ),
                        ..._students.map(
                          (student) => DropdownMenuItem(
                            value: student['student_id'].toString(),
                            child: Text(
                              student['full_name'] ??
                                  student['student_id'].toString(),
                            ),
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedStudentId = value;
                        });
                      },
                    ),
              const SizedBox(height: 12),

              // Course and Year Level
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      isExpanded: true,
                      initialValue: _selectedCourse,
                      decoration: const InputDecoration(
                        labelText: 'Course',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text('All Courses'),
                        ),
                        ..._courses.map(
                          (course) => DropdownMenuItem(
                            value: course,
                            child: Text(course),
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedCourse = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      isExpanded: true,
                      initialValue: _selectedYearLevel,
                      decoration: const InputDecoration(
                        labelText: 'Year Level',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text('All Year Levels'),
                        ),
                        ..._yearLevels.map(
                          (year) =>
                              DropdownMenuItem(value: year, child: Text(year)),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedYearLevel = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        // First row: Clear buttons
        SizedBox(
          width: double.infinity,
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _clearAllFilters,
                  icon: const Icon(Icons.clear_all, size: 16),
                  label: const Text('Clear All'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey[700],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _clearDateRange,
                  icon: const Icon(FontAwesomeIcons.calendarXmark, size: 14),
                  label: const Text('Clear Dates'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF0d6efd),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // Second row: Export button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: widget.isExporting ? null : _export,
            icon: Icon(
              widget.exportType == 'PDF'
                  ? FontAwesomeIcons.filePdf
                  : FontAwesomeIcons.fileExcel,
              size: 16,
            ),
            label: Text('Apply Filters & Export ${widget.exportType}'),
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.exportType == 'PDF'
                  ? const Color(0xFF0d6efd)
                  : const Color(0xFF198754),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate(
    TextEditingController controller,
    String label,
  ) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (date != null) {
      controller.text =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    }
  }

  void _clearAllFilters() {
    setState(() {
      _startDateController.clear();
      _endDateController.clear();
      _selectedStudentId = null;
      _selectedCourse = null;
      _selectedYearLevel = null;
    });
  }

  void _clearDateRange() {
    setState(() {
      _startDateController.clear();
      _endDateController.clear();
    });
  }

  void _export() {
    // Validate date range
    if (_startDateController.text.isNotEmpty &&
        _endDateController.text.isNotEmpty &&
        _startDateController.text.compareTo(_endDateController.text) > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Start date cannot be later than end date.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final filters = ExportFilters(
      startDate: _startDateController.text.isNotEmpty
          ? _startDateController.text
          : null,
      endDate: _endDateController.text.isNotEmpty
          ? _endDateController.text
          : null,
      studentId: _selectedStudentId,
      course: _selectedCourse,
      yearLevel: _selectedYearLevel,
    );

    if (widget.exportType == 'PDF') {
      widget.onExportPDF(filters);
    } else {
      widget.onExportExcel(filters);
    }

    Navigator.pop(context);
  }
}
