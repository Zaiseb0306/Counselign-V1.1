import 'package:flutter/material.dart';
import '../services/psgc_service.dart';

/// A reusable cascading dropdown for Philippine addresses using PSGC data.
///
/// Usage:
///   PsgcAddressPicker(
///     initialAddress: '123 St, Brgy, City, Province, Region',
///     onChanged: (fullAddress) { ... },
///   )
class PsgcAddressPicker extends StatefulWidget {
  final String? initialAddress;
  final ValueChanged<String> onChanged;
  final String? streetHint;
  final String? label;

  const PsgcAddressPicker({
    super.key,
    this.initialAddress,
    required this.onChanged,
    this.streetHint,
    this.label,
  });

  @override
  State<PsgcAddressPicker> createState() => _PsgcAddressPickerState();
}

class _PsgcAddressPickerState extends State<PsgcAddressPicker> {
  final PsgcService _service = PsgcService();

  List<PsgcEntity> _regions = [];
  List<PsgcEntity> _provinces = [];
  List<PsgcEntity> _cities = [];
  List<PsgcEntity> _barangays = [];

  PsgcEntity? _selectedRegion;
  PsgcEntity? _selectedProvince;
  PsgcEntity? _selectedCity;
  PsgcEntity? _selectedBarangay;
  final TextEditingController _streetController = TextEditingController();

  bool _isLoadingRegions = true;
  bool _isLoadingProvinces = false;
  bool _isLoadingCities = false;
  bool _isLoadingBarangays = false;

  @override
  void initState() {
    super.initState();
    _loadRegions();
    if (widget.initialAddress != null && widget.initialAddress!.isNotEmpty) {
      _restoreFromAddress(widget.initialAddress!);
    }
  }

  @override
  void dispose() {
    _streetController.dispose();
    _service.dispose();
    super.dispose();
  }

  Future<void> _loadRegions() async {
    try {
      final regions = await _service.getRegions();
      if (mounted) {
        setState(() {
          _regions = regions;
          _isLoadingRegions = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading regions: $e');
      if (mounted) {
        setState(() => _isLoadingRegions = false);
      }
    }
  }

  Future<void> _restoreFromAddress(String address) async {
    final parsed = PsgcService.parseAddress(address);
    if (parsed['region'] == null) return;

    // Find matching region
    PsgcEntity? matchedRegion;
    for (final r in _regions) {
      if (r.name.toLowerCase().contains(parsed['region']!.toLowerCase())) {
        matchedRegion = r;
        break;
      }
    }
    if (matchedRegion == null) return;

    if (mounted) {
      setState(() {
        _selectedRegion = matchedRegion;
        _streetController.text = parsed['street'] ?? '';
      });
    }

    // Load provinces and find match
    try {
      final provinces = await _service.getProvinces(matchedRegion.code);
      if (mounted) {
        setState(() => _provinces = provinces);
      }
      PsgcEntity? matchedProvince;
      for (final p in provinces) {
        if (p.name.toLowerCase().contains(parsed['province']!.toLowerCase())) {
          matchedProvince = p;
          break;
        }
      }
      if (matchedProvince == null && parsed['province'] != null) {
        // Try loading cities directly (NCR case)
        final citiesByRegion = await _service.getCitiesByRegion(
          matchedRegion.code,
        );
        if (mounted) {
          setState(() => _cities = citiesByRegion);
        }
        PsgcEntity? matchedCity;
        for (final c in citiesByRegion) {
          if (c.name.toLowerCase().contains(parsed['city']!.toLowerCase())) {
            matchedCity = c;
            break;
          }
        }
        if (matchedCity != null && mounted) {
          setState(() {
            _selectedCity = matchedCity;
            _isLoadingCities = false;
          });
          final barangays = await _service.getBarangays(matchedCity.code);
          if (mounted) {
            setState(() => _barangays = barangays);
          }
          PsgcEntity? matchedBarangay;
          for (final b in barangays) {
            if (b.name.toLowerCase().contains(
              parsed['barangay']!.toLowerCase(),
            )) {
              matchedBarangay = b;
              break;
            }
          }
          if (matchedBarangay != null && mounted) {
            setState(() => _selectedBarangay = matchedBarangay);
          }
          _notifyChange();
        }
        return;
      }
      if (matchedProvince == null) return;
      setState(() => _selectedProvince = matchedProvince);
      final cities = await _service.getCities(matchedProvince.code);
      if (mounted) {
        setState(() => _cities = cities);
      }
      PsgcEntity? matchedCity;
      for (final c in cities) {
        if (c.name.toLowerCase().contains(parsed['city']!.toLowerCase())) {
          matchedCity = c;
          break;
        }
      }
      if (matchedCity == null) return;
      setState(() => _selectedCity = matchedCity);
      final barangays = await _service.getBarangays(matchedCity.code);
      if (mounted) {
        setState(() => _barangays = barangays);
      }
      PsgcEntity? matchedBarangay;
      for (final b in barangays) {
        if (b.name.toLowerCase().contains(parsed['barangay']!.toLowerCase())) {
          matchedBarangay = b;
          break;
        }
      }
      if (matchedBarangay != null && mounted) {
        setState(() => _selectedBarangay = matchedBarangay);
      }
      _notifyChange();
    } catch (e) {
      debugPrint('Error restoring address: $e');
    }
  }

  void _notifyChange() {
    final address = PsgcService.buildAddress(
      street: _streetController.text,
      region: _selectedRegion,
      province: _selectedProvince,
      city: _selectedCity,
      barangay: _selectedBarangay,
    );
    widget.onChanged(address);
  }

  Future<void> _onRegionChanged(PsgcEntity? region) async {
    setState(() {
      _selectedRegion = region;
      _selectedProvince = null;
      _selectedCity = null;
      _selectedBarangay = null;
      _provinces = [];
      _cities = [];
      _barangays = [];
    });
    if (region == null) {
      _notifyChange();
      return;
    }
    setState(() => _isLoadingProvinces = true);
    try {
      final provinces = await _service.getProvinces(region.code);
      if (provinces.isEmpty) {
        // NCR or similar - load cities directly from region
        final cities = await _service.getCitiesByRegion(region.code);
        if (mounted) {
          setState(() {
            _cities = cities;
            _isLoadingProvinces = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _provinces = provinces;
            _isLoadingProvinces = false;
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading provinces: $e');
      if (mounted) setState(() => _isLoadingProvinces = false);
    }
    _notifyChange();
  }

  Future<void> _onProvinceChanged(PsgcEntity? province) async {
    setState(() {
      _selectedProvince = province;
      _selectedCity = null;
      _selectedBarangay = null;
      _cities = [];
      _barangays = [];
    });
    if (province == null) {
      _notifyChange();
      return;
    }
    setState(() => _isLoadingCities = true);
    try {
      final cities = await _service.getCities(province.code);
      if (mounted) {
        setState(() {
          _cities = cities;
          _isLoadingCities = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading cities: $e');
      if (mounted) setState(() => _isLoadingCities = false);
    }
    _notifyChange();
  }

  Future<void> _onCityChanged(PsgcEntity? city) async {
    setState(() {
      _selectedCity = city;
      _selectedBarangay = null;
      _barangays = [];
    });
    if (city == null) {
      _notifyChange();
      return;
    }
    setState(() => _isLoadingBarangays = true);
    try {
      final barangays = await _service.getBarangays(city.code);
      if (mounted) {
        setState(() {
          _barangays = barangays;
          _isLoadingBarangays = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading barangays: $e');
      if (mounted) setState(() => _isLoadingBarangays = false);
    }
    _notifyChange();
  }

  void _onBarangayChanged(PsgcEntity? barangay) {
    setState(() => _selectedBarangay = barangay);
    _notifyChange();
  }

  void _onStreetChanged(String value) {
    _notifyChange();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              widget.label!,
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
        // Region dropdown
        DropdownButtonFormField<PsgcEntity>(
          initialValue: _selectedRegion,
          decoration: InputDecoration(
            labelText: 'Region',
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
          ),
          isExpanded: true,
          hint: _isLoadingRegions
              ? const Text('Loading...')
              : const Text('Select Region'),
          items: _regions
              .map(
                (r) => DropdownMenuItem(
                  value: r,
                  child: Text(r.name, overflow: TextOverflow.ellipsis),
                ),
              )
              .toList(),
          onChanged: _isLoadingRegions ? null : _onRegionChanged,
        ),
        const SizedBox(height: 12),
        // Province dropdown
        DropdownButtonFormField<PsgcEntity>(
          initialValue: _selectedProvince,
          decoration: const InputDecoration(
            labelText: 'Province',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          isExpanded: true,
          hint: _isLoadingProvinces
              ? const Text('Loading...')
              : (_provinces.isEmpty && _selectedRegion != null)
              ? const Text('N/A (No Province)')
              : const Text('Select Province'),
          items: _provinces
              .map(
                (p) => DropdownMenuItem(
                  value: p,
                  child: Text(p.name, overflow: TextOverflow.ellipsis),
                ),
              )
              .toList(),
          onChanged: _isLoadingProvinces ? null : _onProvinceChanged,
        ),
        const SizedBox(height: 12),
        // City/Municipality dropdown
        DropdownButtonFormField<PsgcEntity>(
          initialValue: _selectedCity,
          decoration: const InputDecoration(
            labelText: 'City/Municipality',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          isExpanded: true,
          hint: _isLoadingCities
              ? const Text('Loading...')
              : const Text('Select City/Municipality'),
          items: _cities
              .map(
                (c) => DropdownMenuItem(
                  value: c,
                  child: Text(c.name, overflow: TextOverflow.ellipsis),
                ),
              )
              .toList(),
          onChanged: _isLoadingCities ? null : _onCityChanged,
        ),
        const SizedBox(height: 12),
        // Barangay dropdown
        DropdownButtonFormField<PsgcEntity>(
          initialValue: _selectedBarangay,
          decoration: const InputDecoration(
            labelText: 'Barangay',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          isExpanded: true,
          hint: _isLoadingBarangays
              ? const Text('Loading...')
              : const Text('Select Barangay'),
          items: _barangays
              .map(
                (b) => DropdownMenuItem(
                  value: b,
                  child: Text(b.name, overflow: TextOverflow.ellipsis),
                ),
              )
              .toList(),
          onChanged: _isLoadingBarangays ? null : _onBarangayChanged,
        ),
        const SizedBox(height: 12),
        // Street input
        TextField(
          controller: _streetController,
          decoration: InputDecoration(
            labelText: 'Street/Building/Floor/Unit (Optional)',
            hintText: widget.streetHint ?? 'e.g., 123 Main St, Unit 4B',
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
          ),
          onChanged: _onStreetChanged,
        ),
      ],
    );
  }
}
