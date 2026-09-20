import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../backend/models/testimonial_model.dart';

class TestimonialsSection extends StatelessWidget {
  final List<TestimonialModel> testimonials;

  const TestimonialsSection({Key? key, required this.testimonials}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (testimonials.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'What Our Students Say',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: testimonials.length,
            itemBuilder: (context, index) {
              return _buildTestimonialCard(context, testimonials[index], index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTestimonialCard(BuildContext context, TestimonialModel testimonial, int index) {
    return Container(
      key: ValueKey(index),
      width: 280,
      margin: const EdgeInsets.only(right: 12),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: testimonial.avatarUrl != null
                        ? CachedNetworkImageProvider(testimonial.avatarUrl!)
                        : null,
                    child: testimonial.avatarUrl == null
                        ? Text(testimonial.reviewerName?.substring(0, 1).toUpperCase() ?? '?')
                        : null,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          testimonial.reviewerName ?? '',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (testimonial.reviewerTitle != null)
                          Text(
                            testimonial.reviewerTitle!,
                            style: TextStyle(color: Colors.grey[600], fontSize: 12),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              RatingBarIndicator(
                rating: testimonial.rating,
                itemBuilder: (_, __) => const Icon(Icons.star, color: Colors.amber),
                itemCount: 5,
                itemSize: 16,
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Text(
                  testimonial.content ?? '',
                  style: TextStyle(color: Colors.grey[700], fontSize: 13),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
