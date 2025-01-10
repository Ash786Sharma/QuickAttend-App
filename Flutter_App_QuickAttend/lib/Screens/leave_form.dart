import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../services/api_service.dart';
//import '../Widgets/custom_text_field.dart';
import '../Widgets/custom_button.dart';

// Placeholder for On-Duty form
class LeaveForm extends StatefulWidget {
  final DateTime? selectedDay;
  final DateTime? rangeStart;
  final DateTime? rangeEnd;
  final bool isRangeEnabled; // New property to enable/disable range selection
  final ValueChanged<RangeSelectionMode> onToggleMode;
  final VoidCallback onAttendanceApplied; // New callback

  const LeaveForm({super.key, required this.selectedDay, 
  required this.rangeStart, 
  required this.rangeEnd,  
  required this.isRangeEnabled, // Pass the range enable/disable state
  required this.onToggleMode, 
  required this.onAttendanceApplied
  });

  @override
  State<LeaveForm> createState() => _LeaveFormState();
}

class _LeaveFormState extends State<LeaveForm> {
  bool isRangeMode = false; // Switch between single and range selection
  bool isLoading = false;

  // Show a SnackBar with a custom message
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
  
  String? _selectedLeaveType;
  final TextEditingController _approverNameController = TextEditingController();
  final TextEditingController _remarkController = TextEditingController();

  final List<String> predefinedLeaveTypes = [
    "PL",
    "C-Off",
    "CL",
    "SL",
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
    // Form validation
    if (_selectedLeaveType == null ||
        _approverNameController.text.isEmpty ||
        _remarkController.text.isEmpty ||
        (!isRangeMode && widget.selectedDay == null) ||
        (isRangeMode && (widget.rangeStart == null || widget.rangeEnd == null))) {
      _showSnackBar('Please fill in all required fields');
      setState(() => isLoading = false);
      return;
    }

    // Prepare API data
    final data = {
      "date": isRangeMode
          ? "${widget.rangeStart!.toIso8601String().split('T')[0]} - ${widget.rangeEnd!.toIso8601String().split('T')[0]}"
          : widget.selectedDay!.toIso8601String().split('T')[0],
      "status": "leave",
      "leaveType": _selectedLeaveType,
      "approverName": _approverNameController.text,
      "remark": _remarkController.text,
    };

    try {
      // Call API
      //debugPrint('$data');
      final response = await ApiService.post('/attendance/apply', data);
      if (response['success'] == true) {
        _showSnackBar(response['message'] ?? 'Attendance applied successfully!');
        _selectedLeaveType = null;
        _approverNameController.clear();
        _remarkController.clear();
        widget.onAttendanceApplied();
      } else {
        _showSnackBar('Error: ${response['error']}, Try again!');
      }
    } catch (e) {
      debugPrint('Error submitting leave application: $e');
      _showSnackBar('Error: ${e.toString()}');
    }finally {
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
          if(widget.isRangeEnabled)
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
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
            ),
            Text(
              'Range End: ${widget.rangeEnd?.toLocal().toString().split(' ')[0] ?? "Not Selected"}',
              style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
            ),
          ] else ...[
            Text(
              'Selected Date: ${widget.selectedDay?.toLocal().toString().split(' ')[0] ?? "Not Selected"}',
              style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
            ),
          ],
          const SizedBox(height: 20),

          // Dropdown for Location
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(labelText: 'Leave Type'),
            value: _selectedLeaveType,
            items: predefinedLeaveTypes.map((leaveType) {
              return DropdownMenuItem(value: leaveType, child: Text(leaveType));
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedLeaveType = value;
              });
            },
          ),
          const SizedBox(height: 20),
          // Project Code Input
          TextFormField(
            controller: _approverNameController,
            decoration: const InputDecoration(labelText: 'Approver Name'),
          ),

          const SizedBox(height: 20),
          // Remark Input
          TextFormField(
            controller: _remarkController,
            decoration: const InputDecoration(labelText: 'Remark'),
            //maxLines: 3,
          ),

          const SizedBox(height: 20),
          // Submit Button
          Center(
            child: SizedBox(
              width: 200,
              child: CustomButton(label: 'Apply Leave', 
            onPressed: _submitForm, 
            isLoading: isLoading
            ),
            )
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}