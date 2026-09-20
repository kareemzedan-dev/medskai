import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../backend/models/group_model.dart';
import '../backend/parse/community_parse.dart';
import '../helper/router.dart';

class CommunityController extends GetxController {
  final CommunityParser parser;

  CommunityController({required this.parser});

  bool isLoading = true;
  bool hasError = false;
  String errorMessage = '';
  List<GroupModel> groups = [];

  @override
  void onInit() {
    super.onInit();
    fetchMyGroups();
  }

  Future<void> fetchMyGroups() async {
    isLoading = true;
    hasError = false;
    update();

    try {
      final response = await parser.getMyGroups();
      if (response.statusCode == 200) {
        final Map<String, dynamic> body = response.body;
        if (body['success'] == true && body['data'] != null) {
          final List<dynamic> data = body['data'];
          groups = data.map((e) => GroupModel.fromJson(e)).toList();
        } else {
          groups = [];
        }
      } else {
        hasError = true;
        errorMessage = 'Failed to load groups. Status: ${response.statusCode}';
      }
    } catch (e) {
      hasError = true;
      errorMessage = e.toString();
      debugPrint('fetchMyGroups exception: $e');
    } finally {
      isLoading = false;
      update();
    }
  }

  void onGroupTapped(GroupModel group) {
    if (group.groupId != null && group.groupId!.isNotEmpty) {
      Get.toNamed(AppRouter.getDiscussionsRoute(), arguments: [
        group.groupId,
        group.name ?? 'Discussions',
        group.membersCount,
      ]);
    }
  }

  void onBack() {
    Get.back();
  }
}
