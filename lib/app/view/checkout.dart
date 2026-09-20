import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/app/helper/validators.dart';
import 'package:get/get.dart';
import '../controller/cart_controller.dart';
import '../helper/router.dart';
import '../../l10n/locale_keys.g.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CartController>(
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(title: Text(tr(LocaleKeys.cart_checkout))),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(tr(LocaleKeys.cart_billingInfo),
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _firstNameController,
                    decoration: InputDecoration(
                      labelText: tr(LocaleKeys.cart_firstName),
                      border: const OutlineInputBorder(),
                    ),
                    validator: (v) => AppValidators.required(v, 'First name'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _lastNameController,
                    decoration: InputDecoration(
                      labelText: tr(LocaleKeys.cart_lastName),
                      border: const OutlineInputBorder(),
                    ),
                    validator: (v) => AppValidators.required(v, 'Last name'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: tr(LocaleKeys.cart_email),
                      border: const OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) => AppValidators.email(v),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _phoneController,
                    decoration: InputDecoration(
                      labelText: tr(LocaleKeys.cart_phone),
                      border: const OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (v) => AppValidators.phone(v),
                  ),
                  const SizedBox(height: 24),
                  if (controller.cart?.totals != null)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(tr(LocaleKeys.cart_total),
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        Text(controller.cart?.totals?.formattedTotal ?? '',
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: controller.isCheckingOut
                          ? null
                          : () async {
                              if (!_formKey.currentState!.validate()) return;
                              final success = await controller.checkout({
                                'billing_address': {
                                  'first_name': _firstNameController.text,
                                  'last_name': _lastNameController.text,
                                  'email': _emailController.text,
                                  'phone': _phoneController.text,
                                },
                              });
                              if (success) {
                                Get.snackbar(
                                    '', tr(LocaleKeys.cart_orderSuccess),
                                    snackPosition: SnackPosition.BOTTOM);
                                Get.offAllNamed(AppRouter.tabsBarRoutes);
                              } else {
                                Get.snackbar(
                                    '', tr(LocaleKeys.cart_orderFailed),
                                    snackPosition: SnackPosition.BOTTOM);
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: controller.isCheckingOut
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(tr(LocaleKeys.cart_placeOrder)),
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
