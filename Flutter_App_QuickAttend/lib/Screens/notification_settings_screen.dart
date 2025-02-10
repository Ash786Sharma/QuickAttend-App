import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:quickattend/Widgets/custom_button.dart';
import '../Services/notification_service.dart'; // Ensure this points to your notification logic file



class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  TimeOfDay _selectedTime = TimeOfDay.now(); // Default to current time
  final FlutterSecureStorage storage = const FlutterSecureStorage();
  bool _notificationsEnabled = false;
  TimeOfDay? _savedTime; // To display the saved time prominently
  bool _isLoading = true; 
  bool _isLoadingSave = false;
  Map<String, dynamic>? userData;
  String? _timeZone;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    debugPrint('${TimeOfDay.now()}');
  }

  void _showSnackBar(String message) {
    if(!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  // Load saved settings on startup
  Future<void> _loadSettings() async {
    final savedTime = await storage.read(key: 'notificationTime');
    final savedTimeZone = await storage.read(key: 'notificationTimeZone');
    if(savedTime != null && savedTimeZone != null){
      debugPrint("saved time: $savedTime");
      setState(() {
      _notificationsEnabled = true; // Enable notifications if time is saved
      final parts = savedTime.split(':');
        _savedTime = TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
        );
      _timeZone = savedTimeZone;
      });
    }else{
      _showSnackBar("Notification time not set yet!");
    }
    setState(() {
      _isLoading = false; // Mark loading as complete
    });
  }

  // Function to select a time
  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );

    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
        _savedTime = picked;
        debugPrint("selec: $_selectedTime, saved: $_savedTime");
      });
    }
  }

  Future<void> _saveSettings() async {
  setState(() {
    _isLoadingSave = true;
  });
  final String timeZone = await FlutterNativeTimezone.getLocalTimezone();
  // Save the selected notification time to secure storage
  await storage.write(
    key: 'notificationTime',
    value: '${_selectedTime.hour}:${_selectedTime.minute}',
  );

  await storage.write(
    key: 'notificationTimeZone',
    value: timeZone,
  );

  
  debugPrint("selected time: $_selectedTime");

  await _trigerScheduleNotification();
  _showSnackBar('Notification time saved successfully!');
  setState(() {
  _isLoadingSave = false;
  });
}

  Future<void> _trigerNotification() async {
          await NotificationService.showInstantNotification('this is test title', 'this is test message');
  }

  Future<void> _trigerScheduleNotification() async {
          await NotificationService.scheduleDailyNotification(
            "Daily Reminder",
            "Don't forget to mark your attendance!",
            _selectedTime,
            );
  }


  // Toggle notifications
  void _toggleNotifications(bool value) {
    setState(() {
      _notificationsEnabled = value;
      if (!value) {
        _savedTime = null;
        storage.delete(key: 'notificationTime');
        NotificationService.cancelAllNotifications();
      }
    });
    _showSnackBar(value
            ? 'Notifications enabled!'
            : 'Notifications disabled!');
  }


  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: AppBar(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
          ),
        title: const Text('Notification Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Toggle notifications
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Enable Notifications',
                  style: TextStyle(fontSize: 18),
                ),
                Switch(
                  value: _notificationsEnabled,
                  onChanged: _toggleNotifications,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Show saved time prominently
            if (_savedTime != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Saved Notification Time:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    _savedTime!.format(context),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Saved Notification Time Zone:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  if (_timeZone != null)
                  Text(
                    _timeZone!,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),

            // Time picker and save button
            if (_notificationsEnabled)
              Column(
                children: [
                  ListTile(
                    title: const Text('Select Notification Time'),
                    subtitle: Text(_selectedTime.format(context)),
                    trailing: IconButton(
                      icon: const Icon(Icons.access_time),
                      onPressed: _selectTime,
                    ),
                  ),
                  Center(
                  child: SizedBox(
                  width: 200,
                  child:CustomButton(
                    label: 'Save Settings',
                    onPressed: _saveSettings,
                    isLoading: _isLoadingSave,
                    ),
                  ),
                ),
                 const SizedBox(height: 20),
                 Center(
                  child: SizedBox(
                  width: 200,
                  child:CustomButton(
                    label: 'trigger Mock',
                    onPressed: _trigerNotification,
                    isLoading: false,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
