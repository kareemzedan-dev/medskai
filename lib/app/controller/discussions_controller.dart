import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../backend/models/message_model.dart';
import '../backend/parse/community_parse.dart';

class DiscussionsController extends GetxController {
  final CommunityParser parser;

  DiscussionsController({required this.parser});

  String groupId = '';
  String groupName = '';
  int membersCount = 0;

  bool isLoading = true;
  bool isLoadingMore = false;
  bool hasError = false;
  String errorMessage = '';
  
  List<MessageModel> messages = [];
  PaginationModel pagination = PaginationModel();

  final ScrollController scrollController = ScrollController();
  Timer? _refreshTimer;

  @override
  void onInit() {
    super.onInit();
    
    final args = Get.arguments;
    if (args != null && args is List && args.isNotEmpty) {
      groupId = args[0].toString();
      if (args.length > 1) groupName = args[1].toString();
      if (args.length > 2) membersCount = args[2] as int;
    }

    scrollController.addListener(_scrollListener);
    fetchDiscussions(page: 1);

    // Auto-refresh every 40 seconds
    _refreshTimer = Timer.periodic(const Duration(seconds: 40), (_) {
      // Background refresh
      fetchDiscussions(page: 1, isRefresh: true);
    });
  }

  @override
  void onClose() {
    _refreshTimer?.cancel();
    scrollController.dispose();
    super.onClose();
  }

  void _scrollListener() {
    if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
      if (pagination.hasMore && !isLoadingMore && !isLoading) {
        fetchDiscussions(page: pagination.currentPage + 1, isLoadMore: true);
      }
    }
  }

  Future<void> fetchDiscussions({required int page, bool isLoadMore = false, bool isRefresh = false}) async {
    if (groupId.isEmpty) return;

    if (isLoadMore) {
      isLoadingMore = true;
    } else if (!isRefresh) {
      isLoading = true;
      hasError = false;
    }
    update();

    try {
      final response = await parser.getGroupDiscussions(groupId, page: page);
      if (response.statusCode == 200) {
        final Map<String, dynamic> body = response.body;
        
        if (body['success'] == true) {
          if (body['pagination'] != null) {
            pagination = PaginationModel.fromJson(body['pagination']);
          }

          if (body['data'] != null) {
            final List<dynamic> dataList = body['data'];
            final List<MessageModel> newMessages = dataList.map((e) => MessageModel.fromJson(e)).toList();
            
            if (isLoadMore) {
              messages.addAll(newMessages);
            } else {
              messages = newMessages;
            }
          }
        }
      } else {
        if (!isLoadMore) {
          hasError = true;
          errorMessage = 'Failed to load discussions. Status: ${response.statusCode}';
        }
      }
    } catch (e) {
      if (!isLoadMore) {
        hasError = true;
        errorMessage = e.toString();
      }
      debugPrint('fetchDiscussions exception: $e');
    } finally {
      isLoading = false;
      isLoadingMore = false;
      update();
    }
  }

  // --- Send Message ---
  final TextEditingController textController = TextEditingController();
  bool isSending = false;

  Future<void> sendMessage() async {
    final content = textController.text.trim();
    if (content.isEmpty || groupId.isEmpty || isSending) return;

    isSending = true;
    update();

    try {
      final response = await parser.postGroupDiscussion(groupId, content);
      if (response.statusCode == 200) {
        final Map<String, dynamic> body = response.body;
        
        if (body['success'] == true && body['data'] != null) {
          final newMessage = MessageModel.fromJson(body['data']);
          messages.add(newMessage);
          textController.clear();
          
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (scrollController.hasClients) {
              scrollController.animateTo(
                scrollController.position.maxScrollExtent,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            }
          });
        }
      } else {
        Get.snackbar(
          'Error',
          'Failed to send message',
          backgroundColor: Colors.red.withOpacity(0.9),
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      debugPrint('sendMessage error: $e');
      Get.snackbar(
        'Error',
        'Failed to send message: $e',
        backgroundColor: Colors.red.withOpacity(0.9),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isSending = false;
      update();
    }
  }

  void onBack() {
    Get.back();
  }
}
