import 'package:flutter/material.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../../backend/models/course_model.dart';

class CourseListItem extends StatelessWidget {
  final CourseModel course;
  final VoidCallback? onTap;
  final VoidCallback? onWishlistTap;
  final bool isInWishlist;

  const CourseListItem({
    Key? key,
    required this.course,
    this.onTap,
    this.onWishlistTap,
    this.isInWishlist = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: course.image != null
                    ? CachedNetworkImage(
                        imageUrl: course.image!,
                        width: 100,
                        height: 80,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => Container(
                          width: 100, height: 80, color: Colors.grey[200],
                          child: const Icon(Icons.book),
                        ),
                      )
                    : Container(
                        width: 100, height: 80, color: Colors.grey[200],
                        child: const Icon(Icons.book),
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.name ?? '',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    if (course.rating != null && course.rating! > 0)
                      RatingBarIndicator(
                        rating: course.rating!,
                        itemBuilder: (_, __) => const Icon(Icons.star, color: Colors.amber),
                        itemCount: 5,
                        itemSize: 14,
                      ),
                    const SizedBox(height: 4),
                    if (!(!kIsWeb && Platform.isIOS))
                      Text(
                        course.price_rendered ?? (course.price == 0 ? 'Free' : '\$${course.price}'),
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
              ),
              if (onWishlistTap != null)
                IconButton(
                  icon: Icon(
                    isInWishlist ? Icons.favorite : Icons.favorite_border,
                    color: isInWishlist ? Colors.red : Colors.grey,
                  ),
                  onPressed: onWishlistTap,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
