import 'package:flutter/material.dart';

class TextInput extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  // validator
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final bool? enabled;
  final bool? readOnly;
  final String? initialValue;
  const TextInput({
    super.key,
    required this.controller,
    required this.hintText,
    required this.obscureText,
    required this.validator,
    this.keyboardType = TextInputType.text,
    this.enabled = true,
    this.readOnly = false,
    this.initialValue,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          label: Text(hintText),
          // enabledBorder: const OutlineInputBorder(
          //   borderSide: BorderSide(color: Color.fromARGB(255, 175, 175, 175)),
          // ),
          // focusedBorder: const OutlineInputBorder(
          //   borderSide: BorderSide(color: Color.fromARGB(255, 234, 232, 232)),
          // ),
          errorBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red),
          ),
          focusedErrorBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red),
          ),

          fillColor: Colors.transparent,
          filled: true,
          border: const OutlineInputBorder(
            borderSide: const BorderSide(
              color: Color.fromARGB(255, 175, 175, 175),
            ),
          ),
          // hintText: hintText,
          // hintStyle: TextStyle(color: Colors.grey[500]),
        ),
        validator: validator,
        enabled: enabled,
        readOnly: readOnly ?? false,
        maxLines: keyboardType == TextInputType.multiline ? null : 1,
        initialValue: initialValue,
      ),
    );
  }
}
