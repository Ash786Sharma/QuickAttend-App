import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../Services/notification_service.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  TimeOfDay _selectedTime = TimeOfDay.now();
  final FlutterSecureStorage storage = const FlutterSecureStorage();
  bool _notificationsEnabled = false;
  TimeOfDay? _savedTime;
  bool _isLoading = true; // Loading state

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final savedTime = await storage.read(key: 'notificationTime');
    setState(() {
      _notificationsEnabled = savedTime != null;
      if (savedTime != null) {
        final parts = savedTime.split(':');
        _savedTime = TimeOfDay(
          hour: int.parse(parts[0]),
          minute: int.parse(parts[1]),
        );
      }
      _isLoading = false; // Mark loading as complete
    });
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );

    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
        _savedTime = picked;
      });
    }
  }

  Future<void> _saveSettings() async {
    await storage.write(
      key: 'notificationTime',
      value: '${_selectedTime.hour}:${_selectedTime.minute}',
    );

    NotificationService.scheduleDailyNotification(
      "Daily Reminder",
      "Don't forget to mark your attendance!",
      _selectedTime,
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Notification settings saved!')),
    );
  }

  void _toggleNotifications(bool value) {
    setState(() {
      _notificationsEnabled = value;
      if (!value) {
        _savedTime = null;
        storage.delete(key: 'notificationTime');
        NotificationService.cancelAllNotifications();
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(value
            ? 'Notifications enabled!'
            : 'Notifications disabled!'),
      ),
    );
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
        title: const Text('Notification Settings'),
      ),
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
                  ElevatedButton(
                    onPressed: _saveSettings,
                    child: const Text('Save Settings'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
