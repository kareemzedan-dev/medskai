import 'package:flutter/material.dart';
import 'package:flutter_app/app/backend/models/discussion_model.dart';
import 'package:flutter_app/app/backend/parse/discussion_parse.dart';
import 'package:flutter_app/app/controller/discussion_controller.dart';
import 'package:flutter_app/app/core/theme/app_colors.dart';
import 'package:flutter_app/app/util/theme.dart';
import 'package:get/get.dart';

/// Discussion/Q&A section for lessons and courses.
class DiscussionSection extends StatefulWidget {
  final int postId;
  final String tag;

  const DiscussionSection({super.key, required this.postId, String? tag})
      : tag = tag ?? 'discussion';

  @override
  State<DiscussionSection> createState() => _DiscussionSectionState();
}

class _DiscussionSectionState extends State<DiscussionSection> {
  late final String _ctrlTag;

  @override
  void initState() {
    super.initState();
    _ctrlTag = '${widget.tag}_${widget.postId}';
    if (!Get.isRegistered<DiscussionController>(tag: _ctrlTag)) {
      Get.put(
        DiscussionController(
          parser: Get.find<DiscussionParser>(),
          postId: widget.postId,
        ),
        tag: _ctrlTag,
      );
    }
  }

  @override
  void dispose() {
    if (Get.isRegistered<DiscussionController>(tag: _ctrlTag)) {
      Get.delete<DiscussionController>(tag: _ctrlTag, force: true);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.kaiColors;

    return GetBuilder<DiscussionController>(
      tag: _ctrlTag,
      builder: (ctrl) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  Icon(Icons.forum_outlined,
                      color: MedsKaiColors.primary, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Discussion (${ctrl.comments.length})',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: colors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),

            // Comment input
            _buildCommentInput(context, ctrl, colors),

            // Reply indicator
            if (ctrl.replyToName != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Text(
                      'Replying to ${ctrl.replyToName}',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 12,
                        color: MedsKaiColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () => ctrl.cancelReply(),
                      child: Icon(Icons.close,
                          size: 16, color: colors.textSecondary),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 8),

            // Comments list
            if (ctrl.isLoading)
              const Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (ctrl.comments.isEmpty)
              Padding(
                padding: const EdgeInsets.all(32),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.chat_bubble_outline,
                          size: 48, color: colors.textSecondary),
                      const SizedBox(height: 12),
                      Text(
                        'No comments yet. Be the first!',
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 14,
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: ctrl.comments.length,
                itemBuilder: (context, index) => _buildCommentItem(
                    context, ctrl.comments[index], ctrl, colors),
              ),

            // Load more
            if (ctrl.hasMore && ctrl.comments.isNotEmpty)
              Center(
                child: TextButton(
                  onPressed: () => ctrl.loadMore(),
                  child: const Text('Load more comments'),
                ),
              ),

            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  Widget _buildCommentInput(BuildContext context, DiscussionController ctrl,
      MedsKaiThemeColors colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: ctrl.commentController,
              decoration: InputDecoration(
                hintText: 'Write a comment...',
                hintStyle:
                    TextStyle(fontFamily: 'Manrope', color: colors.textHint),
                filled: true,
                fillColor: colors.sectionBg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                isDense: true,
              ),
              style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 14,
                  color: colors.textPrimary),
              maxLines: 3,
              minLines: 1,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => ctrl.postComment(),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: ctrl.isPosting ? null : () => ctrl.postComment(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: MedsKaiColors.primary,
                shape: BoxShape.circle,
              ),
              child: ctrl.isPosting
                  ? const Padding(
                      padding: EdgeInsets.all(10),
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.send_rounded,
                      color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentItem(BuildContext context, DiscussionModel comment,
      DiscussionController ctrl, MedsKaiThemeColors colors) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        comment.parentId != null && comment.parentId! > 0 ? 48 : 16,
        4,
        16,
        4,
      ),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colors.cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Author row
            Row(
              children: [
                // Avatar
                CircleAvatar(
                  radius: 16,
                  backgroundColor: MedsKaiColors.primary.withOpacity(0.1),
                  backgroundImage: comment.authorAvatar != null
                      ? NetworkImage(comment.authorAvatar!)
                      : null,
                  child: comment.authorAvatar == null
                      ? Text(
                          (comment.authorName ?? '?')[0].toUpperCase(),
                          style: const TextStyle(
                            fontFamily: 'Manrope',
                            fontWeight: FontWeight.w700,
                            color: MedsKaiColors.primary,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            comment.authorName ?? 'Anonymous',
                            style: TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: colors.textPrimary,
                            ),
                          ),
                          if (comment.isInstructor == true) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: MedsKaiColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'Instructor',
                                style: TextStyle(
                                  fontFamily: 'Manrope',
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: MedsKaiColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      Text(
                        comment.formattedDate,
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 11,
                          color: colors.textHint,
                        ),
                      ),
                    ],
                  ),
                ),
                // Reply button
                GestureDetector(
                  onTap: () => ctrl.setReplyTo(
                      comment.id ?? 0, comment.authorName ?? ''),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(Icons.reply_rounded,
                        size: 18, color: colors.textSecondary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Content
            Text(
              comment.content ?? '',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 13,
                color: colors.textPrimary,
                height: 1.5,
              ),
            ),
            // Nested replies
            if (comment.replies.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Column(
                  children: comment.replies
                      .map((reply) =>
                          _buildCommentItem(context, reply, ctrl, colors))
                      .toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
