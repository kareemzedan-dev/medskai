import 'package:flutter/material.dart';
import 'package:flutter_app/app/util/theme.dart';
import 'package:carousel_slider/carousel_slider.dart';

class UniversitiesSlider extends StatelessWidget {
  const UniversitiesSlider({Key? key}) : super(key: key);

  static const List<String> logos = [
    'assets/images/logos/1.webp',
    'assets/images/logos/2.webp',
    'assets/images/logos/3.webp',
    'assets/images/logos/4.webp',
    'assets/images/logos/5.webp',
    'assets/images/logos/6.webp',
    'assets/images/logos/7.webp',
    'assets/images/logos/8.webp',
    'assets/images/logos/9.webp',
    'assets/images/logos/10.webp',
    'assets/images/logos/11.webp',
    'assets/images/logos/13.webp',
    'assets/images/logos/14.webp',
    'assets/images/logos/15.webp',
    'assets/images/logos/16.webp',
    'assets/images/logos/17.webp',
    'assets/images/logos/Untitled-design-8.webp',
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.kaiColors;
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Trusted Universities',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: colors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 16),
          CarouselSlider.builder(
            itemCount: logos.length,
            options: CarouselOptions(
              height: 110,
              viewportFraction: 0.35,
              autoPlay: true,
              autoPlayInterval: const Duration(seconds: 3),
              autoPlayAnimationDuration: const Duration(milliseconds: 800),
              enableInfiniteScroll: true,
            ),
            itemBuilder: (context, index, realIndex) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 6),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: MedsKaiColors.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Image.asset(
                  logos[index],
                  fit: BoxFit.contain,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
