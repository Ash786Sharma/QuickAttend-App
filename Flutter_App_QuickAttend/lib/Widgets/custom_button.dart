import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isLoading;

  const CustomButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (event) {},
      onExit: (event) {},
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16.0), // Increase button height
          textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? const SizedBox(
                height: 30, // Reduced size of CircularProgressIndicator
                width: 30, 
                child: CircularProgressIndicator(
                  strokeWidth: 3.0, // Reduce thickness
                ),
              )
            : Text(label),
      ),
    );
  }
}
