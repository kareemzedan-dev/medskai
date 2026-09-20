import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../l10n/locale_keys.g.dart';
import '../../core/constants/social_links.dart';

class SocialMediaLinksWidget extends StatelessWidget {
  const SocialMediaLinksWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tr(LocaleKeys.social_followUs),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: SocialLinks.all.map((link) {
            return InkWell(
              onTap: () => launchUrl(Uri.parse(link.url), mode: LaunchMode.externalApplication),
              borderRadius: BorderRadius.circular(24),
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                ),
                child: Icon(link.icon, color: Theme.of(context).primaryColor),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
