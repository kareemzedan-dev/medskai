import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/app/backend/models/blog_post_model.dart';
import 'package:flutter_app/app/controller/home_controller.dart';
import 'package:flutter_app/app/util/theme.dart';
import 'package:flutter_app/app/view/blog_detail.dart';
import 'package:flutter_app/l10n/locale_keys.g.dart';
import 'package:get/get.dart';

class BlogScreen extends StatefulWidget {
  const BlogScreen({super.key});

  @override
  State<BlogScreen> createState() => _BlogScreenState();
}

class _BlogScreenState extends State<BlogScreen> {
  final ScrollController _scrollController = ScrollController();
  HomeController get _homeController => Get.find<HomeController>();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _homeController.loadMorePosts();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.kaiColors;
    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: colors.textPrimary),
          onPressed: () => Get.back(),
        ),
        title: Text(
          tr(LocaleKeys.blog_title),
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: colors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: GetBuilder<HomeController>(builder: (controller) {
        if (controller.isLoadingPosts) {
          return const Center(
            child: CircularProgressIndicator(color: MedsKaiColors.primary),
          );
        }

        if (controller.latestPosts.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          cacheExtent: 500,
          itemCount: controller.latestPosts.length + (controller.hasMorePosts ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == controller.latestPosts.length) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Center(
                  child: CircularProgressIndicator(color: MedsKaiColors.primary),
                ),
              );
            }
            return KeyedSubtree(
              key: ValueKey(controller.latestPosts[index].id ?? index),
              child: _buildBlogCard(controller.latestPosts[index]),
            );
          },
        );
      }),
    );
  }

  Widget _buildEmptyState() {
    final colors = context.kaiColors;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.article_outlined,
            size: 80,
            color: colors.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            tr(LocaleKeys.blog_empty),
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBlogCard(BlogPostModel post) {
    final colors = context.kaiColors;
    return GestureDetector(
      onTap: () => Get.to(() => BlogDetailScreen(post: post)),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: colors.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.border),
          boxShadow: [
            BoxShadow(
              color: MedsKaiColors.primary.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: SizedBox(
                height: 180,
                width: double.infinity,
                child: post.imageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: post.imageUrl!,
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) {
                          return _buildImagePlaceholder();
                        },
                        placeholder: (context, url) => Container(
                          color: Colors.grey[200],
                          child: Center(
                            child: Icon(Icons.article_outlined, size: 40, color: Colors.grey[400]),
                          ),
                        ),
                      )
                    : _buildImagePlaceholder(),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    post.title ?? '',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: colors.textPrimary,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  // Excerpt
                  Text(
                    post.excerpt ?? '',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: colors.textSecondary,
                      height: 1.5,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),

                  // Category & Date & Read More
                  Row(
                    children: [
                      if (post.categoryName != null) ...[
                        Icon(Icons.sell_outlined, size: 14, color: colors.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          post.categoryName!,
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: colors.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      Icon(Icons.calendar_today_outlined, size: 14, color: colors.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        post.formattedDate,
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: colors.textSecondary,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        tr(LocaleKeys.blog_readMore),
                        style: const TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: MedsKaiColors.primary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_forward, size: 14, color: MedsKaiColors.primary),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    final colors = context.kaiColors;
    return Container(
      color: colors.sectionBg,
      child: Center(
        child: Icon(
          Icons.article_outlined,
          color: colors.textSecondary,
          size: 40,
        ),
      ),
    );
  }
}
