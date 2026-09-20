import 'package:flutter/material.dart';

class SocialLink {
  final String platform;
  final String url;
  final IconData icon;

  const SocialLink({required this.platform, required this.url, required this.icon});
}

class SocialLinks {
  SocialLinks._();

  static const List<SocialLink> all = [
    SocialLink(platform: 'Facebook', url: 'https://facebook.com/medskai', icon: Icons.facebook),
    SocialLink(platform: 'TikTok', url: 'https://tiktok.com/@medskai', icon: Icons.music_note),
    SocialLink(platform: 'YouTube', url: 'https://youtube.com/@medskai', icon: Icons.play_circle_fill),
    SocialLink(platform: 'Instagram', url: 'https://instagram.com/medskai', icon: Icons.camera_alt),
    SocialLink(platform: 'Twitter', url: 'https://twitter.com/medskai', icon: Icons.alternate_email),
    SocialLink(platform: 'LinkedIn', url: 'https://linkedin.com/company/medskai', icon: Icons.business),
  ];
}
