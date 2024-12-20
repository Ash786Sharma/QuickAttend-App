import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../services/api_service.dart';
import '../Widgets/custom_button.dart';

class OnDutyForm extends StatefulWidget {
  final DateTime? selectedDay;
  final DateTime? rangeStart;
  final DateTime? rangeEnd;
  final bool isRangeEnabled; // New property to enable/disable range selection
  final ValueChanged<RangeSelectionMode> onToggleMode;
  final VoidCallback onAttendanceApplied;

  const OnDutyForm({
    super.key,
    required this.selectedDay,
    required this.rangeStart,
    required this.rangeEnd,
    required this.isRangeEnabled, // Pass the range enable/disable state
    required this.onToggleMode,
    required this.onAttendanceApplied,
  });

  @override
  State<OnDutyForm> createState() => _OnDutyFormState();
}

class _OnDutyFormState extends State<OnDutyForm> {
  bool isRangeMode = false;
  bool isLoading = false;

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  String? _selectedLocation;
  final TextEditingController _projectCodeController = TextEditingController();
  final TextEditingController _remarkController = TextEditingController();

  final List<String> predefinedLocations = [
    "HO",
    "Site A",
    "Site B",
    "Remote Work",
  ];

  @override
  void initState() {
    super.initState();
    isRangeMode = widget.isRangeEnabled &&
        (widget.rangeStart != null || widget.rangeEnd != null);
  }

  void _toggleMode(bool value) {
    if (widget.isRangeEnabled) {
      setState(() {
        isRangeMode = value;
        widget.onToggleMode(
          isRangeMode
              ? RangeSelectionMode.toggledOn
              : RangeSelectionMode.toggledOff,
        );
      });
    }
  }

  void _submitForm() async {
    setState(() => isLoading = true);
    if (_selectedLocation == null ||
        _projectCodeController.text.isEmpty ||
        _remarkController.text.isEmpty ||
        (!isRangeMode && widget.selectedDay == null) ||
        (isRangeMode && (widget.rangeStart == null || widget.rangeEnd == null))) {
      _showSnackBar('Please fill in all required fields');
      setState(() => isLoading = false);
      return;
    }

    final data = {
      "date": isRangeMode
          ? "${widget.rangeStart!.toIso8601String().split('T')[0]} - ${widget.rangeEnd!.toIso8601String().split('T')[0]}"
          : widget.selectedDay!.toIso8601String().split('T')[0],
      "status": "on-duty",
      "location": _selectedLocation,
      "projectName": _projectCodeController.text,
      "remark": _remarkController.text,
    };

    try {
      final response = await ApiService.post('/attendance/apply', data);
      if (response['success'] == true) {
        _showSnackBar(response['message'] ?? 'Attendance applied successfully!');
        widget.onAttendanceApplied();
      } else {
        _showSnackBar('Error: ${response['error']}, Try again!');
      }
    } catch (e) {
      _showSnackBar('Error: ${e.toString()}');
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.isRangeEnabled)
            // Toggle Switch
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Range Selection Mode', style: TextStyle(fontSize: 16)),
                Switch(
                  value: isRangeMode,
                  onChanged: _toggleMode,
                ),
              ],
            ),
          const SizedBox(height: 8),
          // Display selected dates
          if (isRangeMode) ...[
            Text(
              'Range Start: ${widget.rangeStart?.toLocal().toString().split(' ')[0] ?? "Not Selected"}',
              style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue),
            ),
            Text(
              'Range End: ${widget.rangeEnd?.toLocal().toString().split(' ')[0] ?? "Not Selected"}',
              style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue),
            ),
          ] else ...[
            Text(
              'Selected Date: ${widget.selectedDay?.toLocal().toString().split(' ')[0] ?? "Not Selected"}',
              style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue),
            ),
          ],
          const SizedBox(height: 20),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(labelText: 'Location'),
            value: _selectedLocation,
            items: predefinedLocations.map((location) {
              return DropdownMenuItem(value: location, child: Text(location));
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedLocation = value;
              });
            },
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _projectCodeController,
            decoration: const InputDecoration(labelText: 'Project Code'),
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _remarkController,
            decoration: const InputDecoration(labelText: 'Remark'),
          ),
          const SizedBox(height: 20),
          Center(
            child: SizedBox(
              width: 200,
              child: CustomButton(
              label: 'Apply On-Duty',
              onPressed: _submitForm,
              isLoading: isLoading,
            ),
            )
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
