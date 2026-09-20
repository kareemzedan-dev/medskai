import 'dart:convert';

class MessageModel {
  int? messageId;
  String? content;
  String? createdAt;
  AuthorModel? author;
  bool isMine = false;
  int repliesCount = 0;

  MessageModel({
    this.messageId,
    this.content,
    this.createdAt,
    this.author,
    this.isMine = false,
    this.repliesCount = 0,
  });

  MessageModel.fromJson(Map<String, dynamic> json) {
    messageId = int.tryParse(json['message_id']?.toString() ?? '0') ?? 0;
    content = json['content']?.toString() ?? '';
    createdAt = json['created_at']?.toString();
    
    if (json['author'] != null && json['author'] is Map) {
      author = AuthorModel.fromJson(json['author']);
    }
    
    if (json['is_mine'] != null) {
      isMine = json['is_mine'] is bool 
          ? json['is_mine'] 
          : json['is_mine'].toString().toLowerCase() == 'true';
    }
    
    repliesCount = int.tryParse(json['replies_count']?.toString() ?? '0') ?? 0;
  }
}

class AuthorModel {
  int? id;
  String? name;
  String? avatarUrl;

  AuthorModel({this.id, this.name, this.avatarUrl});

  AuthorModel.fromJson(Map<String, dynamic> json) {
    id = int.tryParse(json['id']?.toString() ?? '0') ?? 0;
    name = json['name']?.toString() ?? '';
    avatarUrl = json['avatar_url']?.toString() ?? '';
  }
}

class PaginationModel {
  int currentPage = 1;
  int totalPages = 1;
  bool hasMore = false;

  PaginationModel({
    this.currentPage = 1,
    this.totalPages = 1,
    this.hasMore = false,
  });

  PaginationModel.fromJson(Map<String, dynamic> json) {
    currentPage = int.tryParse(json['current_page']?.toString() ?? '1') ?? 1;
    totalPages = int.tryParse(json['total_pages']?.toString() ?? '1') ?? 1;
    
    if (json['has_more'] != null) {
      hasMore = json['has_more'] is bool 
          ? json['has_more'] 
          : json['has_more'].toString().toLowerCase() == 'true';
    }
  }
}
