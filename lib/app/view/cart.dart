import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/app/util/theme.dart';
import 'package:get/get.dart';
import '../controller/cart_controller.dart';
import '../helper/router.dart';
import '../../l10n/locale_keys.g.dart';
import 'components/cart/cart_item_widget.dart';
import 'components/cart/coupon_input.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  void initState() {
    super.initState();
    Get.find<CartController>().loadCart();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.kaiColors;
    return GetBuilder<CartController>(
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(title: Text(tr(LocaleKeys.cart_title))),
          body: controller.isLoading
              ? const Center(child: CircularProgressIndicator())
              : controller.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.shopping_cart_outlined,
                              size: 64, color: Colors.grey),
                          const SizedBox(height: 16),
                          Text(tr(LocaleKeys.cart_empty)),
                        ],
                      ),
                    )
                  : Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: controller.cart?.items.length ?? 0,
                            itemBuilder: (context, index) {
                              final items = controller.cart?.items ?? [];
                              if (index >= items.length) {
                                return const SizedBox();
                              }
                              return CartItemWidget(
                                key: ValueKey(items[index].id ?? index),
                                item: items[index],
                                onRemove: () => controller.removeItem(
                                  items[index].key ?? '',
                                ),
                              );
                            },
                          ),
                        ),
                        // Coupon input
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: CouponInput(
                            onApply: (code) => controller.applyCoupon(code),
                            message: controller.couponMessage,
                            isSuccess: controller.couponSuccess,
                            isLoading: controller.isApplyingCoupon,
                          ),
                        ),
                        // Totals
                        if (controller.cart?.totals != null)
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: colors.sectionBg,
                              border:
                                  Border(top: BorderSide(color: colors.border)),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(tr(LocaleKeys.cart_subtotal)),
                                    Text(controller
                                            .cart?.totals?.formattedSubtotal ??
                                        ''),
                                  ],
                                ),
                                if (controller.cart?.hasCoupons == true) ...[
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(tr(LocaleKeys.cart_discount),
                                          style: const TextStyle(
                                              color: Colors.green)),
                                      Text(
                                          controller.cart?.totals
                                                  ?.formattedDiscount ??
                                              '',
                                          style: const TextStyle(
                                              color: Colors.green)),
                                    ],
                                  ),
                                ],
                                const Divider(height: 24),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(tr(LocaleKeys.cart_total),
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18)),
                                    Text(
                                        controller
                                                .cart?.totals?.formattedTotal ??
                                            '',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18)),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () =>
                                        Get.toNamed(AppRouter.checkout),
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16),
                                    ),
                                    child: Text(
                                        tr(LocaleKeys.cart_proceedToCheckout)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
        );
      },
    );
  }
}
