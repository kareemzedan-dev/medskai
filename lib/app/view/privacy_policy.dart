import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/app/util/theme.dart';
import 'package:flutter_app/l10n/locale_keys.g.dart';
import 'package:get/get.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.kaiColors;
    final isArabic = context.locale.languageCode == 'ar';

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
          tr(LocaleKeys.privacyPolicy_title),
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: colors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    MedsKaiColors.primary,
                    MedsKaiColors.secondary,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.privacy_tip_rounded,
                    size: 48,
                    color: MedsKaiColors.white,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    tr(LocaleKeys.privacyPolicy_title),
                    style: const TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: MedsKaiColors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isArabic ? 'آخر تحديث: يناير 2024' : 'Last updated: January 2024',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: MedsKaiColors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Content Sections
            _buildSection(
              colors: colors,
              icon: Icons.info_outline_rounded,
              title: isArabic ? 'مقدمة' : 'Introduction',
              content: isArabic
                ? 'تلتزم MedsKai بحماية خصوصيتك. توضح سياسة الخصوصية هذه كيفية جمع معلوماتك واستخدامها والإفصاح عنها وحمايتها عند استخدام تطبيقنا وخدماتنا.'
                : 'MedsKai is committed to protecting your privacy. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our mobile application and services.',
            ),

            _buildSection(
              colors: colors,
              icon: Icons.folder_rounded,
              title: isArabic ? 'المعلومات التي نجمعها' : 'Information We Collect',
              content: isArabic
                ? 'نجمع المعلومات التي تقدمها لنا مباشرة، بما في ذلك:\n• معلومات الحساب (الاسم، البريد الإلكتروني، كلمة المرور)\n• معلومات الملف الشخصي (النبذة، الصورة)\n• بيانات تقدم الدورات وإتمامها\n• معلومات الدفع لشراء الدورات\n• معلومات الجهاز وبيانات الاستخدام'
                : 'We collect information that you provide directly to us, including:\n• Account information (name, email, password)\n• Profile information (bio, avatar)\n• Course progress and completion data\n• Payment information for course purchases\n• Device information and usage data',
            ),

            _buildSection(
              colors: colors,
              icon: Icons.settings_rounded,
              title: isArabic ? 'كيف نستخدم معلوماتك' : 'How We Use Your Information',
              content: isArabic
                ? 'نستخدم المعلومات التي نجمعها من أجل:\n• تقديم خدماتنا والحفاظ عليها\n• معالجة المعاملات وإرسال المعلومات ذات الصلة\n• إرسال إشعارات حول دوراتك\n• تحسين خدماتنا وتطوير ميزات جديدة\n• الرد على تعليقاتك وأسئلتك'
                : 'We use the information we collect to:\n• Provide and maintain our services\n• Process transactions and send related information\n• Send notifications about your courses\n• Improve our services and develop new features\n• Respond to your comments and questions',
            ),

            _buildSection(
              colors: colors,
              icon: Icons.security_rounded,
              title: isArabic ? 'أمان البيانات' : 'Data Security',
              content: isArabic
                ? 'نطبق إجراءات أمنية تقنية وتنظيمية مناسبة لحماية معلوماتك الشخصية. ومع ذلك، لا توجد طريقة نقل عبر الإنترنت آمنة بنسبة 100%.'
                : 'We implement appropriate technical and organizational security measures to protect your personal information. However, no method of transmission over the Internet is 100% secure.',
            ),

            _buildSection(
              colors: colors,
              icon: Icons.share_rounded,
              title: isArabic ? 'خدمات الطرف الثالث' : 'Third-Party Services',
              content: isArabic
                ? 'قد نشارك المعلومات مع مقدمي خدمات الطرف الثالث الذين يقدمون خدمات نيابة عنا، مثل معالجة الدفع وتحليل البيانات وتسليم البريد الإلكتروني.'
                : 'We may share information with third-party service providers who perform services on our behalf, such as payment processing, data analysis, and email delivery.',
            ),

            _buildSection(
              colors: colors,
              icon: Icons.cookie_rounded,
              title: isArabic ? 'ملفات تعريف الارتباط والتتبع' : 'Cookies and Tracking',
              content: isArabic
                ? 'نستخدم ملفات تعريف الارتباط وتقنيات التتبع المماثلة لتتبع النشاط على خدمتنا والاحتفاظ بمعلومات معينة لتحسين تجربتك.'
                : 'We use cookies and similar tracking technologies to track activity on our service and hold certain information to improve your experience.',
            ),

            _buildSection(
              colors: colors,
              icon: Icons.verified_user_rounded,
              title: isArabic ? 'حقوقك' : 'Your Rights',
              content: isArabic
                ? 'لديك الحق في:\n• الوصول إلى بياناتك الشخصية\n• تصحيح البيانات غير الدقيقة\n• طلب حذف بياناتك\n• إلغاء الاشتراك في الاتصالات التسويقية\n• تصدير بياناتك'
                : 'You have the right to:\n• Access your personal data\n• Correct inaccurate data\n• Request deletion of your data\n• Opt-out of marketing communications\n• Export your data',
            ),

            _buildSection(
              colors: colors,
              icon: Icons.email_rounded,
              title: isArabic ? 'اتصل بنا' : 'Contact Us',
              content: isArabic
                ? 'إذا كانت لديك أسئلة حول سياسة الخصوصية هذه، يرجى التواصل معنا على:\nالبريد الإلكتروني: privacy@medskai.com'
                : 'If you have questions about this Privacy Policy, please contact us at:\nEmail: privacy@medskai.com',
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required dynamic colors,
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: MedsKaiColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: MedsKaiColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: colors.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
