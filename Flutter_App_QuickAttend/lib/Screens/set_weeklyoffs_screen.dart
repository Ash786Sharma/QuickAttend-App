import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../Services/api_service.dart';
import '../Services/socket_service.dart';

class SetWeeklyOffScreen extends StatefulWidget {
  const SetWeeklyOffScreen({super.key});

  @override
  State<SetWeeklyOffScreen> createState() => _SetWeeklyOffScreenState();
}

class _SetWeeklyOffScreenState extends State<SetWeeklyOffScreen> {
  final List<DateTime> _weeklyOffDates = [];
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Show a SnackBar with a custom message
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void initState() {
    super.initState();
    _loadStoredWeeklyOffDates();
  }

  Future<void> _loadStoredWeeklyOffDates() async {
  final storedDates = await _storage.read(key: 'weeklyOffs');
  if (storedDates != null && storedDates.isNotEmpty) {
    final parsedDates = storedDates.split(',').map((date) => DateTime.parse(date)).toList();
    setState(() {
      _weeklyOffDates.addAll(parsedDates);
    });
    _sortDatesByMonth();
  } else {
    // Call API to fetch weekly offs if local storage is empty
    try {
      final response = await ApiService.get('/admin/getWeeklyOffs');
      if (response['success'] == true && response['weeklyOffs'] != null) {
        final fetchedDates = (response['weeklyOffs'] as List<dynamic>)
            .map((date) => DateTime.parse(date))
            .toList();

        setState(() {
          _weeklyOffDates.addAll(fetchedDates);
        });
        _sortDatesByMonth();
        _saveWeeklyOffDatesToStorage(); // Save fetched data locally
      } else {
        _showSnackBar('Error: ${response['error'] ?? "Failed to fetch weekly offs"}');
      }
    } catch (e) {
      _showSnackBar('Error: ${e.toString()}');
    }
  }
}


  Future<void> _saveWeeklyOffDatesToStorage() async {
    final formattedDates = _weeklyOffDates.map((date) => _dateFormat.format(date)).join(',');
    await _storage.write(key: 'weeklyOffs', value: formattedDates);
  }

  void _sortDatesByMonth() {
    _weeklyOffDates.sort((a, b) => a.compareTo(b));
  }

  Future<void> _addWeeklyOff(DateTime date) async {
    if (!_weeklyOffDates.contains(date)) {
      // Call API to add weekly off
      try {
        final response = await ApiService.post('/admin/addSelectedWeeklyOff', {'date': _dateFormat.format(date)});
        debugPrint('$_dateFormat');
        debugPrint('$response');
        if (response['success'] == true) {
          setState(() {
            _weeklyOffDates.add(date);
          });
          _sortDatesByMonth();
          _saveWeeklyOffDatesToStorage();
          SocketService().emit('update_WeeklyOffOrHoliday', null);
          _showSnackBar(response['message'] ?? 'WeeklyOff updated successfully!');
        } else {
          _showSnackBar('Error: ${response['error']}, Try again!');
        }
      } catch (e) {
        _showSnackBar('Error: ${e.toString()}');
      }
    }
  }

  Future<void> _generateDefaultWeeklyOffs() async {
  try {
    final response = await ApiService.get('/admin/setDefaultWeeklyOffs');
    final settings = response['settings'];

    if (response['success'] == true && settings != null) {
      // Ensure 'weeklyOffs' exists and is a List
      if (settings is Map<String, dynamic> && settings['weeklyOffs'] is List) {
        final newDates = (settings['weeklyOffs'] as List<dynamic>)
            .map((date) => DateTime.parse(date))
            .toList();

        setState(() {
          // Add new dates only if they are not already in the list
          _weeklyOffDates.addAll(newDates.where((date) => !_weeklyOffDates.contains(date)));
        });

        _sortDatesByMonth();
        _saveWeeklyOffDatesToStorage();
        SocketService().emit('update_WeeklyOffOrHoliday', null);
        _showSnackBar(response['message'] ?? 'Default weekly offs generated successfully!');
      } else {
        throw Exception('Invalid data format for weeklyOffs.');
      }
    } else {
      throw Exception(response['error'] ?? 'Failed to generate default weeklyoffs.');
    }
  } catch (e) {
    debugPrint('$e');
    _showSnackBar('Error: ${e.toString()}');
  }
}


  Future<void> _removeWeeklyOff(DateTime date) async {
    // Call API to remove weekly off
    try {
      final response = await ApiService.delete('/admin/removeWeeklyOff', {'date': _dateFormat.format(date)});
      if (response['success'] == true) {
          setState(() {
            _weeklyOffDates.remove(date);
          });
          _saveWeeklyOffDatesToStorage();
          SocketService().emit('update_WeeklyOffOrHoliday', null);
          _showSnackBar(response['message'] ?? 'WeeklyOff removed successfully!');
        } else {
          _showSnackBar('Error: ${response['error']}, Try again!');
        }
    } catch (e) {
      _showSnackBar('Error: ${e.toString()}');
    }
  }

  Future<void> _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      debugPrint('$pickedDate');
      _addWeeklyOff(pickedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
          ),
        title: const Text('Set Weekly Offs'),
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
                  onPressed: _generateDefaultWeeklyOffs,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  child: const Text('Set Default Weekly Offs'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _weeklyOffDates.isEmpty
                  ? const Center(child: Text('No weekly offs set yet.'))
                  : ListView.builder(
                      itemCount: _weeklyOffDates.length,
                      itemBuilder: (context, index) {
                        final date = _weeklyOffDates[index];
                        return Card(
                          child: ListTile(
                            title: Text(_dateFormat.format(date)),
                            trailing: IconButton(
                              icon: const Icon(Icons.close, color: Colors.red),
                              onPressed: () => _removeWeeklyOff(date),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
