import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../api/config.dart';
import '../models/announcement.dart';

class AnnouncementsViewModel extends ChangeNotifier {
  // Data
  List<Announcement> _announcements = [];
  List<Announcement> get announcements => _announcements;

  // Filtered announcements (after search/filter)
  List<Announcement> _filteredAnnouncements = [];
  List<Announcement> get filteredAnnouncements => _filteredAnnouncements;

  // Loading states
  bool _isLoading = true;
  bool get isLoading => _isLoading;

  bool _isSaving = false;
  bool get isSaving => _isSaving;

  // Search and filter
  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  String _typeFilter = 'all';
  String get typeFilter => _typeFilter;

  // Form data
  String _title = '';
  String get title => _title;

  String _content = '';
  String get content => _content;

  String _type = 'announcement';
  String get type => _type;

  void setTitle(String title) {
    _title = title;
    notifyListeners();
  }

  void setContent(String content) {
    _content = content;
    notifyListeners();
  }

  void setType(String type) {
    _type = type;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _filterAnnouncements();
    notifyListeners();
  }

  void setTypeFilter(String filter) {
    _typeFilter = filter;
    _filterAnnouncements();
    notifyListeners();
  }

  void _filterAnnouncements() {
    _filteredAnnouncements = _announcements.where((announcement) {
      // Search filter
      final matchesSearch =
          _searchQuery.isEmpty ||
          announcement.title.toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ) ||
          announcement.content.toLowerCase().contains(
            _searchQuery.toLowerCase(),
          );

      // Type filter
      final matchesType =
          _typeFilter == 'all' ||
          announcement.type.toLowerCase() == _typeFilter.toLowerCase();

      return matchesSearch && matchesType;
    }).toList();
  }

  Future<void> fetchAnnouncements() async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await http.get(
        Uri.parse('${ApiConfig.currentBaseUrl}/admin/announcements'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          _announcements =
              (data['announcements'] as List?)
                  ?.map((a) => Announcement.fromJson(a))
                  .toList() ??
              [];

          _filterAnnouncements();
        }
      }
    } catch (e) {
      debugPrint('Error fetching announcements: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createAnnouncement() async {
    try {
      _isSaving = true;
      notifyListeners();

      final response = await http.post(
        Uri.parse('${ApiConfig.currentBaseUrl}/admin/announcements/create'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'title': _title,
          'content': _content,
          'type': _type,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          _title = '';
          _content = '';
          _type = 'announcement';
          await fetchAnnouncements();
          return true;
        }
      }
      return false;
    } catch (e) {
      debugPrint('Error creating announcement: $e');
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> updateAnnouncement(int id) async {
    try {
      _isSaving = true;
      notifyListeners();

      final response = await http.put(
        Uri.parse('${ApiConfig.currentBaseUrl}/admin/announcements/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'title': _title,
          'content': _content,
          'type': _type,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          _title = '';
          _content = '';
          _type = 'announcement';
          await fetchAnnouncements();
          return true;
        }
      }
      return false;
    } catch (e) {
      debugPrint('Error updating announcement: $e');
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> deleteAnnouncement(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.currentBaseUrl}/admin/announcements/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          await fetchAnnouncements();
          return true;
        }
      }
      return false;
    } catch (e) {
      debugPrint('Error deleting announcement: $e');
      return false;
    }
  }

  void loadAnnouncementForEdit(Announcement announcement) {
    _title = announcement.title;
    _content = announcement.content;
    _type = announcement.type;
    notifyListeners();
  }

  void clearForm() {
    _title = '';
    _content = '';
    _type = 'announcement';
    notifyListeners();
  }

  void initialize() {
    fetchAnnouncements();
  }
}
