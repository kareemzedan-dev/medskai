import 'package:flutter/material.dart';
import 'package:flutter_app/app/backend/models/lesson-model.dart';
import 'package:flutter_app/app/util/theme.dart';
import 'package:flutter_app/app/view/components/item-lesson-accordion.dart';

import '../../controller/learning_controller.dart';

typedef OnNavigateCallback = void Function(dynamic item);

class AccordionLessonLearning extends StatefulWidget {
  final List<LessonModel> data;

  // final void onNavigate;
  final OnNavigateCallback onNavigate;
  final int index;
  final LearningController controller;
  final ItemLesson itemLesson;

  const AccordionLessonLearning({
    Key? key,
    required this.data,
    required this.onNavigate,
    required this.index,
    required this.itemLesson,
    required this.controller,
  }) : super(key: key);

  @override
  State<AccordionLessonLearning> createState() => _AccordionState();
}

class _AccordionState extends State<AccordionLessonLearning> {
  double get screenWidth => MediaQuery.of(context).size.width;

  @override
  Widget build(BuildContext context) {
    final colors = context.kaiColors;
    final percent = widget.controller.progressPercent;
    final completed = widget.controller.completedCount;
    final total = widget.controller.totalCount;

    return SizedBox(
      width: screenWidth * 0.7,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Progress Header ──
            if (total > 0)
              Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${percent.toStringAsFixed(0)}% Complete · $completed of $total items',
                      style: const TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: MedsKaiColors.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: percent / 100,
                        minHeight: 6,
                        backgroundColor: colors.border,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                            MedsKaiColors.primary),
                      ),
                    ),
                  ],
                ),
              ),

            // ── Section Accordion List ──
            ...List.generate(
              widget.data.length,
              (index) => ItemLessonAccordion(
                item: widget.data[index],
                onNavigate: widget.onNavigate,
                showContent: index == widget.index,
                lessonIndex: index,
                itemLesson: widget.itemLesson,
                controller: widget.controller,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
