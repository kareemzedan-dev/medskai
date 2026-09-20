import 'package:flutter/material.dart';
import 'package:flutter_app/app/backend/models/lesson-model.dart';
import 'package:flutter_app/app/core/services/offline_storage.dart';
import 'package:flutter_app/app/helper/function_helper.dart';
import 'package:flutter_app/app/util/theme.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:get/get.dart';

typedef OnNavigateCallback = void Function(dynamic item);

class AccordionItemLesson extends StatefulWidget {
  final LessonModel item;
  final OnNavigateCallback onNavigate;

  const AccordionItemLesson(
      {Key? key,
      required this.item,
      required this.showContent,
      required this.onNavigate})
      : super(key: key);
  final bool showContent;

  @override
  State<AccordionItemLesson> createState() => _ItemLessonState();
}

class _ItemLessonState extends State<AccordionItemLesson> {
  // Show or hide the content
  bool _showContent = false;
  double get screenWidth => MediaQuery.of(context).size.width;

  @override
  void initState() {
    _showContent = widget.showContent;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.kaiColors;
    return GestureDetector(
        onTap: () => {
              setState(() {
                _showContent = !_showContent;
              })
            },
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
            child: Row(
              children: [
                InkWell(
                  onTap: () {
                    setState(() {
                      _showContent = !_showContent;
                    });
                  },
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  child: Icon(_showContent
                      ? Icons.arrow_drop_up
                      : Icons.arrow_drop_down),
                ),
                Expanded(
                  child: Text(
                    widget.item.title!,
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: colors.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  widget.item.items!.length.toString(),
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontWeight: FontWeight.w600,
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          _showContent
              ? Column(
                      children: List.generate(
                        widget.item.items!.length,
                        (i) => GestureDetector(
                          onTap: () {
                            if (widget.item.items![i].status == "completed" ||
                                widget.item.items![i].locked.toString() ==
                                    'false') {
                              widget.onNavigate(widget.item.items![i]);
                            }
                          },
                          child: Padding(
                              padding: const EdgeInsets.fromLTRB(16, 4, 0, 4),
                                  child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Expanded(
                                          child: Row(
                                            children: [
                                              if (widget.item.items![i].type ==
                                                  'lp_lesson')
                                                Icon(Feather.book,
                                                    color: colors.textSecondary,
                                                    size: 18),
                                              if (widget.item.items![i].type ==
                                                  'lp_quiz')
                                                Icon(Feather.help_circle,
                                                    color: colors.textSecondary,
                                                    size: 18),
                                              if (widget.item.items![i].type ==
                                                  'lp_assignment')
                                                Icon(Feather.file,
                                                    color: colors.textSecondary,
                                                    size: 18),
                                              const SizedBox(
                                                width: 8,
                                              ),
                                              Expanded(
                                                child: Text(
                                                  widget.item.items![i].title!,
                                                  style: TextStyle(
                                                    fontFamily: 'Manrope',
                                                    fontSize: 14,
                                                    color: colors.textSecondary,
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                  maxLines: 1,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        // Offline availability indicator
                                        if (widget.item.items![i].type == 'lp_lesson')
                                          Builder(builder: (_) {
                                            try {
                                              final offline = Get.find<OfflineStorage>();
                                              if (offline.isAvailable(widget.item.items![i].id.toString())) {
                                                return const Padding(
                                                  padding: EdgeInsets.only(right: 4),
                                                  child: Icon(Icons.offline_pin, size: 14, color: MedsKaiColors.success),
                                                );
                                              }
                                            } catch (_) {}
                                            return const SizedBox.shrink();
                                          }),
                                        const SizedBox(width: 4),
                                    //check icon quiz
                                    (widget.item.items![i].type == 'lp_quiz' &&
                                            widget.item.items![i].status != '')
                                        ? ((widget.item.items![i].graduation !=
                                                    '' &&
                                                widget.item.items![i]
                                                        .graduation ==
                                                    'passed')
                                            ? const Icon(
                                                Icons.check_circle,
                                                size: 18,
                                                color: MedsKaiColors.success,
                                              )
                                            : const Icon(Icons.close,
                                                color: MedsKaiColors.error, size: 16))
                                        : Text(''),

                                    if (['completed', 'evaluated'].contains(
                                            widget.item.items![i].status) &&
                                        widget.item.items![i].type != 'lp_quiz')
                                      const Icon(
                                        Icons.check_circle,
                                        size: 18,
                                        color: MedsKaiColors.success,
                                      ),
                                    if (widget.item.items![i].status != 'failed' && !['completed', 'evaluated'].contains(widget.item.items![i].status) && widget.item.items![i].status == '')
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          if (widget.item.items![i].preview ==
                                              true)
                                            const Icon(Icons.remove_red_eye,
                                                size: 16, color: MedsKaiColors.primary),
                                          if (widget.item.items![i].duration !=
                                              '')
                                            SizedBox(
                                              width: 2,
                                            ),
                                          if (widget.item.items![i].duration !=
                                              '')
                                            Text(
                                            //widget.item.items![i].duration!,
                                              Helper.handleTranslationsDuration(widget.item.items![i].duration!),
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  fontFamily: 'Manrope',
                                                  fontSize: 10,
                                                  color: colors.textSecondary),
                                            ),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          if (widget.item.items![i].locked ==
                                              true)
                                            Icon(
                                              Icons.lock,
                                              color: colors.textSecondary,
                                              size: 18,
                                            ),
                                        ],
                                      ),
                                  ])),
                        ),
                      ),
                )
              : Container()
        ]));
  }
}
