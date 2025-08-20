import 'package:flutter/material.dart';

class CountryCodePicker extends StatefulWidget {
  final String initialValue;
  final ValueChanged<String> onChanged;

  const CountryCodePicker({
    super.key,
    this.initialValue = '+91',
    required this.onChanged,
  });

  @override
  State<CountryCodePicker> createState() => _CountryCodePickerState();
}

class _CountryCodePickerState extends State<CountryCodePicker> {
  late String _selectedCode;

  final List<Map<String, String>> countryCodes = [
    {'code': '+1', 'country': 'US', 'name': 'United States'},
    {'code': '+91', 'country': 'IN', 'name': 'India'},
    {'code': '+44', 'country': 'GB', 'name': 'United Kingdom'},
    {'code': '+61', 'country': 'AU', 'name': 'Australia'},
    {'code': '+81', 'country': 'JP', 'name': 'Japan'},
    {'code': '+86', 'country': 'CN', 'name': 'China'},
    {'code': '+49', 'country': 'DE', 'name': 'Germany'},
    {'code': '+33', 'country': 'FR', 'name': 'France'},
    {'code': '+7', 'country': 'RU', 'name': 'Russia'},
    {'code': '+971', 'country': 'AE', 'name': 'UAE'},
    {'code': '+966', 'country': 'SA', 'name': 'Saudi Arabia'},
    {'code': '+65', 'country': 'SG', 'name': 'Singapore'},
    {'code': '+82', 'country': 'KR', 'name': 'South Korea'},
    {'code': '+34', 'country': 'ES', 'name': 'Spain'},
    {'code': '+39', 'country': 'IT', 'name': 'Italy'},
    {'code': '+20', 'country': 'EG', 'name': 'Egypt'},
    {'code': '+27', 'country': 'ZA', 'name': 'South Africa'},
    {'code': '+62', 'country': 'ID', 'name': 'Indonesia'},
    {'code': '+60', 'country': 'MY', 'name': 'Malaysia'},
    {'code': '+66', 'country': 'TH', 'name': 'Thailand'},
  ];

  @override
  void initState() {
    super.initState();
    _selectedCode = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButton<String>(
        value: _selectedCode,
        isExpanded: true,
        underline: const SizedBox(),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        items: countryCodes.map((country) {
          return DropdownMenuItem<String>(
            value: country['code'],
            child: Text(
              '${country['code']} (${country['country']})',
              style: const TextStyle(fontSize: 14),
            ),
          );
        }).toList(),
        onChanged: (value) {
          if (value != null) {
            setState(() {
              _selectedCode = value;
            });
            widget.onChanged(value);
          }
        },
      ),
    );
  }
}
