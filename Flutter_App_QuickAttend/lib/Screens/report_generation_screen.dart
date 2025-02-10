import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
//import 'package:permission_handler/permission_handler.dart';
//import 'dart:io';
import '../services/api_service.dart';
import '../Widgets/custom_text_field.dart';
import '../Widgets/custom_button.dart';

class ReportGenerationScreen extends StatefulWidget {
  const ReportGenerationScreen({super.key});

  @override
  State<ReportGenerationScreen> createState() => _ReportGenerationScreenState();
}

class _ReportGenerationScreenState extends State<ReportGenerationScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _selectedYear;
  String? _selectedMonth;
  final TextEditingController _employeeIdController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _selectedYear = DateFormat('yyyy').format(DateTime.now());
    _selectedMonth = DateFormat('MM').format(DateTime.now());
    //debugPrint(_selectedMonth);
    //debugPrint('${_getMonths()}');
  }

  Future<void> _downloadReport(String type) async {
    if (_selectedYear == null || _selectedYear!.isEmpty) {
      _showMessage('Year is required');
      return;
    }

    final year = _selectedYear!;
    final month = type == 'monthly' ? _selectedMonth ?? '' : '';
    final employeeId = _employeeIdController.text.trim();

    final endpoint = type == 'monthly'
        ? '/admin/reports/monthly/$year/$month${employeeId.isNotEmpty ? '/$employeeId' : ''}'
        : '/admin/reports/yearly/$year${employeeId.isNotEmpty ? '/$employeeId' : ''}';

    setState(() {
      _isLoading = true;
    });

    try {

      final response = await ApiService.downloadFile(endpoint);

      if (response['success'] == true) {
        _showMessage('Report downloaded to ${response['filePath']}');
      } else {
        _showMessage('Failed to download report: ${response['error']}');
      }
    } catch (e) {
      debugPrint('$e');
      _showMessage('An error occurred: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  List<String> _getYears() {
    final currentYear = DateTime.now().year;
    return List.generate(10, (index) => (currentYear - index).toString());
  }

  List<Map<String, String>> _getMonths() {
  return List.generate(12, (index) {
    final monthNum = (index + 1).toString().padLeft(2, '0'); // Numerical format
    final monthName = DateFormat('MMMM').format(DateTime(0, index + 1)); // Full month name
    return {'value': monthNum, 'name': monthName};
  });
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
          ),
        title: const Text('Generate Reports'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Yearly Report'),
            Tab(text: 'Monthly Report'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Yearly Report Tab
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonFormField<String>(
                  value: _selectedYear,
                  decoration: const InputDecoration(
                    labelText: 'Year',
                    border: OutlineInputBorder(),
                  ),
                  items: _getYears()
                      .map((year) => DropdownMenuItem(value: year, child: Text(year)))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedYear = value;
                    });
                  },
                ),
                const SizedBox(height: 30),
                CustomTextField(label: 'Employee ID (optional)', controller: _employeeIdController, onChanged: (value) {}),
                const SizedBox(height: 32),
                Center(
                  child: SizedBox(
                    width: 300,
                    child: CustomButton(label: 'Download Yearly Report', onPressed: () => _downloadReport('yearly'), isLoading: _isLoading,),
                  )
                ),
              ],
            ),
          ),

          // Monthly Report Tab
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonFormField<String>(
                  value: _selectedYear,
                  decoration: const InputDecoration(
                    labelText: 'Year',
                    border: OutlineInputBorder(),
                  ),
                  items: _getYears()
                      .map((year) => DropdownMenuItem(value: year, child: Text(year)))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedYear = value;
                    });
                  },
                ),
                const SizedBox(height: 30),
                DropdownButtonFormField<String>(
                  value: _selectedMonth, // Ensure it's initialized correctly
                  decoration: const InputDecoration(
                    labelText: 'Month',
                    border: OutlineInputBorder(),
                  ),
                  items: _getMonths().map((month) {
                    return DropdownMenuItem(
                      value: month['value'], // Numerical value (e.g., "01")
                      child: Text(month['name']!), // Display full month name (e.g., "January")
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedMonth = value; // Update the selected numerical value
                    });
                  },
                ),
                const SizedBox(height: 30),
                CustomTextField(label: 'Employee ID (optional)', controller: _employeeIdController, onChanged: (value) {}),
                const SizedBox(height: 32),
                Center(
                  child: SizedBox(
                    width: 300,
                    child: CustomButton(label: 'Download Monthly Report', onPressed: () => _downloadReport('monthly'), isLoading: _isLoading,),
                  )
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
