import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../backend/parse/jobs_parse.dart';

/// Minimal controller kept for binding compatibility, and for creating jobs natively.
class JobsController extends GetxController implements GetxService {
  final JobsParser parser;
  JobsController({required this.parser});

  String errorMessage = '';

  Future<bool> createJob(Map<String, dynamic> data) async {
    try {
      final response = await parser.createJob(data);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }
      errorMessage = response.statusText ?? 'Failed to create job';
      return false;
    } catch (e) {
      debugPrint('createJob error: $e');
      errorMessage = 'Error creating job';
      return false;
    }
  }
}
