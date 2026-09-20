import 'package:flutter/material.dart';
import 'package:flutter_app/app/backend/mobx-store/init_store.dart';
import 'package:flutter_app/app/backend/models/lesson-model.dart';
import 'package:flutter_app/app/backend/mobx-store/course_store.dart';
import 'package:flutter_app/app/core/services/offline_storage.dart';
import 'package:flutter_app/app/util/theme.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:get/get.dart';

import '../../controller/learning_controller.dart';
import '../../helper/function_helper.dart';

typedef OnNavigateCallback = void Function(dynamic item);

class ItemLessonAccordion extends StatefulWidget {
  final LessonModel item;

  final OnNavigateCallback onNavigate;
  final bool showContent;
  final int lessonIndex;
  final ItemLesson itemLesson;
  final LearningController controller;

  const ItemLessonAccordion({
    Key? key,
    required this.item,
    required this.onNavigate,
    required this.showContent,
    required this.itemLesson,
    required this.lessonIndex,
    required this.controller,
  }) : super(key: key);

  @override
  State<ItemLessonAccordion> createState() => _ItemLessonState();
}

class _ItemLessonState extends State<ItemLessonAccordion> {
  final courseStore = locator<CourseStore>();

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
      child: Column(
        children: [
          Container(
            width: screenWidth * 0.7,
            padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
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
                          child: Icon(
                            _showContent
                                ? Icons.arrow_drop_up
                                : Icons.arrow_drop_down,
                            color: colors.textPrimary,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            widget.item.title!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'Manrope',
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              color: colors.textPrimary,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: MedsKaiColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    (widget.item.items?.length ?? 0).toString(),
                    style: const TextStyle(
                      fontFamily: 'Manrope',
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color: MedsKaiColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_showContent)
              Column(
                    children: List.generate(
                      widget.item.items?.length ?? 0,
                      (i) => GestureDetector(
                          onTap: () {
                            widget.onNavigate(widget.item.items?[i]);
                          },
                          child: Container(
                            padding: const EdgeInsets.fromLTRB(14, 8, 10, 8),
                            decoration: BoxDecoration(
                              color: widget.itemLesson.id == widget.item.items?[i].id
                                  ? MedsKaiColors.primary.withOpacity(0.08)
                                  : null,
                              border: widget.itemLesson.id == widget.item.items?[i].id
                                  ? Border(left: BorderSide(color: MedsKaiColors.primary, width: 3))
                                  : null,
                            ),
                            child: Opacity(
                              opacity: (courseStore.detail?.status ==
                                              'finished' ||
                                          courseStore.detail?.status == '') &&
                                      widget.item.items?[i].preview == null
                                  ? 0.5
                                  : 1.0,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Row(children: [
                                      if (widget.item.items?[i].type == 'lp_lesson')
                                        const Icon(Feather.book,
                                            color: MedsKaiColors.primary,
                                            size: 14),
                                      if (widget.item.items?[i].type == 'lp_quiz')
                                        const Icon(Feather.help_circle,
                                            color: MedsKaiColors.accent,
                                            size: 14),
                                      if (widget.item.items?[i].type ==
                                          'lp_assignment')
                                        const Icon(Feather.file,
                                            color: MedsKaiColors.info, size: 14),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          widget.item.items?[i].title ?? '',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontFamily: 'Manrope',
                                            fontSize: 13,
                                            fontWeight: widget.itemLesson.id ==
                                                    widget.item.items?[i].id
                                                ? FontWeight.w700
                                                : FontWeight.w400,
                                            color: widget.itemLesson.id ==
                                                    widget.item.items?[i].id
                                                ? MedsKaiColors.primary
                                                : colors.textSecondary,
                                          ),
                                        ),
                                      )
                                    ]),
                                  ),
                                  // Offline availability indicator (lesson, quiz, assignment)
                                  Builder(builder: (_) {
                                    try {
                                      final offline = Get.find<OfflineStorage>();
                                      final itemId = widget.item.items![i].id.toString();
                                      final type = widget.item.items?[i].type;
                                      final key = type == 'lp_quiz' ? 'quiz_$itemId'
                                          : type == 'lp_assignment' ? 'assignment_$itemId'
                                          : itemId;
                                      if (offline.isAvailable(key)) {
                                        return const Padding(
                                          padding: EdgeInsets.only(right: 4),
                                          child: Icon(Icons.offline_pin, size: 12, color: MedsKaiColors.success),
                                        );
                                      }
                                    } catch (_) {}
                                    return const SizedBox.shrink();
                                  }),
                                  if (['completed', 'evaluated'].contains(
                                          widget.item.items?[i].status) &&
                                      widget.item.items?[i].type != "lp_quiz")
                                    const Icon(
                                      Icons.check_circle,
                                      size: 16,
                                      color: MedsKaiColors.success,
                                    ),
                                  // check quiz icon - passed
                                  if (widget.item.items?[i].type == "lp_quiz" &&
                                      widget.item.items?[i].graduation == 'passed')
                                    const Icon(
                                      Icons.check_circle,
                                      size: 16,
                                      color: MedsKaiColors.success,
                                    ),
                                  // check quiz icon - failed
                                  if (widget.item.items?[i].type == "lp_quiz" &&
                                      widget.item.items?[i].graduation != '' &&
                                      widget.item.items?[i].graduation != null &&
                                      widget.item.items?[i].graduation != 'passed')
                                    const Icon(Icons.close,
                                        color: MedsKaiColors.error,
                                        size: 16),

                                  if (widget.item.items?[i].status != 'failed' &&
                                      !['completed', 'evaluated'].contains(
                                          widget.item.items?[i].status) &&
                                      widget.item.items?[i].status == '')
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        if (widget.item.items?[i].preview == true)
                                          const Icon(Icons.remove_red_eye,
                                              size: 16, color: MedsKaiColors.success),
                                        const SizedBox(width: 5),
                                        if (widget.item.items?[i].locked == true)
                                          Icon(
                                            Icons.lock,
                                            color: colors.textSecondary,
                                            size: 16,
                                          ),
                                        if ((widget.item.items?[i].duration != '' &&
                                            widget.item.items?[i].graduation == ''))
                                          Text(
                                            Helper.handleTranslationsDuration(
                                                widget.item.items?[i].duration ?? ''),
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontFamily: 'Manrope',
                                              fontSize: 10,
                                              fontWeight: FontWeight.w500,
                                              color: colors.textSecondary,
                                            ),
                                          ),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
        ],
      ),
    );
  }
}
