import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/api_service.dart';
import '../Services/socket_service.dart';

class SetHolidayScreen extends StatefulWidget {
  const SetHolidayScreen({super.key});

  @override
  State<SetHolidayScreen> createState() => _SetHolidayScreenState();
}

class _SetHolidayScreenState extends State<SetHolidayScreen> {
  final List<DateTime> _selectedDates = [];
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Show a SnackBar with a custom message
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void initState() {
    super.initState();
    _loadStoredDates();
  }

  Future<void> _loadStoredDates() async {
  try {
    // Check if stored holidays exist
    final storedDates = await _storage.read(key: 'holidays');

    if (storedDates != null) {
      // Parse stored dates and update the UI
      final parsedDates = (storedDates.split(','))
          .map((date) => DateTime.parse(date))
          .toList();
      setState(() {
        _selectedDates.addAll(parsedDates);
      });
    } else {
      // Fetch holiday dates from the database via API
      final response = await ApiService.get('/admin/getHolidays');
      if (response['success'] == true) {
        final fetchedDates = (response['holidays'] as List)
            .map((date) => DateTime.parse(date))
            .toList();

        setState(() {
          _selectedDates.addAll(fetchedDates);
        });

        // Store fetched dates for future use
        _saveDatesToStorage();
      } else {
        _showSnackBar(response['message'] ?? 'Failed to fetch holidays');
      }
    }
  } catch (e) {
    _showSnackBar('Error fetching holidays: ${e.toString()}');
  }
}


  Future<void> _saveDatesToStorage() async {
    final formattedDates = _selectedDates.map((date) => _dateFormat.format(date)).join(',');
    await _storage.write(key: 'holidays', value: formattedDates);
  }

  Future<void> _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null && !_selectedDates.contains(pickedDate)) {
      setState(() {
        _selectedDates.add(pickedDate);
      });
      _saveDatesToStorage(); // Save changes to storage
    }
  }

  void _removeDate(DateTime date) {
    setState(() {
      _selectedDates.remove(date);
    });
    _saveDatesToStorage(); // Save changes to storage
  }

  void _clearAllDates() {
    setState(() {
      _selectedDates.clear();
    });
    _storage.delete(key: 'holidays'); // Clear all stored dates
  }

  Future<void> _submitHolidays() async {
    if (_selectedDates.isEmpty) {
      _showSnackBar('No dates selected to set as holidays');
      return;
    }

    try {
      final formattedDates = _selectedDates.map((date) => _dateFormat.format(date)).toList();
      final response = await ApiService.post('/admin/setHolidays', {'holidays': formattedDates});
      //debugPrint('$response');
      if (response['success'] == true) {
        SocketService().emit('update_WeeklyOffOrHoliday', null);
        _showSnackBar(response['message'] ?? 'Holidays set successfully!');
      } else {
        _showSnackBar('Error: ${response['error']}, Try again!');
      }
    } catch (e) {
      _showSnackBar('Error: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
          ),
        title: const Text('Set Holidays'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ElevatedButton(
                  onPressed: _pickDate,
                  child: const Text('Pick Date'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _clearAllDates,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text('Clear All'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _selectedDates.isEmpty
                  ? const Center(child: Text('No dates added yet.'))
                  : ListView.builder(
                      itemCount: _selectedDates.length,
                      itemBuilder: (context, index) {
                        final date = _selectedDates[index];
                        return Card(
                          child: ListTile(
                            title: Text(_dateFormat.format(date)),
                            trailing: IconButton(
                              icon: const Icon(Icons.close, color: Colors.red),
                              onPressed: () => _removeDate(date),
                            ),
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitHolidays,
                child: const Text('Set Holidays'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
