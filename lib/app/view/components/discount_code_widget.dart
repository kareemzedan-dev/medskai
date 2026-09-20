import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/app/util/theme.dart';
import 'package:flutter_app/l10n/locale_keys.g.dart';

class DiscountCodeWidget extends StatefulWidget {
  final Function(String code, double discountPercentage)? onDiscountApplied;

  const DiscountCodeWidget({
    super.key,
    this.onDiscountApplied,
  });

  @override
  State<DiscountCodeWidget> createState() => _DiscountCodeWidgetState();
}

class _DiscountCodeWidgetState extends State<DiscountCodeWidget> {
  final TextEditingController _codeController = TextEditingController();
  bool _isExpanded = false;
  bool _isLoading = false;
  String? _message;
  bool _isSuccess = false;

  // Sample discount codes - in real app, this would be validated via API
  final Map<String, double> _validCodes = {
    'FIRST1000': 20.0,
    'WELCOME10': 10.0,
    'MEDSKAI25': 25.0,
    'STUDENT15': 15.0,
  };

  void _applyCode() async {
    final code = _codeController.text.trim().toUpperCase();

    if (code.isEmpty) {
      setState(() {
        _message = tr(LocaleKeys.discountCode_placeholder);
        _isSuccess = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _message = null;
    });

    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    if (_validCodes.containsKey(code)) {
      final discount = _validCodes[code]!;
      setState(() {
        _isLoading = false;
        _message = '${tr(LocaleKeys.discountCode_applied)} ($discount%)';
        _isSuccess = true;
      });
      widget.onDiscountApplied?.call(code, discount);
    } else {
      setState(() {
        _isLoading = false;
        _message = tr(LocaleKeys.discountCode_invalid);
        _isSuccess = false;
      });
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.kaiColors;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: colors.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        children: [
          // Header
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: MedsKaiColors.accent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.local_offer_rounded,
                      color: MedsKaiColors.accent,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      tr(LocaleKeys.discountCode_title),
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: colors.textPrimary,
                      ),
                    ),
                  ),
                  Icon(
                    _isExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: colors.textSecondary,
                  ),
                ],
              ),
            ),
          ),

          // Expandable content
          if (_isExpanded) ...[
            Divider(height: 1, color: colors.border),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Input field and button
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _codeController,
                          textCapitalization: TextCapitalization.characters,
                          decoration: InputDecoration(
                            hintText: tr(LocaleKeys.discountCode_placeholder),
                            hintStyle: TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: colors.textSecondary,
                            ),
                            filled: true,
                            fillColor: colors.sectionBg,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: colors.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _applyCode,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: MedsKaiColors.primary,
                            foregroundColor: MedsKaiColors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: MedsKaiColors.white,
                                  ),
                                )
                              : Text(
                                  tr(LocaleKeys.discountCode_apply),
                                  style: const TextStyle(
                                    fontFamily: 'Manrope',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),

                  // Message
                  if (_message != null) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(
                          _isSuccess
                              ? Icons.check_circle_rounded
                              : Icons.error_outline_rounded,
                          size: 16,
                          color: _isSuccess
                              ? MedsKaiColors.success
                              : MedsKaiColors.error,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _message!,
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: _isSuccess
                                ? MedsKaiColors.success
                                : MedsKaiColors.error,
                          ),
                        ),
                      ],
                    ),
                  ],

                  // Hint
                  const SizedBox(height: 12),
                  Text(
                    tr(LocaleKeys.discount_exampleCodes),
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      color: colors.textSecondary.withOpacity(0.7),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
