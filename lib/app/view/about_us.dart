import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/app/core/theme/app_colors.dart';
import 'package:flutter_app/app/util/theme.dart';
import 'package:flutter_app/l10n/locale_keys.g.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  final Color primaryColor = const Color(0xFF4A55A2);
  final Color darkPurple = const Color(0xFF3B2A56);
  final Color indigoColor = const Color(0xFF2D3C6A);
  final Color lightBlue = const Color(0xFF5BA4CF);
  final Color medBlue = const Color(0xFF2E6F95);

  @override
  Widget build(BuildContext context) {
    final colors = context.kaiColors;
    
    // Fetch goals from easy_localization dynamically
    List<dynamic> goalsList = [];
    try {
      goalsList = tr('aboutUs.goalsList') as List<dynamic>;
    } catch(e) {
      goalsList = [];
    }

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text(tr(LocaleKeys.aboutUs_title), style: TextStyle(color: colors.textPrimary, fontWeight: FontWeight.bold, fontFamily: 'Manrope')),
        backgroundColor: colors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: colors.textPrimary),
          onPressed: () => Get.back(),
        ),
        iconTheme: IconThemeData(color: colors.textPrimary),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- 0.1 Hero Section ---
            Image.asset(
              'assets/images/about_us_header.png',
              width: double.infinity,
              height: 160,
              fit: BoxFit.cover,
            ),

            // --- 0.2 About Description ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildInfoCard(
                title: tr(LocaleKeys.aboutUs_title),
                icon: Icons.info_outline_rounded,
                content: tr('aboutUs.description'),
                colors: colors,
              ),
            ),
            const SizedBox(height: 16),

            // --- 0.3 Mission ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildInfoCard(
                title: tr('aboutUs.mission'),
                icon: Icons.flag_rounded,
                content: tr('aboutUs.missionContent'),
                colors: colors,
              ),
            ),
            const SizedBox(height: 16),

            // --- 0.4 Vision ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildInfoCard(
                title: tr('aboutUs.vision'),
                icon: Icons.visibility_rounded,
                content: tr('aboutUs.visionContent'),
                colors: colors,
              ),
            ),
            const SizedBox(height: 16),

            // --- 1. Stats Cards ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                children: [
                  _buildStatCard(tr('aboutUs.statsLearnersNum'), tr('aboutUs.statsLearnersLabel'), darkPurple),
                  const SizedBox(height: 12),
                  _buildStatCard(tr('aboutUs.statsCertificatesNum'), tr('aboutUs.statsCertificatesLabel'), indigoColor),
                  const SizedBox(height: 12),
                  _buildStatCard(tr('aboutUs.statsClassesNum'), tr('aboutUs.statsClassesLabel'), lightBlue),
                  const SizedBox(height: 12),
                  _buildStatCard(tr('aboutUs.statsInstructorsNum'), tr('aboutUs.statsInstructorsLabel'), medBlue),
                ],
              ),
            ),

            // --- 2. What Makes Us Different ---
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: const TextStyle(fontFamily: 'Manrope', fontSize: 28, fontWeight: FontWeight.w900),
                      children: [
                        TextSpan(
                          text: tr('aboutUs.introTitleDark'),
                          style: TextStyle(color: colors.textPrimary),
                        ),
                        TextSpan(
                          text: '\n${tr('aboutUs.introTitlePrimary')}',
                          style: TextStyle(color: primaryColor),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    tr('aboutUs.introSubtitle'),
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: colors.textPrimary, fontFamily: 'Manrope'),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    tr('aboutUs.introDesc'),
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, height: 1.6, color: colors.textSecondary, fontFamily: 'Manrope'),
                  ),
                ],
              ),
            ),

            // --- 3. Our Goals ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border(
                    top: BorderSide(color: colors.border),
                    left: BorderSide(color: colors.border),
                    right: BorderSide(color: colors.border),
                    bottom: BorderSide(color: primaryColor, width: 4),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.people_alt_outlined, color: primaryColor, size: 28),
                        const SizedBox(width: 8),
                        Text(
                          tr('aboutUs.goalsTitle'),
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: primaryColor, fontFamily: 'Manrope'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    ...goalsList.map((goal) {
                      final boldPart = goal['bold'] ?? '';
                      final regularPart = goal['regular'] ?? '';
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(top: 8),
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: Colors.grey,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: RichText(
                                text: TextSpan(
                                  style: TextStyle(fontSize: 14, height: 1.6, color: colors.textPrimary, fontFamily: 'Manrope'),
                                  children: [
                                    TextSpan(
                                      text: boldPart,
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    TextSpan(
                                      text: regularPart,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),

            // --- 4. Trusted By ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    tr('aboutUs.trustedByTitle'),
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: primaryColor, fontFamily: 'Manrope', height: 1.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    tr('aboutUs.trustedByDesc'),
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, height: 1.6, color: colors.textSecondary, fontFamily: 'Manrope'),
                  ),
                  // Skipping University Logos as requested
                ],
              ),
            ),

            // --- 5. Contact Section ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: colors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.contact_support_rounded,
                          color: primaryColor,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          tr('aboutUs.contactUs'),
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: colors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildContactItem(
                      Icons.language_rounded,
                      tr('aboutUs.website'),
                      'medskai.com',
                      () => _launchUrl('https://medskai.com'),
                      colors,
                    ),
                    _buildContactItem(
                      Icons.email_rounded,
                      tr('aboutUs.email'),
                      'support@medskai.com',
                      () => _launchUrl('mailto:support@medskai.com'),
                      colors,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String number, String label, Color bgColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            number,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: Colors.white, fontFamily: 'Manrope'),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white70, fontFamily: 'Manrope'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({required String title, required IconData icon, required String content, required MedsKaiThemeColors colors}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: primaryColor, size: 28),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: primaryColor, fontFamily: 'Manrope'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: TextStyle(fontSize: 15, height: 1.5, color: colors.textPrimary, fontFamily: 'Manrope'),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String label, String value, VoidCallback onTap, MedsKaiThemeColors colors) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: colors.textSecondary,
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: colors.textSecondary,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: primaryColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}
