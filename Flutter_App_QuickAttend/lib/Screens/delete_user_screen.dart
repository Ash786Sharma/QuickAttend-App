import 'package:flutter/material.dart';
import 'package:quickattend/Services/api_service.dart';

class DeleteUserScreen extends StatefulWidget {
  const DeleteUserScreen({super.key});

  @override
  State<DeleteUserScreen> createState() => _DeleteUserScreenState();
}

class _DeleteUserScreenState extends State<DeleteUserScreen> {
  List<Map<String, dynamic>> users = []; // Mock data for users
  bool isLoading = true; // Loading state

  // Show a SnackBar with a custom message
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void initState() {
    super.initState();
    fetchUsers(); // Fetch users on screen load
  }

  // Fetch all users from API
  void fetchUsers() async {
    setState(() {
      isLoading = true;
    });
  
    try {
      final response = await ApiService.get('/admin/user/getUsers');
  
      if (response['success'] == true) {
        // Safely parse the response into a List<Map<String, dynamic>>
        final List<dynamic> fetchedUsers = response['users'];
        users = fetchedUsers
            .map((user) => user as Map<String, dynamic>) // Explicitly cast each item
            .toList();
  
        _showSnackBar(response['message'] ?? 'Users fetched successfully');
      } else {
        _showSnackBar('Error: ${response['error']}, Try again!');
      }
    } catch (e) {
      _showSnackBar(e.toString());
      debugPrint('Error: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }


  // Delete a single user
  void deleteUser(String employeeId) async {

    setState(() {
      isLoading = true;
    });
  
    try {
      final response = await ApiService.delete('/admin/user/deleteUser/$employeeId', null);
  
      if (response['success'] == true) {
        fetchUsers();
        _showSnackBar(response['message'] ?? 'User deleted successfully');
      } else {
        _showSnackBar('Error: ${response['error']}, Try again!');
      }
    } catch (e) {
      _showSnackBar(e.toString());
      debugPrint('Error: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Delete all users
  void deleteAllUsers() async {
    setState(() {
      isLoading = true;
    });
  
    try {

      final response = await ApiService.delete('/admin/user/deleteAllUsers', null);

      if (response['success'] == true) {
        fetchUsers();
        _showSnackBar(response['message'] ?? 'All users deleted successfully');
      } else {
        _showSnackBar('Error: ${response['error']}, Try again!');
      }
    } catch (e) {
      _showSnackBar(e.toString());
      debugPrint('Error: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Show warning dialog
  Future<bool> showWarningDialog(String message) async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Warning'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Confirm', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
          ),
        title: const Text('Delete Users'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : users.isEmpty
              ? const Center(child: Text("No users available"))
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: users.length,
                        itemBuilder: (context, index) {
                          final user = users[index];
                          return ListTile(
                            title: Text('${user['name']}, ${user['employeeId']}'),
                            subtitle: Text('Role: ${user['role']}'),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => deleteUser(user['employeeId']),
                            ),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        onPressed: deleteAllUsers,
                        child: const Text('Delete All Users'),
                      ),
                    ),
                  ],
                ),
    );
  }
}
