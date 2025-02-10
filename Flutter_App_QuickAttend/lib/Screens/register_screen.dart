import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import '../services/api_service.dart';
import '../Widgets/custom_text_field.dart';
import '../Widgets/custom_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController employeeIdController = TextEditingController();
  final LocalAuthentication auth = LocalAuthentication();
  bool isLoading = false;
  bool canAuthenticate = false;

  // Show a SnackBar with a custom message
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  // Check if biometric authentication is supported
  Future<void> _checkBiometricSupport() async {
    final canCheckBiometrics = await auth.canCheckBiometrics;
    final isDeviceSupported = await auth.isDeviceSupported();

    setState(() {
      canAuthenticate = canCheckBiometrics || isDeviceSupported;
    });

    if (!canAuthenticate && mounted) {
      _showSnackBar('This device does not support biometric authentication try other method.');
    }
  }

  // Handle biometric or fallback authentication
  Future<void> _authenticateUser() async {
    if (nameController.text.isEmpty || employeeIdController.text.isEmpty) {
      _showSnackBar('Please fill in all fields.');
      return;
    }

    try {
      final isAuthenticated = await auth.authenticate(
        localizedReason: 'Authenticate to complete Registration!',
        options: const AuthenticationOptions(
          stickyAuth: true,
        ),
      );

      if (isAuthenticated) {
        //_showSnackBar('Authentication successful!');
        await _registerUser();
      } else {
        _showSnackBar('Authentication failed. Please try again.');
      }
    } catch (e) {
      _showSnackBar('Error: ${e.toString()}');
    }
  }

  // Register user via API
  Future<void> _registerUser() async {
    setState(() => isLoading = true);

    try {
      final response = await ApiService.post('/auth/register', {
        'name': nameController.text,
        'employeeId': employeeIdController.text,
      });

      //debugPrint(response);

      if (mounted) {
        // Extract and display the message from the response
        final message = response['message'] ?? 'Registration successful!';
        _showSnackBar(message);
        Navigator.of(context).pushNamed('/login');
      } else {
        _showSnackBar('Error: ${response['error']}');
        //debugPrint('Error 1: ${response['error']}');
      }
    } catch (e) {
      _showSnackBar('Error: ${e.toString()}');
      //debugPrint('Error 2: ${e.toString()}');
    } finally {
      setState(() => isLoading = false); 
    }
  }

  @override
  void initState() {
    super.initState();
    _checkBiometricSupport();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
          children: [
            Container(
          height: double.infinity,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: Theme.of(context).brightness == Brightness.dark
                ? [
                    Colors.black,
                    Color(0xFF9E0C39),
                  ]
                : [
                    Color(0xFFE21B5A),
                    Color(0xFF9E0C39),
                    Color(0xFF333333)
                  ],)
          ),
          child: Padding(
            padding: const EdgeInsets.only(top: 60.0, left: 22),
            child: Text('Wellcome,\nSign up!', style: TextStyle(fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).brightness == Brightness.dark ? Color(0xFFE21B5A) :Color(0xFFFBFFE3),
            ),)
          )
        ),
        Padding(padding: EdgeInsets.only(top: 200.0),
        child: Container(
          height: double.infinity,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark ? Color(0xFF333333) :Color(0xFFFBFFE3),
            boxShadow: [ 
              BoxShadow(
                color: Colors.black.withOpacity(0.9), // Shadow color with transparency
                offset: const Offset(0, 10), // Horizontal and vertical offset
                blurRadius: 40, // Softness of the shadow
                spreadRadius: 8, // How much the shadow spreads
               ),
             ],
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(40),
              topRight: Radius.circular(40),
            )
          ),
          child: Padding(
            padding: const EdgeInsets.only(top: 100, left: 20, right: 20),
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CustomTextField(
              label: 'Name',
              controller: nameController,
              onChanged: (value) {},
            ),
            const SizedBox(height: 40),
            CustomTextField(
              label: 'Employee ID',
              controller: employeeIdController,
              onChanged: (value) {},
            ),
            const SizedBox(height: 60),
            CustomButton(
              label: 'Sign Up',
              onPressed: _authenticateUser,
              isLoading: isLoading,
            ),
            const SizedBox(height: 150),
            // Button to go to Login Screen
            TextButton(
              onPressed: () {
                Navigator.of(context).pushNamed("/login");
              },
              child: const Text('Already have an account? Log in!'),
            ),
          ],
         ),
        ),
       ),
      ),
     ]
    )
   );      
  }
}
