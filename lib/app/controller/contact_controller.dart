import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../backend/models/contact_form_model.dart';
import '../backend/parse/contact_parse.dart';

class ContactController extends GetxController implements GetxService {
  final ContactParser parser;

  ContactController({required this.parser});

  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final subjectController = TextEditingController();
  final messageController = TextEditingController();

  bool isLoading = false;
  bool isSuccess = false;
  bool hasError = false;
  String statusMessage = '';
  List<InvalidField> validationErrors = [];

  @override
  void onInit() {
    super.onInit();
    nameController.text = parser.getUserName();
    emailController.text = parser.getUserEmail();
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    subjectController.dispose();
    messageController.dispose();
    super.onClose();
  }

  bool validate() {
    if (nameController.text.trim().isEmpty) {
      statusMessage = 'Please enter your name';
      hasError = true;
      update();
      return false;
    }
    if (emailController.text.trim().isEmpty || !GetUtils.isEmail(emailController.text.trim())) {
      statusMessage = 'Please enter a valid email';
      hasError = true;
      update();
      return false;
    }
    if (subjectController.text.trim().isEmpty) {
      statusMessage = 'Please enter a subject';
      hasError = true;
      update();
      return false;
    }
    if (messageController.text.trim().isEmpty) {
      statusMessage = 'Please enter your message';
      hasError = true;
      update();
      return false;
    }
    return true;
  }

  Future<void> submitForm() async {
    if (!(formKey.currentState?.validate() ?? false)) return;
    if (!validate()) return;

    isLoading = true;
    isSuccess = false;
    hasError = false;
    statusMessage = '';
    validationErrors = [];
    update();

    try {
      final response = await parser.submitContactForm(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        subject: subjectController.text.trim(),
        message: messageController.text.trim(),
      );

      if (response.statusCode == 200 && response.body is Map) {
        final result = ContactFormResponse.fromJson(response.body);
        if (result.isSuccess) {
          isSuccess = true;
          statusMessage = result.message ?? 'Message sent successfully';
          _clearForm();
        } else if (result.isValidationError) {
          hasError = true;
          validationErrors = result.invalidFields;
          statusMessage = result.message ?? 'Please check the form fields';
        } else {
          hasError = true;
          statusMessage = result.message ?? 'Failed to send message';
        }
      } else {
        hasError = true;
        statusMessage = 'Failed to send message. Please try again.';
      }
    } catch (e) {
      hasError = true;
      statusMessage = 'Network error. Please try again.';
      debugPrint('submitForm error: $e');
    }

    isLoading = false;
    update();
  }

  void _clearForm() {
    subjectController.clear();
    messageController.clear();
  }

  void resetState() {
    isSuccess = false;
    hasError = false;
    statusMessage = '';
    validationErrors = [];
    update();
  }
}
