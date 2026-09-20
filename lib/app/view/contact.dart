import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/app/helper/validators.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../controller/contact_controller.dart';
import '../../l10n/locale_keys.g.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ContactController>(
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(title: Text(tr(LocaleKeys.contact_title))),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: controller.isSuccess
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check_circle, size: 80, color: Colors.green),
                        const SizedBox(height: 16),
                        Text(controller.statusMessage,
                            style: Theme.of(context).textTheme.titleMedium,
                            textAlign: TextAlign.center),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () => controller.resetState(),
                          child: Text(tr(LocaleKeys.ui_sendAnotherMessage)),
                        ),
                      ],
                    ),
                  )
                : Form(
                    key: controller.formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // WhatsApp Quick Contact Card
                        Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: const Color(0xFF25D366).withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          color: const Color(0xFF25D366).withOpacity(0.06),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () async {
                              final whatsappUrl = Uri.parse("https://wa.me/201031974400");
                              try {
                                if (await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication)) {
                                  // Launched successfully
                                } else {
                                  throw 'Could not launch $whatsappUrl';
                                }
                              } catch (e) {
                                debugPrint("Error launching WhatsApp: $e");
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF25D366),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.chat_rounded,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          tr(LocaleKeys.contact_viaWhatsApp),
                                          style: const TextStyle(
                                            fontFamily: 'Manrope',
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF075E54),
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        const Text(
                                          "01031974400",
                                          style: TextStyle(
                                            fontFamily: 'Manrope',
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black54,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    color: Color(0xFF075E54),
                                    size: 14,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        if (controller.hasError && controller.statusMessage.isNotEmpty)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: Colors.red[50],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(controller.statusMessage, style: TextStyle(color: Colors.red[700])),
                          ),
                        TextFormField(
                          controller: controller.nameController,
                          decoration: InputDecoration(
                            labelText: tr(LocaleKeys.contact_name),
                            border: const OutlineInputBorder(),
                          ),
                          validator: (value) => AppValidators.required(value, 'Name'),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: controller.emailController,
                          decoration: InputDecoration(
                            labelText: tr(LocaleKeys.contact_email),
                            border: const OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) => AppValidators.email(value),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: controller.subjectController,
                          decoration: InputDecoration(
                            labelText: tr(LocaleKeys.contact_subject),
                            border: const OutlineInputBorder(),
                          ),
                          validator: (value) => AppValidators.required(value, 'Subject'),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: controller.messageController,
                          decoration: InputDecoration(
                            labelText: tr(LocaleKeys.contact_message),
                            border: const OutlineInputBorder(),
                            alignLabelWithHint: true,
                          ),
                          maxLines: 5,
                          validator: (value) => AppValidators.required(value, 'Message'),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: controller.isLoading ? null : () => controller.submitForm(),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: controller.isLoading
                                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                                : Text(tr(LocaleKeys.contact_send)),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        );
      },
    );
  }
}
