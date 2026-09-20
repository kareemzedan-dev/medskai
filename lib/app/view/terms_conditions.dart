import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/app/util/theme.dart';
import 'package:flutter_app/l10n/locale_keys.g.dart';
import 'package:get/get.dart';

class TermsConditionsScreen extends StatelessWidget {
  TermsConditionsScreen({super.key});

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
          tr(LocaleKeys.terms_title),
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
                    MedsKaiColors.secondary,
                    MedsKaiColors.primary,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.description_rounded,
                    size: 48,
                    color: MedsKaiColors.white,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    tr(LocaleKeys.terms_title),
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
              number: '1',
              title: isArabic ? 'قبول الشروط' : 'Acceptance of Terms',
              content: isArabic
                ? 'بالوصول إلى خدمات MedsKai أو استخدامها، فإنك توافق على الالتزام بهذه الشروط والأحكام. إذا كنت لا توافق على هذه الشروط، يرجى عدم استخدام خدماتنا.'
                : 'By accessing or using MedsKai\'s services, you agree to be bound by these Terms and Conditions. If you do not agree to these terms, please do not use our services.',
            ),

            _buildSection(
              colors: colors,
              number: '2',
              title: isArabic ? 'وصف الخدمات' : 'Description of Services',
              content: isArabic
                ? 'توفر MedsKai دورات تعليمية طبية عبر الإنترنت ومواد تعليمية وبرامج شهادات للمهنيين الصحيين. نحتفظ بالحق في تعديل أو إيقاف أي خدمة في أي وقت.'
                : 'MedsKai provides online medical education courses, learning materials, and certification programs for healthcare professionals. We reserve the right to modify or discontinue any service at any time.',
            ),

            _buildSection(
              colors: colors,
              number: '3',
              title: isArabic ? 'حسابات المستخدمين' : 'User Accounts',
              content: isArabic
                ? 'أنت مسؤول عن:\n• الحفاظ على سرية حسابك\n• جميع الأنشطة التي تحدث تحت حسابك\n• إخطارنا بأي استخدام غير مصرح به\n• تقديم معلومات دقيقة وكاملة'
                : 'You are responsible for:\n• Maintaining the confidentiality of your account\n• All activities that occur under your account\n• Notifying us of any unauthorized use\n• Providing accurate and complete information',
            ),

            _buildSection(
              colors: colors,
              number: '4',
              title: isArabic ? 'شروط الدفع' : 'Payment Terms',
              content: isArabic
                ? '• رسوم الدورات غير قابلة للاسترداد ما لم يُذكر خلاف ذلك\n• تتجدد اشتراكات العضوية تلقائياً ما لم يتم إلغاؤها\n• جميع الأسعار قابلة للتغيير مع إشعار مسبق\n• توافق على دفع جميع الرسوم بالأسعار السارية'
                : '• Course fees are non-refundable unless otherwise stated\n• Membership subscriptions auto-renew unless cancelled\n• All prices are subject to change with notice\n• You agree to pay all charges at the prices in effect',
            ),

            _buildSection(
              colors: colors,
              number: '5',
              title: isArabic ? 'الملكية الفكرية' : 'Intellectual Property',
              content: isArabic
                ? 'جميع المحتوى على MedsKai، بما في ذلك الدورات والفيديوهات والصور والنصوص، هو ملك MedsKai أو موردي المحتوى. لا يجوز لك إعادة إنتاج أو توزيع أو إنشاء أعمال مشتقة دون إذن.'
                : 'All content on MedsKai, including courses, videos, images, and text, is the property of MedsKai or its content suppliers. You may not reproduce, distribute, or create derivative works without permission.',
            ),

            _buildSection(
              colors: colors,
              number: '6',
              title: isArabic ? 'الأنشطة المحظورة' : 'Prohibited Activities',
              content: isArabic
                ? 'توافق على عدم:\n• مشاركة بيانات اعتماد حسابك\n• تنزيل أو توزيع محتوى الدورات\n• استخدام الخدمة لأغراض غير قانونية\n• محاولة الوصول غير المصرح به\n• التدخل في تشغيل الخدمة'
                : 'You agree not to:\n• Share your account credentials\n• Download or distribute course content\n• Use the service for unlawful purposes\n• Attempt to gain unauthorized access\n• Interfere with the service\'s operation',
            ),

            _buildSection(
              colors: colors,
              number: '7',
              title: isArabic ? 'الإنهاء' : 'Termination',
              content: isArabic
                ? 'يجوز لنا إنهاء أو تعليق حسابك في أي وقت بسبب انتهاكات هذه الشروط. عند الإنهاء، سيتوقف حقك في استخدام الخدمة فوراً.'
                : 'We may terminate or suspend your account at any time for violations of these terms. Upon termination, your right to use the service will immediately cease.',
            ),

            _buildSection(
              colors: colors,
              number: '8',
              title: isArabic ? 'تحديد المسؤولية' : 'Limitation of Liability',
              content: isArabic
                ? 'لن تكون MedsKai مسؤولة عن أي أضرار غير مباشرة أو عرضية أو خاصة أو تبعية أو عقابية ناتجة عن استخدامك أو عدم قدرتك على استخدام الخدمة.'
                : 'MedsKai shall not be liable for any indirect, incidental, special, consequential, or punitive damages resulting from your use of or inability to use the service.',
            ),

            _buildSection(
              colors: colors,
              number: '9',
              title: isArabic ? 'تغييرات الشروط' : 'Changes to Terms',
              content: isArabic
                ? 'نحتفظ بالحق في تعديل هذه الشروط في أي وقت. سنخطر المستخدمين بالتغييرات الهامة عبر البريد الإلكتروني أو إشعار داخل التطبيق.'
                : 'We reserve the right to modify these terms at any time. We will notify users of significant changes via email or in-app notification.',
            ),

            _buildSection(
              colors: colors,
              number: '10',
              title: isArabic ? 'اتصل بنا' : 'Contact',
              content: isArabic
                ? 'للأسئلة حول هذه الشروط، تواصل معنا على:\nالبريد الإلكتروني: legal@medskai.com'
                : 'For questions about these Terms, contact us at:\nEmail: legal@medskai.com',
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required dynamic colors,
    required String number,
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
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      MedsKaiColors.primary,
                      MedsKaiColors.primary.withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    number,
                    style: const TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: MedsKaiColors.white,
                    ),
                  ),
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
