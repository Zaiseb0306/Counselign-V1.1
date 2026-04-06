import 'dart:convert';
import 'package:http/http.dart' as http;

/// Represents a PSGC geographic entity (region, province, city, barangay)
class PsgcEntity {
  final String code;
  final String name;

  PsgcEntity({required this.code, required this.name});

  factory PsgcEntity.fromJson(Map<String, dynamic> json) {
    return PsgcEntity(
      code: json['code']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
    );
  }

  @override
  String toString() => name;
}

/// Service for fetching Philippine Standard Geographic Code (PSGC) data
/// Uses the PSGC API: https://psgc.gitlab.io/api/
class PsgcService {
  static const String _baseUrl = 'https://psgc.gitlab.io/api';

  final http.Client _client;

  PsgcService({http.Client? client}) : _client = client ?? http.Client();

  /// Fetch all regions
  Future<List<PsgcEntity>> getRegions() async {
    final response = await _client.get(Uri.parse('$_baseUrl/regions/'));
    if (response.statusCode != 200) {
      throw Exception('Failed to load regions: ${response.statusCode}');
    }
    final List<dynamic> data = json.decode(response.body);
    return data.map((e) => PsgcEntity.fromJson(e)).toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  /// Fetch provinces for a given region code
  Future<List<PsgcEntity>> getProvinces(String regionCode) async {
    final response = await _client.get(
      Uri.parse('$_baseUrl/regions/$regionCode/provinces/'),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to load provinces: ${response.statusCode}');
    }
    final List<dynamic> data = json.decode(response.body);
    if (data.isEmpty) return [];
    return data.map((e) => PsgcEntity.fromJson(e)).toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  /// Fetch cities/municipalities for a given province code
  Future<List<PsgcEntity>> getCities(String provinceCode) async {
    final response = await _client.get(
      Uri.parse('$_baseUrl/provinces/$provinceCode/cities-municipalities/'),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to load cities: ${response.statusCode}');
    }
    final List<dynamic> data = json.decode(response.body);
    return data.map((e) => PsgcEntity.fromJson(e)).toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  /// Fetch cities/municipalities for a region (for NCR which has no provinces)
  Future<List<PsgcEntity>> getCitiesByRegion(String regionCode) async {
    final response = await _client.get(
      Uri.parse('$_baseUrl/regions/$regionCode/cities-municipalities/'),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to load cities: ${response.statusCode}');
    }
    final List<dynamic> data = json.decode(response.body);
    return data.map((e) => PsgcEntity.fromJson(e)).toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  /// Fetch barangays for a given city/municipality code
  Future<List<PsgcEntity>> getBarangays(String cityCode) async {
    final response = await _client.get(
      Uri.parse('$_baseUrl/cities-municipalities/$cityCode/barangays/'),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to load barangays: ${response.statusCode}');
    }
    final List<dynamic> data = json.decode(response.body);
    return data.map((e) => PsgcEntity.fromJson(e)).toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  /// Build a full address string from components
  /// Format: "Street, Barangay, City, Province, Region" (street optional)
  static String buildAddress({
    String? street,
    PsgcEntity? region,
    PsgcEntity? province,
    PsgcEntity? city,
    PsgcEntity? barangay,
  }) {
    final parts = <String>[];
    if (street != null && street.trim().isNotEmpty) {
      parts.add(street.trim());
    }
    if (barangay != null) parts.add(barangay.name);
    if (city != null) parts.add(city.name);
    if (province != null && province.code != 'N/A') {
      parts.add(province.name);
    }
    if (region != null) parts.add(region.name);
    return parts.join(', ');
  }

  /// Parse a stored address string back into components
  /// Returns a map with keys: street, barangay, city, province, region
  static Map<String, String?> parseAddress(String address) {
    if (address.isEmpty) {
      return {'street': null, 'barangay': null, 'city': null, 'province': null, 'region': null};
    }
    final parts = address.split(',').map((s) => s.trim()).toList();
    if (parts.length >= 5) {
      return {
        'street': parts[0],
        'barangay': parts[1],
        'city': parts[2],
        'province': parts[3],
        'region': parts[4],
      };
    } else if (parts.length >= 4) {
      return {
        'street': null,
        'barangay': parts[0],
        'city': parts[1],
        'province': parts[2],
        'region': parts[3],
      };
    }
    return {'street': null, 'barangay': null, 'city': null, 'province': null, 'region': null};
  }

  void dispose() {
    _client.close();
  }
}
