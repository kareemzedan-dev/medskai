import 'package:flutter/material.dart';
import 'package:flutter_app/app/util/theme.dart';

class InputPassword extends StatefulWidget {
  final TextEditingController controller;
  final String? Function(String?)? validator;

  InputPassword({required this.controller, this.validator});

  @override
  State<InputPassword> createState() => _InputPasswordState();
}

class _InputPasswordState extends State<InputPassword> {
  bool showPassword = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.kaiColors;
    final screenWidth = MediaQuery.of(context).size.width;
    return Container(
      width: screenWidth - 32,
      height: 50,
      decoration: BoxDecoration(
        color: colors.sectionBg,
        border: Border.all(color: colors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: widget.controller,
        validator: widget.validator,
        style: TextStyle(
          fontFamily: 'Manrope',
          fontSize: 14,
          color: colors.textPrimary,
        ),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: InputBorder.none,
          suffixIcon: GestureDetector(
            onTap: () => setState(() {
              showPassword = !showPassword;
            }),
            child: Icon(
              showPassword == false ? Icons.visibility_outlined : Icons.visibility_off_outlined,
              color: colors.textSecondary.withOpacity(0.5),
              size: 20,
            ),
          ),
        ),
        obscureText: !showPassword,
      ),
    );
  }
}
