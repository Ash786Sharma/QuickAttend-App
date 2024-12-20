import 'package:flutter/material.dart';

class AdminSettingsScreen extends StatelessWidget {
  const AdminSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
          ),
        title: const Text('Admin Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2, // Two buttons per row
          crossAxisSpacing: 16.0, // Space between buttons horizontally
          mainAxisSpacing: 16.0, // Space between buttons vertically
          children: [
            _buildAdminOption(context, Icons.calendar_today, 'Set Holidays', '/set-holiday'),
            _buildAdminOption(context, Icons.schedule, 'Set Weekly Offs', '/set-weekly-offs'),
            _buildAdminOption(context, Icons.check_circle, 'Apply Attendance', '/apply-attendance'),
            _buildAdminOption(context, Icons.person, 'Update User Details', '/update-user'),
            _buildAdminOption(context, Icons.delete, 'Delete Users', '/delete-user'),
            _buildAdminOption(context, Icons.bar_chart, 'Generate Reports', '/generate-report'),
          ],
        ),
      ),
    );
  }

  // Widget for each admin option
  Widget _buildAdminOption(BuildContext context, IconData icon, String label, String route) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed(route); // Navigate using the named route
      },
      child: Card(
        elevation: 4, // Slight elevation for the card
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), // Rounded corners
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: Colors.blue), // Feature Icon
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(fontSize: 16), // Feature Label
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
