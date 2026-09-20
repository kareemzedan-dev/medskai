import 'package:flutter/material.dart';
import 'package:flutter_app/app/backend/models/discussion_model.dart';
import 'package:flutter_app/app/backend/parse/discussion_parse.dart';
import 'package:flutter_app/app/util/toast.dart';
import 'package:get/get.dart';

class DiscussionController extends GetxController {
  final DiscussionParser parser;
  final int postId;

  DiscussionController({required this.parser, required this.postId});

  final TextEditingController commentController = TextEditingController();
  List<DiscussionModel> comments = [];
  bool isLoading = true;
  bool isPosting = false;
  bool hasMore = true;
  int _page = 1;
  int? replyToId;
  String? replyToName;

  @override
  void onInit() {
    super.onInit();
    loadComments();
  }

  @override
  void onClose() {
    commentController.dispose();
    super.onClose();
  }

  Future<void> loadComments() async {
    isLoading = comments.isEmpty;
    _page = 1;
    update();

    try {
      final response = await parser.getComments(postId, page: 1);
      if (response.statusCode == 200 && response.body is List) {
        comments = [];
        for (var data in response.body) {
          if (data is Map<String, dynamic>) {
            comments.add(DiscussionModel.fromJson(data));
          }
        }
        hasMore = comments.length >= 20;
      }
    } catch (e) {
      debugPrint('loadComments error: $e');
    }

    isLoading = false;
    update();
  }

  Future<void> loadMore() async {
    if (!hasMore) return;
    _page++;

    try {
      final response = await parser.getComments(postId, page: _page);
      if (response.statusCode == 200 && response.body is List) {
        for (var data in response.body) {
          if (data is Map<String, dynamic>) {
            comments.add(DiscussionModel.fromJson(data));
          }
        }
        hasMore = (response.body as List).length >= 20;
      } else {
        hasMore = false;
      }
    } catch (e) {
      hasMore = false;
    }

    update();
  }

  void setReplyTo(int id, String name) {
    replyToId = id;
    replyToName = name;
    update();
  }

  void cancelReply() {
    replyToId = null;
    replyToName = null;
    update();
  }

  Future<void> postComment() async {
    final text = commentController.text.trim();
    if (text.isEmpty) return;
    if (parser.getToken().isEmpty) {
      showToast('Please login to comment', isError: true);
      return;
    }

    isPosting = true;
    update();

    try {
      final response = await parser.postComment(
        postId: postId,
        content: text,
        parentId: replyToId,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        commentController.clear();
        replyToId = null;
        replyToName = null;
        await loadComments();
        showToast('Comment posted');
      } else {
        showToast(response.body?['message']?.toString() ?? 'Failed to post comment', isError: true);
      }
    } catch (e) {
      showToast('Failed to post comment', isError: true);
    }

    isPosting = false;
    update();
  }
}
