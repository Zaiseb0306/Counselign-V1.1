import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:excel/excel.dart' as excel_pkg;
import '../models/appointment_report.dart';
import '../../utils/session.dart';
import '../../api/config.dart';

class CounselorReportsViewModel extends ChangeNotifier {
  bool _isLoading = false;
  bool _isExporting = false;
  String? _error;
  AppointmentReport? _reportData;
  TimeRange _selectedTimeRange = TimeRange.weekly;
  AppointmentStatus _selectedStatus = AppointmentStatus.all;
  String _searchQuery = '';
  String? _selectedDate;
  List<AppointmentReportItem> _filteredAppointments = [];
  List<AppointmentReportItem> _allAppointments = [];
  Map<String, Map<String, String>> _studentAcademicMap = {};

  // Getters
  bool get isLoading => _isLoading;
  bool get isExporting => _isExporting;
  String? get error => _error;
  AppointmentReport? get reportData => _reportData;
  TimeRange get selectedTimeRange => _selectedTimeRange;
  AppointmentStatus get selectedStatus => _selectedStatus;
  String get searchQuery => _searchQuery;
  String? get selectedDate => _selectedDate;
  List<AppointmentReportItem> get filteredAppointments => _filteredAppointments;
  List<AppointmentReportItem> get allAppointments => _allAppointments;

  int get totalCompleted => _reportData?.totalCompleted ?? 0;
  int get totalApproved => _reportData?.totalApproved ?? 0;
  int get totalRejected => _reportData?.totalRejected ?? 0;
  int get totalPending => _reportData?.totalPending ?? 0;
  int get totalCancelled => _reportData?.totalCancelled ?? 0;

  ChartData? get chartData {
    if (_reportData == null) return null;
    return ChartData(
      labels: _reportData!.labels,
      completed: _reportData!.completed,
      approved: _reportData!.approved,
      rejected: _reportData!.rejected,
      pending: _reportData!.pending,
      cancelled: _reportData!.cancelled,
    );
  }

  List<AppointmentPieChartData> get pieChartData {
    return [
      AppointmentPieChartData(
        'Completed',
        totalCompleted,
        const Color(0xFF0d6efd),
      ),
      AppointmentPieChartData(
        'Approved',
        totalApproved,
        const Color(0xFF198754),
      ),
      AppointmentPieChartData(
        'Rejected',
        totalRejected,
        const Color(0xFFdc3545),
      ),
      AppointmentPieChartData('Pending', totalPending, const Color(0xFFffc107)),
      AppointmentPieChartData(
        'Cancelled',
        totalCancelled,
        const Color(0xFF6c757d),
      ),
    ];
  }

  Future<void> initialize() async {
    await _loadStudentAcademicMap();
    await loadReportData();
  }

  Future<void> _loadStudentAcademicMap() async {
    try {
      final session = Session();
      final url =
          '${ApiConfig.currentBaseUrl}/counselor/filter-data/student-academic-map';
      final response = await session.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final mapData = data['data'] as Map<String, dynamic>;
          _studentAcademicMap = mapData.map((key, value) {
            return MapEntry(key, {
              'course': value['course']?.toString() ?? '',
              'year_level': value['year_level']?.toString() ?? '',
            });
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading student academic map: $e');
    }
  }

  Future<void> loadReportData() async {
    _setLoading(true);
    _clearError();

    try {
      final session = Session();
      final url =
          '${ApiConfig.currentBaseUrl}/counselor/appointments/get_all_appointments?timeRange=${_selectedTimeRange.value}';

      debugPrint('Loading report data from: $url');

      final response = await session.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        debugPrint('Report data received: ${data.keys}');

        if (data['success'] == true || data['appointments'] != null) {
          _reportData = AppointmentReport.fromJson(data);
          _allAppointments = _reportData!.appointments;
          _applyFilters();
          debugPrint(
            'Report data loaded successfully: ${_allAppointments.length} appointments',
          );
        } else {
          throw Exception(data['message'] ?? 'Failed to load report data');
        }
      } else {
        throw Exception(
          'HTTP ${response.statusCode}: ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      debugPrint('Error loading report data: $e');
      _setError('Failed to load report data: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateTimeRange(TimeRange timeRange) async {
    if (_selectedTimeRange != timeRange) {
      _selectedTimeRange = timeRange;
      notifyListeners();
      await loadReportData();
    }
  }

  void updateStatusFilter(AppointmentStatus status) {
    _selectedStatus = status;
    _applyFilters();
    notifyListeners();
  }

  void updateSearchQuery(String query) {
    _searchQuery = query.toLowerCase();
    _applyFilters();
    notifyListeners();
  }

  void updateDateFilter(String? date) {
    _selectedDate = date;
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    List<AppointmentReportItem> filtered = List.from(_allAppointments);

    if (_selectedStatus != AppointmentStatus.all) {
      if (_selectedStatus == AppointmentStatus.followup) {
        filtered = filtered.where((appointment) {
          final isFollowUp =
              (appointment.recordKind == 'follow_up') ||
              (appointment.appointmentType != null &&
                  appointment.appointmentType!.toLowerCase().contains(
                    'follow-up',
                  ));
          final validStatus = [
            'PENDING',
            'COMPLETED',
            'CANCELLED',
          ].contains(appointment.status.toUpperCase());
          return isFollowUp && validStatus;
        }).toList();
      } else {
        filtered = filtered.where((appointment) {
          return appointment.status.toLowerCase() == _selectedStatus.value;
        }).toList();
      }
    }

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((appointment) {
        return appointment.userId.toLowerCase().contains(_searchQuery) ||
            appointment.studentName.toLowerCase().contains(_searchQuery) ||
            appointment.consultationType.toLowerCase().contains(_searchQuery) ||
            appointment.purpose.toLowerCase().contains(_searchQuery) ||
            (appointment.methodType?.toLowerCase().contains(_searchQuery) ??
                false);
      }).toList();
    }

    if (_selectedDate != null && _selectedDate!.isNotEmpty) {
      filtered = filtered.where((appointment) {
        return appointment.appointedDate.startsWith(_selectedDate!);
      }).toList();
    }

    filtered.sort((a, b) {
      final dateTimeA = '${a.appointedDate} ${a.appointedTime}';
      final dateTimeB = '${b.appointedDate} ${b.appointedTime}';
      return dateTimeA.compareTo(dateTimeB);
    });

    _filteredAppointments = filtered;
  }

  void clearFilters() {
    _searchQuery = '';
    _selectedDate = null;
    _selectedStatus = AppointmentStatus.all;
    _applyFilters();
    notifyListeners();
  }

  Future<void> exportToPDF(ExportFilters? filters) async {
    _setExporting(true);
    _clearError();

    try {
      final appointments = _getFilteredAppointmentsForExport(filters);
      final reportTitle = _getReportTitle();
      final counselorName = _reportData?.counselorName ?? 'Unknown Counselor';
      final filterSummary = _buildFilterSummary(filters);

      final pdf = pw.Document();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4.landscape,
          margin: const pw.EdgeInsets.all(32),
          build: (pw.Context context) {
            return [
              // Header
              pw.Row(
                children: [
                  pw.Container(
                    width: 25,
                    height: 19,
                    decoration: pw.BoxDecoration(color: PdfColors.blue),
                    child: pw.Center(
                      child: pw.Text(
                        'C',
                        style: pw.TextStyle(
                          color: PdfColors.white,
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  pw.SizedBox(width: 10),
                  pw.Text(
                    'Counselign - The USTP Guidance Counseling Sanctuary',
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 10),
              pw.Divider(),
              pw.SizedBox(height: 10),

              // Report title
              pw.Center(
                child: pw.Text(
                  '$reportTitle - Counselor: $counselorName',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 20),

              // Table
              pw.TableHelper.fromTextArray(
                headerStyle: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                  fontSize: 9,
                ),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.blue),
                cellAlignment: pw.Alignment.centerLeft,
                cellPadding: const pw.EdgeInsets.all(4),
                headers: [
                  'User ID',
                  'Full Name',
                  'Date',
                  'Time',
                  'Method Type',
                  'Consultation Type',
                  'Session',
                  'Purpose',
                  'Counselor',
                  'Status',
                ],
                data: appointments.map((app) {
                  return [
                    app.userId,
                    app.studentName,
                    app.formattedDate,
                    app.appointedTime,
                    app.methodType ?? '',
                    app.consultationType,
                    app.sessionTypeDisplay,
                    app.purpose,
                    app.counselorName,
                    app.status.toLowerCase(),
                  ];
                }).toList(),
                cellStyle: const pw.TextStyle(fontSize: 8),
              ),
            ];
          },
          footer: (pw.Context context) {
            return pw.Column(
              children: [
                pw.Divider(),
                pw.SizedBox(height: 10),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'Confidential Document',
                      style: const pw.TextStyle(fontSize: 8),
                    ),
                    pw.Text(
                      'Prepared by the University Guidance Counseling Office',
                      style: const pw.TextStyle(fontSize: 8),
                    ),
                    pw.Text(
                      'Generated: ${DateTime.now().toLocal().toString().split('.')[0]} | Page ${context.pageNumber}',
                      style: const pw.TextStyle(fontSize: 8),
                    ),
                  ],
                ),
                pw.SizedBox(height: 5),
                pw.Center(
                  child: pw.Text(
                    filterSummary,
                    style: const pw.TextStyle(fontSize: 9),
                  ),
                ),
              ],
            );
          },
        ),
      );

      final directory = await getApplicationDocumentsDirectory();
      final file = File(
        '${directory.path}/appointment_report_${DateTime.now().millisecondsSinceEpoch}.pdf',
      );
      await file.writeAsBytes(await pdf.save());

      await OpenFile.open(file.path);

      // Track export activity
      await _trackExportActivity();
    } catch (e) {
      debugPrint('Error exporting PDF: $e');
      _setError('Failed to export PDF: $e');
    } finally {
      _setExporting(false);
    }
  }

  Future<void> exportToExcel(ExportFilters? filters) async {
    _setExporting(true);
    _clearError();

    try {
      final appointments = _getFilteredAppointmentsForExport(filters);
      final reportTitle = _getReportTitle();
      final counselorName = _reportData?.counselorName ?? 'Unknown Counselor';
      final filterSummary = _buildFilterSummary(filters);

      final excelFile = excel_pkg.Excel.createExcel();
      final sheet = excelFile['Appointments'];

      // Title row
      sheet.merge(
        excel_pkg.CellIndex.indexByString('A1'),
        excel_pkg.CellIndex.indexByString('J1'),
      );
      var titleCell = sheet.cell(excel_pkg.CellIndex.indexByString('A1'));
      titleCell.value = excel_pkg.TextCellValue(
        '$reportTitle - Counselor: $counselorName',
      );
      titleCell.cellStyle = excel_pkg.CellStyle(
        bold: true,
        fontSize: 14,
        horizontalAlign: excel_pkg.HorizontalAlign.Center,
      );

      // Filter summary row
      sheet.merge(
        excel_pkg.CellIndex.indexByString('A2'),
        excel_pkg.CellIndex.indexByString('J2'),
      );
      var filterCell = sheet.cell(excel_pkg.CellIndex.indexByString('A2'));
      filterCell.value = excel_pkg.TextCellValue(filterSummary);
      filterCell.cellStyle = excel_pkg.CellStyle(
        fontSize: 10,
        horizontalAlign: excel_pkg.HorizontalAlign.Center,
      );

      // Header row
      final headers = [
        'User ID',
        'Full Name',
        'Date',
        'Time',
        'Method Type',
        'Consultation Type',
        'Session',
        'Purpose',
        'Counselor',
        'Status',
      ];
      for (var i = 0; i < headers.length; i++) {
        var cell = sheet.cell(
          excel_pkg.CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 3),
        );
        cell.value = excel_pkg.TextCellValue(headers[i]);
        cell.cellStyle = excel_pkg.CellStyle(bold: true);
      }

      // Data rows
      for (var i = 0; i < appointments.length; i++) {
        final app = appointments[i];
        final rowIndex = i + 4;

        sheet
            .cell(
              excel_pkg.CellIndex.indexByColumnRow(
                columnIndex: 0,
                rowIndex: rowIndex,
              ),
            )
            .value = excel_pkg.TextCellValue(
          app.userId,
        );
        sheet
            .cell(
              excel_pkg.CellIndex.indexByColumnRow(
                columnIndex: 1,
                rowIndex: rowIndex,
              ),
            )
            .value = excel_pkg.TextCellValue(
          app.studentName,
        );
        sheet
            .cell(
              excel_pkg.CellIndex.indexByColumnRow(
                columnIndex: 2,
                rowIndex: rowIndex,
              ),
            )
            .value = excel_pkg.TextCellValue(
          app.formattedDate,
        );
        sheet
            .cell(
              excel_pkg.CellIndex.indexByColumnRow(
                columnIndex: 3,
                rowIndex: rowIndex,
              ),
            )
            .value = excel_pkg.TextCellValue(
          app.appointedTime,
        );
        sheet
            .cell(
              excel_pkg.CellIndex.indexByColumnRow(
                columnIndex: 4,
                rowIndex: rowIndex,
              ),
            )
            .value = excel_pkg.TextCellValue(
          app.methodType ?? '',
        );
        sheet
            .cell(
              excel_pkg.CellIndex.indexByColumnRow(
                columnIndex: 5,
                rowIndex: rowIndex,
              ),
            )
            .value = excel_pkg.TextCellValue(
          app.consultationType,
        );
        sheet
            .cell(
              excel_pkg.CellIndex.indexByColumnRow(
                columnIndex: 6,
                rowIndex: rowIndex,
              ),
            )
            .value = excel_pkg.TextCellValue(
          app.sessionTypeDisplay,
        );
        sheet
            .cell(
              excel_pkg.CellIndex.indexByColumnRow(
                columnIndex: 7,
                rowIndex: rowIndex,
              ),
            )
            .value = excel_pkg.TextCellValue(
          app.purpose,
        );
        sheet
            .cell(
              excel_pkg.CellIndex.indexByColumnRow(
                columnIndex: 8,
                rowIndex: rowIndex,
              ),
            )
            .value = excel_pkg.TextCellValue(
          app.counselorName,
        );
        sheet
            .cell(
              excel_pkg.CellIndex.indexByColumnRow(
                columnIndex: 9,
                rowIndex: rowIndex,
              ),
            )
            .value = excel_pkg.TextCellValue(
          app.status.toLowerCase(),
        );
      }

      // Set column widths
      sheet.setColumnWidth(0, 12);
      sheet.setColumnWidth(1, 24);
      sheet.setColumnWidth(2, 10);
      sheet.setColumnWidth(3, 18);
      sheet.setColumnWidth(4, 15);
      sheet.setColumnWidth(5, 22);
      sheet.setColumnWidth(6, 18);
      sheet.setColumnWidth(7, 30);
      sheet.setColumnWidth(8, 25);
      sheet.setColumnWidth(9, 12);

      final directory = await getApplicationDocumentsDirectory();
      final file = File(
        '${directory.path}/appointment_report_${DateTime.now().millisecondsSinceEpoch}.xlsx',
      );

      final bytes = excelFile.encode();
      if (bytes != null) {
        await file.writeAsBytes(bytes);
        await OpenFile.open(file.path);

        // Track export activity
        await _trackExportActivity();
      } else {
        throw Exception('Failed to encode Excel file');
      }
    } catch (e) {
      debugPrint('Error exporting Excel: $e');
      _setError('Failed to export Excel: $e');
    } finally {
      _setExporting(false);
    }
  }

  Future<void> _trackExportActivity() async {
    try {
      final session = Session();
      final url =
          '${ApiConfig.currentBaseUrl}/counselor/appointments/track-export';
      await session.post(url, body: {'export_type': 'appointments_report'});
    } catch (e) {
      debugPrint('Error tracking export activity: $e');
    }
  }

  List<AppointmentReportItem> _getFilteredAppointmentsForExport(
    ExportFilters? filters,
  ) {
    List<AppointmentReportItem> appointments = List.from(_filteredAppointments);

    if (filters != null) {
      if (filters.startDate != null) {
        appointments = appointments.where((app) {
          return app.appointedDate.compareTo(filters.startDate!) >= 0;
        }).toList();
      }

      if (filters.endDate != null) {
        appointments = appointments.where((app) {
          return app.appointedDate.compareTo(filters.endDate!) <= 0;
        }).toList();
      }

      if (filters.studentId != null) {
        appointments = appointments.where((app) {
          return app.userId == filters.studentId;
        }).toList();
      }

      if (filters.course != null) {
        appointments = appointments.where((app) {
          final academic = _studentAcademicMap[app.userId] ?? {};
          return academic['course'] == filters.course;
        }).toList();
      }

      if (filters.yearLevel != null) {
        appointments = appointments.where((app) {
          final academic = _studentAcademicMap[app.userId] ?? {};
          return academic['year_level'] == filters.yearLevel;
        }).toList();
      }
    }

    return appointments;
  }

  String _getReportTitle() {
    switch (_selectedStatus) {
      case AppointmentStatus.approved:
        return 'Approved Consultation Records';
      case AppointmentStatus.rejected:
        return 'Rejected Consultation Records';
      case AppointmentStatus.completed:
        return 'Completed Consultation Records';
      case AppointmentStatus.cancelled:
        return 'Cancelled Consultation Records';
      case AppointmentStatus.followup:
        return 'Follow-up Consultation Records';
      default:
        return 'All Consultation Records';
    }
  }

  String _buildFilterSummary(ExportFilters? filters) {
    final parts = <String>[];

    parts.add('Status: ${_selectedStatus.displayName}');

    if (filters != null) {
      if (filters.startDate != null) {
        parts.add('Start: ${_formatDateForDisplay(filters.startDate!)}');
      }
      if (filters.endDate != null) {
        parts.add('End: ${_formatDateForDisplay(filters.endDate!)}');
      }
      if (filters.studentId != null) {
        parts.add('Student: ${filters.studentId}');
      }
      if (filters.course != null) {
        parts.add('Course: ${filters.course}');
      }
      if (filters.yearLevel != null) {
        parts.add('Year: ${filters.yearLevel}');
      }
    }

    return parts.isEmpty ? 'No additional filters applied' : parts.join(' | ');
  }

  String _formatDateForDisplay(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final months = [
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
      return '${months[date.month - 1]} ${date.day}, ${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setExporting(bool exporting) {
    _isExporting = exporting;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }
}
