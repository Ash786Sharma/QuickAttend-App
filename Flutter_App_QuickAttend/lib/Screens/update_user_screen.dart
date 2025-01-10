import 'package:flutter/material.dart';
import 'package:quickattend/Services/api_service.dart';
import '../Widgets/custom_text_field.dart';
import '../Widgets/custom_button.dart';

class UpdateUserScreen extends StatefulWidget {
  const UpdateUserScreen({super.key});

  @override
  _UpdateUserScreenState createState() => _UpdateUserScreenState();
}

class _UpdateUserScreenState extends State<UpdateUserScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _employeeIdController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _roleController = TextEditingController();

  // Show a SnackBar with a custom message
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  bool _isLoading = false;

  // Function to search user by employee ID
  Future<void> _searchUser() async {
    final employeeId = _searchController.text.trim();
    debugPrint(employeeId);
    if (employeeId.isEmpty) {
       _showSnackBar('Please enter an Employee ID.');
      return;
    }
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await ApiService.get('/admin/searchUser/$employeeId');
      if (response['success'] == true) {
        final userData = response['user'];
        setState(() {
          _employeeIdController.text = userData['employeeId'];
          _nameController.text = userData['name'];
          _roleController.text = userData['role'];
        });
        _showSnackBar(response['message'] ?? 'User found Successfully');
      } else {
          _showSnackBar('Error: ${response['error']}, Try again!');
        }
    } catch (e) {
      _showSnackBar(e.toString());
      print('Error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Function to update user details
  Future<void> _updateUser() async {
    final employeeId = _employeeIdController.text.trim();
    final name = _nameController.text.trim();
    final role = _roleController.text.trim();

    if (employeeId.isEmpty || name.isEmpty || role.isEmpty) {
      _showSnackBar('All fields are required.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await ApiService.post(
        '/admin/user/$employeeId', { 'name': name, 'newEmployeeId': employeeId, 'role': role}
      );
      debugPrint('$response');

      if (response['success'] == true) {
        final userData = response['user'];
        setState(() {
          _employeeIdController.text = userData['employeeId'];
          _nameController.text = userData['name'];
          _roleController.text = userData['role'];
        });
        _showSnackBar(response['message'] ?? 'User data updated successfully');
      } else {
          _showSnackBar('Error: ${response['error']}, Try again!');
        }

    } catch (e) {
      _showSnackBar(e.toString());
      print('Error: $e');
    } finally {
      setState(() {
        _isLoading = false;
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
        title: const Text('Update User Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Input and Button
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(labelText: 'Enter Employee ID'),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _searchUser,
                ),
              ],
            ),
            const SizedBox(height: 30),
            // User Details Input Fields
            
            CustomTextField(label: 'Employee ID', controller: _employeeIdController, onChanged: (value) {}),

            const SizedBox(height: 16),
            
            CustomTextField(label: 'Name', controller: _nameController, onChanged: (value) {}),

            const SizedBox(height: 16),

            CustomTextField(label: 'Role', controller: _roleController, onChanged: (value) {}),

            const SizedBox(height: 20),
            // Update Button
            Center(
              child: SizedBox(
              width: 200,
              child: CustomButton(label: 'Update User', onPressed: _updateUser, isLoading: _isLoading,),
            )  ,
            )
          ],
        ),
      ),
    );
  }
}
