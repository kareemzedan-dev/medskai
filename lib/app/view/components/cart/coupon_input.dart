import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../l10n/locale_keys.g.dart';

class CouponInput extends StatefulWidget {
  final Function(String) onApply;
  final String message;
  final bool isSuccess;
  final bool isLoading;

  const CouponInput({
    super.key,
    required this.onApply,
    this.message = '',
    this.isSuccess = false,
    this.isLoading = false,
  });

  @override
  State<CouponInput> createState() => _CouponInputState();
}

class _CouponInputState extends State<CouponInput> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) {
                  if (_controller.text.trim().isNotEmpty) {
                    widget.onApply(_controller.text.trim());
                  }
                },
                decoration: InputDecoration(
                  hintText: tr(LocaleKeys.cart_couponPlaceholder),
                  border: const OutlineInputBorder(),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  isDense: true,
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: widget.isLoading
                  ? null
                  : () {
                      if (_controller.text.trim().isNotEmpty) {
                        widget.onApply(_controller.text.trim());
                      }
                    },
              child: widget.isLoading
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : Text(tr(LocaleKeys.cart_applyCoupon)),
            ),
          ],
        ),
        if (widget.message.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            widget.message,
            style: TextStyle(
              color: widget.isSuccess ? Colors.green : Colors.red,
              fontSize: 12,
            ),
          ),
        ],
      ],
    );
  }
}
