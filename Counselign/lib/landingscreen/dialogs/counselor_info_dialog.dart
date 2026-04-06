import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../widgets/psgc_address_picker.dart';

class CounselorInfoDialog extends StatefulWidget {
  final String counselorId;
  final String name;
  final String degree;
  final String email;
  final String contact;
  final String address;
  final String birthdate;
  final String? civilStatus;
  final String? sex;
  final ValueChanged<String?> onCivilStatusChanged;
  final ValueChanged<String?> onSexChanged;
  final String warning;
  final bool isLoading;
  final ValueChanged<String>? onAddressChanged;
  final VoidCallback onSavePressed;
  final VoidCallback onCancelPressed;

  const CounselorInfoDialog({
    super.key,
    required this.counselorId,
    required this.name,
    required this.degree,
    required this.email,
    required this.contact,
    required this.address,
    required this.birthdate,
    required this.civilStatus,
    required this.sex,
    required this.onCivilStatusChanged,
    required this.onSexChanged,
    required this.warning,
    required this.isLoading,
    required this.onSavePressed,
    required this.onCancelPressed,
    this.onAddressChanged,
  });

  @override
  State<CounselorInfoDialog> createState() => _CounselorInfoDialogState();
}

class _CounselorInfoDialogState extends State<CounselorInfoDialog> {
  late TextEditingController _counselorIdController;
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _miController;
  late TextEditingController _degreeController;
  late TextEditingController _emailController;
  late TextEditingController _contactController;
  late TextEditingController _birthdateController;
  String _address = '';
  String? _selectedCivilStatus;
  String? _selectedSex;

  @override
  void initState() {
    super.initState();
    _counselorIdController = TextEditingController(text: widget.counselorId);
    _degreeController = TextEditingController(text: widget.degree);
    _emailController = TextEditingController(text: widget.email);
    _contactController = TextEditingController(text: widget.contact);
    _birthdateController = TextEditingController(text: widget.birthdate);
    _selectedCivilStatus = widget.civilStatus;
    _selectedSex = widget.sex;
    _address = widget.address;

    // Split name into parts
    final nameParts = widget.name.trim().split(RegExp(r'\s+'));
    if (nameParts.length >= 3) {
      _firstNameController = TextEditingController(text: nameParts[0]);
      _miController = TextEditingController(
        text: nameParts.sublist(1, nameParts.length - 1).join(' '),
      );
      _lastNameController = TextEditingController(text: nameParts.last);
    } else if (nameParts.length == 2) {
      _firstNameController = TextEditingController(text: nameParts[0]);
      _lastNameController = TextEditingController(text: nameParts[1]);
      _miController = TextEditingController();
    } else {
      _firstNameController = TextEditingController(text: widget.name);
      _lastNameController = TextEditingController();
      _miController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _counselorIdController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _miController.dispose();
    _degreeController.dispose();
    _emailController.dispose();
    _contactController.dispose();
    _birthdateController.dispose();
    super.dispose();
  }

  String get _fullName {
    final fn = _firstNameController.text.trim();
    final ln = _lastNameController.text.trim();
    final mi = _miController.text.trim();
    if (mi.isEmpty) return '$fn $ln'.trim();
    return '$fn $mi $ln'.trim();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Counselor Information'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _counselorIdController,
              decoration: const InputDecoration(labelText: 'Counselor ID'),
              readOnly: true,
            ),
            const SizedBox(height: 12),
            // Name fields row
            Row(
              children: [
                Expanded(
                  flex: 5,
                  child: TextField(
                    controller: _firstNameController,
                    decoration: const InputDecoration(labelText: 'First Name'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _miController,
                    decoration: const InputDecoration(labelText: 'M.I.'),
                    maxLength: 3,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 5,
                  child: TextField(
                    controller: _lastNameController,
                    decoration: const InputDecoration(labelText: 'Last Name'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _degreeController,
              decoration: const InputDecoration(
                labelText: 'Degree (e.g., RGC, RPm)',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              readOnly: true,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _contactController,
              decoration: const InputDecoration(
                labelText: 'Contact Number (09XXXXXXXXX)',
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            // PSGC Address Picker
            PsgcAddressPicker(
              initialAddress: widget.address.isNotEmpty ? widget.address : null,
              label: 'Address',
              onChanged: (address) {
                setState(() => _address = address);
                widget.onAddressChanged?.call(address);
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _birthdateController,
              decoration: InputDecoration(
                labelText: 'Birthdate (YYYY-MM-DD, optional)',
                hintText: 'YYYY-MM-DD',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () async {
                    final now = DateTime.now();
                    final initial =
                        _parseYyyyMmDd(_birthdateController.text) ??
                        DateTime(now.year - 18, now.month, now.day);
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: initial,
                      firstDate: DateTime(1900, 1, 1),
                      lastDate: now,
                    );
                    if (picked != null) {
                      final y = picked.year.toString().padLeft(4, '0');
                      final m = picked.month.toString().padLeft(2, '0');
                      final d = picked.day.toString().padLeft(2, '0');
                      _birthdateController.text = '$y-$m-$d';
                    }
                  },
                ),
              ),
              keyboardType: TextInputType.datetime,
              inputFormatters: const [_YyyyMmDdFormatter()],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    isExpanded: true,
                    initialValue: _selectedCivilStatus?.isEmpty == true
                        ? null
                        : _selectedCivilStatus,
                    items: const [
                      DropdownMenuItem(value: '', child: Text('Select')),
                      DropdownMenuItem(value: 'Single', child: Text('Single')),
                      DropdownMenuItem(
                        value: 'Married',
                        child: Text('Married'),
                      ),
                      DropdownMenuItem(
                        value: 'Widowed',
                        child: Text('Widowed'),
                      ),
                      DropdownMenuItem(
                        value: 'Legally Separated',
                        child: Text('Legally Separated'),
                      ),
                      DropdownMenuItem(
                        value: 'Annulled',
                        child: Text('Annulled'),
                      ),
                    ],
                    decoration: const InputDecoration(
                      labelText: 'Civil Status (optional)',
                    ),
                    onChanged: (value) {
                      setState(() => _selectedCivilStatus = value);
                      widget.onCivilStatusChanged(value);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    isExpanded: true,
                    initialValue: _selectedSex?.isEmpty == true
                        ? null
                        : _selectedSex,
                    items: const [
                      DropdownMenuItem(value: '', child: Text('Select')),
                      DropdownMenuItem(value: 'Male', child: Text('Male')),
                      DropdownMenuItem(value: 'Female', child: Text('Female')),
                    ],
                    decoration: const InputDecoration(
                      labelText: 'Sex (optional)',
                    ),
                    onChanged: (value) {
                      setState(() => _selectedSex = value);
                      widget.onSexChanged(value);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (widget.warning.isNotEmpty)
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  widget.warning,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: widget.isLoading ? null : widget.onCancelPressed,
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: widget.isLoading
              ? null
              : () {
                  // Update controllers with current values before saving
                  widget.onSavePressed();
                },
          child: widget.isLoading
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Save Information'),
        ),
      ],
    );
  }

  DateTime? _parseYyyyMmDd(String input) {
    final parts = input.split('-');
    if (parts.length != 3) return null;
    try {
      return DateTime(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      );
    } catch (_) {
      return null;
    }
  }

  // Getters for parent to retrieve values
  String get firstName => _firstNameController.text.trim();
  String get lastName => _lastNameController.text.trim();
  String get middleInitial => _miController.text.trim();
  String get fullName => _fullName;
  String get degree => _degreeController.text.trim();
  String get email => _emailController.text.trim();
  String get contact => _contactController.text.trim();
  String get address => _address;
  String get birthdate => _birthdateController.text.trim();
}

class _YyyyMmDdFormatter extends TextInputFormatter {
  const _YyyyMmDdFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(RegExp(r'[^0-9-]'), '');
    if (text.length > 10) return oldValue;
    // Auto-insert dashes
    if (text.length == 4 && !text.contains('-')) {
      return TextEditingValue(text: '$text-');
    }
    if (text.length == 7 && text[7] != '-') {
      return TextEditingValue(
        text: '${text.substring(0, 7)}-${text.substring(7)}',
      );
    }
    return TextEditingValue(text: text);
  }
}
