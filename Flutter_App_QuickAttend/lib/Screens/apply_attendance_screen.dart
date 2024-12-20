import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'on_duty_form.dart';
import 'leave_form.dart';
import '../Services/socket_service.dart';

class ApplyAttendanceScreen extends StatefulWidget {
  // GlobalKey to access HomeScreenState
  const ApplyAttendanceScreen({super.key});

  @override
  State<ApplyAttendanceScreen> createState() => _ApplyAttendanceScreenState();
}

class _ApplyAttendanceScreenState extends State<ApplyAttendanceScreen>
    with SingleTickerProviderStateMixin {
  final FlutterSecureStorage storage = const FlutterSecureStorage();
  Map<String, dynamic>? userData;
  late TabController _tabController;
  final TextEditingController _employeeIdController = TextEditingController();
  DateTime? _selectedDate; // To store the selected date

  @override
  void initState() {
    super.initState();
    _loadUserDetails();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _employeeIdController.dispose();
    super.dispose();
  }

  Future<void> _loadUserDetails() async {
    final userJson = await storage.read(key: 'user');
    if (userJson != null) {
      try {
        final userMap = jsonDecode(userJson) as Map<String, dynamic>;
        setState(() {
          userData = userMap;
        });
      } catch (e) {
        debugPrint('Error decoding userJson: $e');
      }
    }
  }

  Future<void> _pickDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
          ),
        title: const Text("Apply Attendance"),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "On Duty"),
            Tab(text: "Leave"),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _employeeIdController,
              decoration: const InputDecoration(
                labelText: "Employee ID",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),

            // Date Picker Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                //const Text(
                //  "Selected Date:",
                //  style: TextStyle(fontSize: 16),
                //),
                //Text(
                //  _selectedDate != null ? _selectedDate!.toLocal().toString().split(' ')[0]
                //      : "No Date Selected",
                //  style: const TextStyle(
                //      fontSize: 16, fontWeight: FontWeight.bold),
                //),
                ElevatedButton(
                  onPressed: _pickDate,
                  child: const Text("Pick Date"),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Tab Views for Leave and On Duty
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  OnDutyForm(
                    selectedDay: _selectedDate,
                    rangeStart: null,
                    rangeEnd: null,
                    isRangeEnabled: false,
                    onToggleMode: (mode) {
                      // Handle range toggle (optional for on-duty attendance)
                    },
                    onAttendanceApplied: () {
                      // Handle on-duty form submission
                      SocketService().emit('apply_attendance', (userData?['employeeId']));
                    },
                  ),
                  LeaveForm(
                    selectedDay: _selectedDate,
                    rangeStart: null,
                    rangeEnd: null,
                    isRangeEnabled: false,
                    onToggleMode: (mode) {
                      // Handle range toggle (optional for on-duty attendance)
                    },
                    onAttendanceApplied: () {
                      // Handle on-duty form submission
                      SocketService().emit('apply_attendance', (userData?['employeeId']));
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
