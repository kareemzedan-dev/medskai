import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/app/backend/models/blog_post_model.dart';
import 'package:flutter_app/app/util/theme.dart';
import 'package:flutter_app/l10n/locale_keys.g.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class BlogDetailScreen extends StatelessWidget {
  final BlogPostModel post;

  const BlogDetailScreen({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    final colors = context.kaiColors;
    return Scaffold(
      backgroundColor: colors.background,
      body: CustomScrollView(
        slivers: [
          // Collapsing AppBar with hero image
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: colors.cardBg,
            surfaceTintColor: colors.cardBg,
            leading: _buildCircleButton(
              context: context,
              icon: Icons.arrow_back_ios_new,
              onTap: () => Get.back(),
            ),
            actions: [
              if (post.link != null)
                _buildCircleButton(
                  context: context,
                  icon: Icons.open_in_browser,
                  onTap: () async {
                    try {
                      await launchUrl(
                        Uri.parse(post.link!),
                        mode: LaunchMode.externalApplication,
                      );
                    } catch (_) {}
                  },
                ),
              const SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: _buildHeroImage(context),
            ),
          ),

          // Article body
          SliverToBoxAdapter(
            child: Container(
              color: colors.background,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Meta info bar (category + date)
                  _buildMetaBar(context),

                  // Title
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Text(
                      post.title ?? '',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: colors.textPrimary,
                        height: 1.3,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Author card
                  _buildAuthorCard(context),

                  // Divider
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    child: Divider(color: colors.border, height: 1),
                  ),

                  // Article content
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _HtmlContentRenderer(html: post.content ?? post.excerpt ?? ''),
                  ),

                  // Tags
                  if (post.tags.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    _buildTagsSection(context),
                  ],

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircleButton({required BuildContext context, required IconData icon, required VoidCallback onTap}) {
    final colors = context.kaiColors;
    return Padding(
      padding: const EdgeInsets.all(8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: colors.cardBg,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(icon, color: colors.textPrimary, size: 18),
        ),
      ),
    );
  }

  Widget _buildHeroImage(BuildContext context) {
    final colors = context.kaiColors;
    return Stack(
      fit: StackFit.expand,
      children: [
        // Light background behind the image
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                MedsKaiColors.primary.withOpacity(0.15),
                MedsKaiColors.primary.withOpacity(0.05),
              ],
            ),
          ),
        ),
        if (post.imageUrl != null)
          CachedNetworkImage(
            imageUrl: post.imageUrl!,
            fit: BoxFit.contain,
            alignment: Alignment.center,
            errorWidget: (_, __, ___) => _imageFallback(),
          )
        else
          _imageFallback(),
        // Bottom gradient
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: 60,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  colors.background,
                  colors.background.withOpacity(0.0),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _imageFallback() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [MedsKaiColors.primary, MedsKaiColors.primary.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Center(
        child: Icon(Icons.article_outlined, size: 64, color: MedsKaiColors.white),
      ),
    );
  }

  Widget _buildMetaBar(BuildContext context) {
    final colors = context.kaiColors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        children: [
          if (post.categoryName != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: MedsKaiColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                post.categoryName!,
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: MedsKaiColors.primary,
                ),
              ),
            ),
          const SizedBox(width: 12),
          Icon(Icons.calendar_today_outlined, size: 14, color: colors.textSecondary),
          const SizedBox(width: 6),
          Text(
            post.formattedDate,
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 13,
              color: colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuthorCard(BuildContext context) {
    final colors = context.kaiColors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          // Author avatar
          ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: post.authorAvatar != null
                ? CachedNetworkImage(
                    imageUrl: post.authorAvatar!,
                    width: 44,
                    height: 44,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => _avatarFallback(),
                  )
                : _avatarFallback(),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                post.authorName ?? 'MedsKai',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                tr(LocaleKeys.ui_author),
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 12,
                  color: colors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _avatarFallback() {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: MedsKaiColors.primary.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.person, color: MedsKaiColors.primary, size: 24),
    );
  }

  Widget _buildTagsSection(BuildContext context) {
    final colors = context.kaiColors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(color: colors.border, height: 1),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.sell_outlined, size: 16, color: colors.textSecondary),
              const SizedBox(width: 8),
              Text(
                tr(LocaleKeys.ui_tags),
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: post.tags.map((tag) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: colors.sectionBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: colors.border),
                ),
                child: Text(
                  tag,
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: colors.textSecondary,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Simple HTML → Widget renderer
// Handles: <p>, <h1-h6>, <strong>/<b>, <em>/<i>, <a>, <ul>/<ol>/<li>,
//          <img>, <blockquote>, <br>
// ─────────────────────────────────────────────────────────────

class _HtmlContentRenderer extends StatelessWidget {
  final String html;
  const _HtmlContentRenderer({required this.html});

  @override
  Widget build(BuildContext context) {
    final colors = context.kaiColors;
    final widgets = _parse(html, colors);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }

  List<Widget> _parse(String html, MedsKaiThemeColors colors) {
    final List<Widget> widgets = [];

    // Split into block-level elements
    final blocks = html.split(RegExp(r'(?=<(?:p|h[1-6]|ul|ol|blockquote|img)[^>]*>)|(?<=</(?:p|h[1-6]|ul|ol|blockquote)>)'));

    for (final block in blocks) {
      final trimmed = block.trim();
      if (trimmed.isEmpty) continue;

      // Heading
      final headingMatch = RegExp(r'<h([1-6])[^>]*>(.*?)</h\1>', dotAll: true).firstMatch(trimmed);
      if (headingMatch != null) {
        final level = int.parse(headingMatch.group(1)!);
        final text = _decodeHtml(headingMatch.group(2)!);
        widgets.add(Padding(
          padding: const EdgeInsets.only(top: 20, bottom: 10),
          child: Text(
            text,
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: _headingSize(level),
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
              height: 1.4,
            ),
          ),
        ));
        continue;
      }

      // Image
      final imgMatch = RegExp(r'<img[^>]+src="([^"]*)"[^>]*/?>').firstMatch(trimmed);
      if (imgMatch != null) {
        final src = imgMatch.group(1)!;
        widgets.add(Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CachedNetworkImage(
              imageUrl: src,
              fit: BoxFit.cover,
              width: double.infinity,
              errorWidget: (_, __, ___) => const SizedBox(),
            ),
          ),
        ));
        continue;
      }

      // Blockquote
      final bqMatch = RegExp(r'<blockquote[^>]*>(.*?)</blockquote>', dotAll: true).firstMatch(trimmed);
      if (bqMatch != null) {
        final text = _decodeHtml(bqMatch.group(1)!);
        widgets.add(Container(
          margin: const EdgeInsets.symmetric(vertical: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(color: MedsKaiColors.primary, width: 4),
            ),
            color: MedsKaiColors.primary.withOpacity(0.05),
          ),
          child: Text(
            text,
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 16,
              fontStyle: FontStyle.italic,
              color: colors.textPrimary,
              height: 1.7,
            ),
          ),
        ));
        continue;
      }

      // Unordered / Ordered list
      final listMatch = RegExp(r'<(ul|ol)[^>]*>(.*?)</\1>', dotAll: true).firstMatch(trimmed);
      if (listMatch != null) {
        final isOrdered = listMatch.group(1) == 'ol';
        final listHtml = listMatch.group(2)!;
        final items = RegExp(r'<li[^>]*>(.*?)</li>', dotAll: true).allMatches(listHtml);
        int idx = 1;
        for (final item in items) {
          final text = _decodeHtml(item.group(1)!);
          widgets.add(Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 24,
                  child: Text(
                    isOrdered ? '$idx.' : '•',
                    style: const TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: MedsKaiColors.primary,
                      height: 1.7,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    text,
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 16,
                      color: colors.textPrimary,
                      height: 1.7,
                    ),
                  ),
                ),
              ],
            ),
          ));
          idx++;
        }
        continue;
      }

      // Paragraph (default)
      final pMatch = RegExp(r'<p[^>]*>(.*?)</p>', dotAll: true).firstMatch(trimmed);
      if (pMatch != null) {
        final text = _decodeHtml(pMatch.group(1)!);
        if (text.trim().isEmpty) continue;
        widgets.add(Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildRichText(pMatch.group(1)!, colors),
        ));
        continue;
      }

      // Fallback - plain text
      final text = _decodeHtml(trimmed);
      if (text.trim().isNotEmpty) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Text(
            text,
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 16,
              color: colors.textPrimary,
              height: 1.8,
            ),
          ),
        ));
      }
    }

    return widgets;
  }

  /// Build RichText with bold/italic/link support
  Widget _buildRichText(String html, MedsKaiThemeColors colors) {
    final List<TextSpan> spans = [];
    final RegExp tagPattern = RegExp(
      r'<(strong|b|em|i|a)([^>]*)>(.*?)</\1>',
      dotAll: true,
    );

    int lastEnd = 0;
    for (final match in tagPattern.allMatches(html)) {
      // Add text before this tag
      if (match.start > lastEnd) {
        final before = _decodeHtml(html.substring(lastEnd, match.start));
        if (before.isNotEmpty) {
          spans.add(TextSpan(text: before));
        }
      }

      final tag = match.group(1)!;
      final content = _decodeHtml(match.group(3)!);

      if (tag == 'strong' || tag == 'b') {
        spans.add(TextSpan(
          text: content,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ));
      } else if (tag == 'em' || tag == 'i') {
        spans.add(TextSpan(
          text: content,
          style: const TextStyle(fontStyle: FontStyle.italic),
        ));
      } else if (tag == 'a') {
        spans.add(TextSpan(
          text: content,
          style: const TextStyle(
            color: MedsKaiColors.primary,
            decoration: TextDecoration.underline,
          ),
        ));
      }

      lastEnd = match.end;
    }

    // Remaining text after last tag
    if (lastEnd < html.length) {
      final remaining = _decodeHtml(html.substring(lastEnd));
      if (remaining.isNotEmpty) {
        spans.add(TextSpan(text: remaining));
      }
    }

    // If no tags found, just return plain text
    if (spans.isEmpty) {
      return Text(
        _decodeHtml(html),
        style: TextStyle(
          fontFamily: 'Manrope',
          fontSize: 16,
          color: colors.textPrimary,
          height: 1.8,
        ),
      );
    }

    return RichText(
      text: TextSpan(
        style: TextStyle(
          fontFamily: 'Manrope',
          fontSize: 16,
          color: colors.textPrimary,
          height: 1.8,
        ),
        children: spans,
      ),
    );
  }

  double _headingSize(int level) {
    switch (level) {
      case 1: return 24;
      case 2: return 22;
      case 3: return 20;
      case 4: return 18;
      default: return 16;
    }
  }

  String _decodeHtml(String html) {
    return html
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&#038;', '&')
        .replaceAll('&#8217;', '\u2019')
        .replaceAll('&#8216;', '\u2018')
        .replaceAll('&#8220;', '\u201C')
        .replaceAll('&#8221;', '\u201D')
        .replaceAll('&#8230;', '\u2026')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&hellip;', '\u2026')
        .trim();
  }
}
