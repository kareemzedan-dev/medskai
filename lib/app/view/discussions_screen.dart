import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../l10n/locale_keys.g.dart';
import '../controller/discussions_controller.dart';
import '../util/theme.dart';
import '../view/components/cached_image.dart';

class DiscussionsScreen extends StatelessWidget {
  const DiscussionsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DiscussionsController>(
      builder: (controller) {
        final colors = context.kaiColors;
        // Match the background color of the design
        const Color bgColor = Color(0xFFF4F6F9); 
        return Scaffold(
          backgroundColor: bgColor,
          appBar: _buildAppBar(controller),
          body: Column(
            children: [
              Expanded(
                child: _buildBody(controller, colors),
              ),
              _buildBottomInput(controller, colors),
            ],
          ),
        );
      },
    );
  }

  // ─── AppBar ──────────────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar(DiscussionsController controller) {
    // Exact match of the primary color in the reference design
    const Color appBarColor = Color(0xFF6B7ED6); 
    
    return AppBar(
      backgroundColor: appBarColor,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
        onPressed: () => controller.onBack(),
      ),
      titleSpacing: 0,
      title: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                _initials(controller.groupName),
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: appBarColor,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  controller.groupName.isNotEmpty ? controller.groupName : tr(LocaleKeys.community_discussions),
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (controller.membersCount > 0)
                  Text(
                    '${controller.membersCount} ${tr(LocaleKeys.community_members)}',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Body ─────────────────────────────────────────────────────────────────────
  Widget _buildBody(DiscussionsController controller, MedsKaiThemeColors colors) {
    if (controller.isLoading) return _buildSkeleton(colors);

    if (controller.hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded, color: MedsKaiColors.error, size: 40),
            const SizedBox(height: 16),
            Text(controller.errorMessage,
                textAlign: TextAlign.center,
                style: TextStyle(color: colors.textPrimary, fontFamily: 'Manrope', fontSize: 14)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => controller.fetchDiscussions(page: 1),
              style: ElevatedButton.styleFrom(backgroundColor: MedsKaiColors.primary),
              child: Text(tr(LocaleKeys.community_retry), style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }

    if (controller.messages.isEmpty) {
      return Center(
        child: Text(tr(LocaleKeys.community_noDiscussions),
            style: TextStyle(fontFamily: 'Manrope', fontSize: 16, color: colors.textSecondary)),
      );
    }

    return Column(
      children: [
        if (controller.isLoadingMore)
          Padding(
            padding: const EdgeInsets.all(8),
            child: SizedBox(
              width: 20, height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: MedsKaiColors.primary),
            ),
          ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => controller.fetchDiscussions(page: 1, isRefresh: true),
            color: MedsKaiColors.primary,
            child: ListView.builder(
              controller: controller.scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              itemCount: controller.messages.length,
              itemBuilder: (context, index) {
              final msg = controller.messages[index];
              final bool isMine = msg.isMine;
              final bool isFirstInGroup = index == 0 ||
                  controller.messages[index - 1].author?.id != msg.author?.id ||
                  controller.messages[index - 1].isMine != msg.isMine;
              final bool showDate = index == 0 ||
                  _isDifferentDay(controller.messages[index - 1].createdAt, msg.createdAt);

              return Column(
                children: [
                  if (showDate) _buildDateDivider(msg.createdAt, colors),
                  _buildMessageRow(msg, isMine, isFirstInGroup, colors),
                ],
              );
            },
          ),
        ),
        )
      ],
    );
  }

  // ─── Date Divider ─────────────────────────────────────────────────────────────
  Widget _buildDateDivider(String? dateStr, MedsKaiThemeColors colors) {
    // Keep it minimal as per the user's previous preference, or as in typical chats
    return const SizedBox.shrink(); 
  }

  // ─── Message Row ─────────────────────────────────────────────────────────────
  Widget _buildMessageRow(
      dynamic msg, bool isMine, bool isFirstInGroup, MedsKaiThemeColors colors) {

    String formattedTime = '';
    if (msg.createdAt != null && msg.createdAt!.isNotEmpty) {
      try {
        formattedTime = DateFormat('hh:mm a').format(DateTime.parse(msg.createdAt!));
      } catch (_) {}
    }

    const Color myBubbleColor = Color(0xFF6B7ED6);
    const Color otherBubbleColor = Color(0xFFE5E6EA);
    const Color textColorMy = Colors.white;
    const Color textColorOther = Color(0xFF1E1E1E);

    return Padding(
      padding: EdgeInsets.only(
        top: isFirstInGroup ? 16 : 4,
        bottom: 2,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          // Avatar (Others only)
          if (!isMine)
            SizedBox(
              width: 32,
              child: _buildAvatar(msg.author),
            ),
          if (!isMine) const SizedBox(width: 8),

          // Bubble Column
          Flexible(
            child: Column(
              crossAxisAlignment: isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                // Author name (Others only, top of group)
                if (!isMine && isFirstInGroup && msg.author?.name != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6, left: 4),
                    child: Text(
                      msg.author!.name!,
                      style: const TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF757575),
                      ),
                    ),
                  ),

                // Bubble
                Container(
                  constraints: BoxConstraints(
                    maxWidth: Get.width * 0.75,
                  ),
                  decoration: BoxDecoration(
                    color: isMine ? myBubbleColor : otherBubbleColor,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(18),
                      topRight: const Radius.circular(18),
                      bottomLeft: Radius.circular(isMine ? 18 : 4),
                      bottomRight: Radius.circular(isMine ? 4 : 18),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        msg.content?.trim() ?? '',
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 14.5,
                          fontWeight: FontWeight.w400,
                          color: isMine ? textColorMy : textColorOther,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Timestamp inside bubble
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              formattedTime,
                              style: TextStyle(
                                fontFamily: 'Manrope',
                                fontSize: 10,
                                color: isMine ? Colors.white.withOpacity(0.7) : const Color(0xFF757575),
                              ),
                            ),
                            if (isMine) ...[
                              const SizedBox(width: 4),
                              Icon(Icons.done_all_rounded, size: 14, color: Colors.white.withOpacity(0.9)),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Spacer for mine
          if (isMine) const SizedBox(width: 8),
        ],
      ),
    );
  }

  // ─── Avatar ───────────────────────────────────────────────────────────────────
  Widget _buildAvatar(dynamic author) {
    final String? url = author?.avatarUrl;
    if (url != null && url.isNotEmpty) {
      return ClipOval(
        child: AppCachedImage(imageUrl: url, width: 32, height: 32, fit: BoxFit.cover),
      );
    }
    return Container(
      width: 32, height: 32,
      decoration: const BoxDecoration(color: Color(0xFF6B7ED6), shape: BoxShape.circle),
      child: Center(
        child: Text(
          _initials(author?.name),
          style: const TextStyle(fontFamily: 'Manrope', fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white),
        ),
      ),
    );
  }

  String _initials(String? name) {
    if (name == null || name.isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name[0].toUpperCase();
  }

  bool _isDifferentDay(String? a, String? b) {
    if (a == null || b == null) return false;
    try {
      final d1 = DateTime.parse(a);
      final d2 = DateTime.parse(b);
      return d1.day != d2.day || d1.month != d2.month || d1.year != d2.year;
    } catch (_) {
      return false;
    }
  }

  // ─── Bottom Input Field ───────────────────────────────────────────────────────
  Widget _buildBottomInput(DiscussionsController controller, MedsKaiThemeColors colors) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Input Field
            Expanded(
              child: TextField(
                controller: controller.textController,
                maxLines: null,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => controller.sendMessage(),
                decoration: InputDecoration(
                  hintText: tr(LocaleKeys.community_writeMessage),
                  hintStyle: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 14,
                    color: Color(0xFF757575),
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF4F6F9),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Send Button
            GestureDetector(
              onTap: controller.isSending ? null : controller.sendMessage,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF6B7ED6),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: controller.isSending
                    ? const SizedBox(
                        width: 20, height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text(
                        tr(LocaleKeys.community_send),
                        style: const TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Skeleton ─────────────────────────────────────────────────────────────────
  Widget _buildSkeleton(MedsKaiThemeColors colors) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
      itemCount: 5,
      itemBuilder: (_, i) => Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: i % 2 == 0 ? MainAxisAlignment.start : MainAxisAlignment.end,
          children: [
            if (i % 2 == 0)
              Container(
                width: 32, height: 32,
                decoration: const BoxDecoration(color: Color(0xFFE5E6EA), shape: BoxShape.circle),
              ),
            if (i % 2 == 0) const SizedBox(width: 8),
            Container(
              height: 60,
              width: 150 + (i * 10.0),
              decoration: BoxDecoration(
                color: const Color(0xFFE5E6EA),
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
