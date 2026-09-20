import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/app/backend/mobx-store/session_store.dart';
import 'package:flutter_app/app/helper/function_helper.dart';
import 'package:flutter_app/app/helper/router.dart';
import 'package:flutter_app/app/util/theme.dart';
import 'package:flutter_app/l10n/locale_keys.g.dart';
import 'package:get/get.dart';
import 'package:get_it_mixin/get_it_mixin.dart';
import 'package:indexed/indexed.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

typedef OnNavigateCallback = void Function(int page);

class MyOrderScreen extends StatelessWidget with GetItMixin {
  final PageController pageController;
  final OnNavigateCallback goBack;

  MyOrderScreen(
      {super.key, required this.pageController, required this.goBack});

  void onLogin() {
    Future.delayed(Duration.zero, () {
      Get.offAllNamed(AppRouter.getLoginRoute());
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.kaiColors;
    final screenWidth = MediaQuery.of(context).size.width;
    final sessionStore = Provider.of<SessionStore>(context);
    List<Map<String, dynamic>> getData() {
      final data = sessionStore.userInfo?.tabs["orders"]["content"];
      final List<Map<String, dynamic>> result = [];

      if (data != null && data.isNotEmpty) {
        data.forEach((key, order) {
          result.add({
            'Id': order['order_key'] ?? 0,
            'Date': DateFormat('yyyy/MM/dd').format(DateTime.parse(order['date'])),
            'Status': order['status'],
            'Total': order['total'],
          });
        });
      }

      return result;
    }

    return Scaffold(
      backgroundColor: colors.background,
      drawerEnableOpenDragGesture: false,
      body: Stack(
        children: <Widget>[
          // Gradient header background
          Indexed(
            index: 1,
            child: Positioned(
              right: 0,
              top: 0,
              left: 0,
              child: Container(
                width: screenWidth,
                height: (200 / 375) * screenWidth,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      MedsKaiColors.accent.withOpacity(0.12),
                      MedsKaiColors.primary.withOpacity(0.06),
                      colors.sectionBg,
                    ],
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                // Header
                Container(
                  height: 60.0,
                  width: screenWidth,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      IconButton(
                        onPressed: () => goBack(0),
                        icon: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: colors.cardBg,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF6B39BF).withOpacity(0.15),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: colors.textPrimary,
                            size: 18,
                          ),
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [MedsKaiColors.primary, MedsKaiColors.primary.withOpacity(0.85)],
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.shopping_bag_rounded,
                              color: MedsKaiColors.white,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            tr(LocaleKeys.myOrders_title),
                            style: TextStyle(
                              fontFamily: 'Manrope',
                              fontWeight: FontWeight.w800,
                              fontSize: 22,
                              color: colors.textPrimary,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 44),
                    ],
                  ),
                ),
                // Content
                getData().isEmpty
                    ? Expanded(
                        child: Center(
                          child: _buildEmptyState(context),
                        ),
                      )
                    : Expanded(
                        child: renderItemOrders(getData()),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final colors = context.kaiColors;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                MedsKaiColors.accent.withOpacity(0.15),
                MedsKaiColors.accent.withOpacity(0.08),
              ],
            ),
            borderRadius: BorderRadius.circular(28),
          ),
          child: Icon(
            Icons.shopping_bag_outlined,
            size: 50,
            color: MedsKaiColors.accent.withOpacity(0.5),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          tr(LocaleKeys.dataNotFound),
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: colors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          tr(LocaleKeys.empty_ordersHint),
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: colors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget renderItemOrders(value) {
    return ListView.builder(
      itemCount: value.length,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemBuilder: (context, index) {
        final colors = context.kaiColors;
        if (index < value.length) {
          return Container(
            key: ValueKey(index),
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6B39BF).withOpacity(0.15),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildOrderRow(
                  context,
                  tr(LocaleKeys.myOrders_order),
                  value[index]['Id'],
                  isFirst: true,
                ),
                const SizedBox(height: 12),
                _buildOrderRow(
                  context,
                  tr(LocaleKeys.myOrders_date),
                  value[index]['Date'],
                ),
                const SizedBox(height: 12),
                _buildOrderRow(
                  context,
                  tr(LocaleKeys.myOrders_status),
                  Helper.handleTranslationsStatusOrder(value[index]['Status']).toString(),
                  isStatus: true,
                  status: value[index]['Status'],
                ),
                const SizedBox(height: 12),
                _buildOrderRow(
                  context,
                  tr(LocaleKeys.myOrders_total),
                  value[index]['Total'],
                  isTotal: true,
                ),
              ],
            ),
          );
        } else {
          return Container();
        }
      },
    );
  }

  Widget _buildOrderRow(BuildContext context, String label, String value, {
    bool isFirst = false,
    bool isStatus = false,
    bool isTotal = false,
    String? status,
  }) {
    final colors = context.kaiColors;
    Color statusColor = colors.textPrimary;
    if (isStatus) {
      switch (status?.toLowerCase()) {
        case 'completed':
          statusColor = MedsKaiColors.success;
          break;
        case 'pending':
          statusColor = MedsKaiColors.accent;
          break;
        case 'failed':
        case 'cancelled':
          statusColor = MedsKaiColors.error;
          break;
        default:
          statusColor = MedsKaiColors.info;
      }
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: colors.textSecondary,
          ),
        ),
        isStatus
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  value,
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              )
            : Text(
                value,
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: isFirst ? 15 : 14,
                  fontWeight: isFirst || isTotal ? FontWeight.w700 : FontWeight.w600,
                  color: isTotal ? MedsKaiColors.primary : colors.textPrimary,
                ),
              ),
      ],
    );
  }

}
