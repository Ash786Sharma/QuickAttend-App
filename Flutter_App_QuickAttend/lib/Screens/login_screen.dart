import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/api_service.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController employeeIdController = TextEditingController();
  final LocalAuthentication auth = LocalAuthentication();
  bool isLoading = false;
  bool canAuthenticate = false;

  // Instance of FlutterSecureStorage
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

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
    if (employeeIdController.text.isEmpty) {
      _showSnackBar('Please fill in all fields.');
      return;
    }

    try {
      final isAuthenticated = await auth.authenticate(
        localizedReason: 'Authenticate to Login!',
        options: const AuthenticationOptions(
          stickyAuth: true,
        ),
      );

      if (isAuthenticated) {
        //_showSnackBar('Authentication successful!');
        await login();
      } else {
        _showSnackBar('Authentication failed. Please try again.');
      }
    } catch (e) {
      debugPrint(e.toString());
      _showSnackBar('Error: ${e.toString()}');
    }
  }

  Future<void> saveUserDetails(String token) async {
  try {
    
    // Store token and user data securely
    await secureStorage.write(key: 'jwt_token', value: token);
    //_showSnackBar("User details saved securely.");
    //debugPrint("User details saved securely.");
  } catch (e) {
    _showSnackBar("Error saving user details: $e");
    //debugPrint("Error saving user details: $e");
  }
}

  Future<void> login() async {
  if (employeeIdController.text.isEmpty) {
    _showSnackBar('Please enter your Employee ID.');
    return;
  }

  setState(() => isLoading = true);

  try {
    // Call the API and get the response
    final response = await ApiService.post(
      '/auth/login',
      {'employeeId': employeeIdController.text},
    );

    // Handle a successful response
    if (response['success'] == true) {
      final token = response['token'];

      if (token != null) {
        await saveUserDetails(token);
      } else {
        _showSnackBar('Invalid response data from server.');
        return;
      }
      //debugPrint(token);
      // Show success message and navigate to home
      _showSnackBar(response['message'] ?? 'Login successful!');
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      // Handle server-provided errors (e.g., user not found)
      _showSnackBar('${response['error']}, Please Register.');
      debugPrint('Error 0: $response');
    }
  } catch (e) {
    // Handle errors gracefully
    _showSnackBar(e.toString());
    debugPrint('Error: $e');
  } finally {
    setState(() => isLoading = false);
  }
}

  @override
  void initState() {
    super.initState();
    _checkBiometricSupport();
  }


  Future<bool> _onWillPop() async {
    final result = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Leave Login'),
          content: const Text('Do you want to Sign Up ?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Yes'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('No'),
            ),
          ],
        );
      },
    );
    return result ?? false; // Default to false if dialog is dismissed
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return; // If pop already handled, do nothing

        final bool shouldPop = await _onWillPop();
        if (context.mounted && shouldPop) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
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
            child: Text('Hello,\nLog in!', style: TextStyle(fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).brightness == Brightness.dark ? Color(0xFFE21B5A) :Color(0xFFFBFFE3)
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
                label: 'Employee ID',
                controller: employeeIdController,
                onChanged: (value) {},
              ),
              const SizedBox(height: 60),
              CustomButton(
                label: 'Login',
                onPressed: _authenticateUser,
                isLoading: isLoading,
              ),
              const SizedBox(height: 250),
              TextButton(
                onPressed: () async {
                final bool shouldNavigate = await _onWillPop(); // Show the dialog
                  if (context.mounted && shouldNavigate) {
                    Navigator.of(context).pushNamed("/register"); // Navigate to the register screen if "Yes" is selected
                  }
                },
                child: const Text("Don't have an account? Sign Up!"),
              ),
            ],
          ),
          )
        ),
        )
          ],
        )
      ),
    );
  }
}
