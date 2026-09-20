import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_app/app/backend/mobx-store/course_store.dart';
import 'package:flutter_app/app/backend/mobx-store/init_store.dart';
import 'package:flutter_app/app/backend/mobx-store/learning_quiz_store.dart';
import 'package:flutter_app/app/backend/models/learning-lesson-model.dart';
import 'package:flutter_app/app/controller/learning_controller.dart';
import 'package:flutter_app/app/util/theme.dart';
import 'package:flutter_app/app/view/components/countdown.dart';
import 'package:flutter_app/app/view/components/uptime.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/get_state_manager.dart';

import '../../../../l10n/locale_keys.g.dart';

class _LearningStartQuiz extends State<LearningStartQuiz> {
  final courseStore = locator<CourseStore>();
  final learningQuizStore = locator<LearningQuizStore>();
  late double screenWidth;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    screenWidth = MediaQuery.of(context).size.width;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.kaiColors;
    return GetBuilder<LearningController>(builder: (value) {
      bool isQuestionAnswer = value.listAnswerDataCheck
          .containsKey(learningQuizStore.itemQuestion?.id.toString());
      return Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        widget.data.name ?? '',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(fontFamily: 'Manrope', fontWeight: FontWeight.w700, fontSize: 16),
                      ),
                    ),
                    Row(
                      children: [
                        if(widget.dataQuiz.duration != 0)
                        Countdown(
                          duration: (widget.dataQuiz.total_time ?? 0),
                          callBack: () {
                            if (widget.dataQuiz.duration != 0) {
                              value.callBackFinishQuiz();
                            }
                          },
                        ),
                        if(widget.dataQuiz.duration == 0)
                          Uptime(callBack: (){}),
                        SizedBox(
                          width: 4,
                        ),
                        Text(
                          tr(LocaleKeys.learningScreen_quiz_timeRemaining),
                          style: const TextStyle(
                              color: MedsKaiColors.error, fontFamily: 'Manrope', fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if ((widget.dataQuiz.questions?.length ?? 0) > 1)
                Container(
                  width: screenWidth,
                  margin: const EdgeInsets.symmetric(vertical: 10.0),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    // Allow scrolling horizontally to prevent overflow
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Previous button container
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 6),
                          decoration: BoxDecoration(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(4)),
                            color: colors.surface,
                            border: Border.all(
                              color: colors.border,
                            ),
                          ),
                          child: GestureDetector(
                            onTap: () => value.pageActive == 0
                                ? null
                                : value.onPrevQuiz(),
                            child: const Icon(
                              Icons.chevron_left,
                              size: 18,
                            ),
                          ),
                        ),
                        Expanded(
                          child: SizedBox(
                            height: 34,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: widget.dataQuiz.questions?.length ?? 0,
                              itemBuilder: (context, index) => GestureDetector(
                                key: ValueKey(index),
                                onTap: () {
                                  value.onActiveQuiz(
                                      widget.dataQuiz.questions?[index],
                                      index);
                                },
                                child: Container(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 2),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 6),
                                  decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(4)),
                                    color: value.pageActive == index
                                        ? MedsKaiColors.accent
                                        : colors.surface,
                                    border: Border.all(
                                      color: value.pageActive == index
                                          ? MedsKaiColors.accent
                                          : colors.border,
                                    ),
                                  ),
                                  child: Text(
                                    '${index + 1}',
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Next button container
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 6),
                          decoration: BoxDecoration(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(4)),
                            color: colors.surface,
                            border: Border.all(
                              color: colors.border,
                            ),
                          ),
                          child: GestureDetector(
                            onTap: () => value.pageActive ==
                                    (widget.dataQuiz.questions?.length ?? 0)
                                ? null
                                : value.onNextQuiz(),
                            child: const Icon(
                              Icons.chevron_right,
                              size: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              if (learningQuizStore.itemQuestion != null)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: isQuestionAnswer
                          ? handleRenderQuestionAfterClickCheckAnswer(
                              learningQuizStore.itemQuestion,
                              value.listAnswerDataCheck[
                                  learningQuizStore.itemQuestion?.id.toString()])
                          : handleRenderQuestion(value)),
                ),
              if (learningQuizStore.dataQuiz?.instant_check != null &&
                  (learningQuizStore.dataQuiz?.checked_questions ?? [])
                      .contains(learningQuizStore.itemQuestion?.id))
                Container(
                  height: 50,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        tr(LocaleKeys.learningScreen_quiz_questionAnswered),
                        style: const TextStyle(color: MedsKaiColors.success),
                      ),
                      const Icon(Icons.check, color: MedsKaiColors.success),
                    ],
                  ),
                ),
              Container(
                margin: const EdgeInsets.only(top: 12),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                ),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (!isQuestionAnswer) {
                          value.checkAnswer(learningQuizStore.itemQuestion);
                        }
                      },
                      child: Container(
                        width: screenWidth,
                        height: 50,
                        decoration: BoxDecoration(
                          color:
                              !isQuestionAnswer ? Colors.green : colors.surface,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              tr(LocaleKeys.learningScreen_quiz_btnCheck),
                              style: TextStyle(
                                fontFamily: 'Manrope',
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: !isQuestionAnswer
                                    ? Colors.white
                                    : Colors.green,
                              ),
                            ),
                            Icon(
                              Icons.check,
                              size: 20,
                              color: !isQuestionAnswer
                                  ? Colors.white
                                  : Colors.green,
                            )
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: value.showHint,
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: MedsKaiColors.primary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.lightbulb_outline,
                              size: 20,
                              color: MedsKaiColors.white,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => value.onFinish(),
                          child: Container(
                            height: 50,
                            width: screenWidth - 150,
                            decoration: BoxDecoration(
                              color: MedsKaiColors.accent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                tr(LocaleKeys.learningScreen_quiz_btnFinish),
                                style: TextStyle(
                                  fontFamily: 'Manrope',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: colors.textPrimary,
                                ),
                              ),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: value.onNextQuiz,
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: colors.sectionBg,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.chevron_right),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              )
            ],
          ));
    });
  }

  Future<void> _dialogBuilder(BuildContext context, explanation) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            tr(LocaleKeys.learningScreen_quiz_explanation),
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 20,
            ),
            textAlign: TextAlign.center,
          ),
          content: Text(
            explanation,
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          actions: <Widget>[
            TextButton(
              child: Text(tr(LocaleKeys.alert_ok),
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  List<Widget> handleRenderQuestionAfterClickCheckAnswer(question, answer) {
    List<Widget> listWidget = [];

    if (question != null)
      listWidget.add(Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(children: [
            HtmlWidget(
              question!.title.toString(),
              textStyle: TextStyle(fontFamily: 'Manrope', fontWeight: FontWeight.w600),
            ),
          ])));
    if (question?.content != null)
      listWidget.add(Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        child: HtmlWidget(question!.content.toString()),
      ));
    if (question?.type == 'single_choice' || question?.type == 'true_or_false')
      listWidget.add(Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        child: Wrap(
            direction: Axis.vertical,
            children: List.generate(
                question?.options?.length ?? 0,
                (index) =>
                    itemOption(question?.options?[index], answer, index))),
      ));
    if (question?.type == 'multi_choice')
      listWidget.add(Wrap(
          direction: Axis.vertical,
          children: List.generate(
              question?.options?.length ?? 0,
              (index) => itemOptionMultiChoice(
                  question?.options?[index], answer, index))));
    if (question?.type == 'sorting_choice')
      listWidget.add(Container(
        child: Column(
          children: [...handleSortingChoice(answer)],
        ),
      ));
    if (question?.type == 'fill_in_blanks')
      listWidget.add(renderFillInBlanksAnswer(answer));

    listWidget.add(Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: answer.result.correct
                  ? MedsKaiColors.info
                  : MedsKaiColors.error,
              padding: const EdgeInsets.symmetric(
                  vertical: 12, horizontal: 12), // foreground color
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {},
            child: Text(
              answer.result.correct
                  ? tr(LocaleKeys.reviewQuiz_status_success)
                  : tr(LocaleKeys.reviewQuiz_status_failed),
              style: TextStyle(fontFamily: 'Manrope', fontWeight: FontWeight.w600),
            ),
          ),
          SizedBox(
            width: 20,
          ),
          Expanded(
              child: Text(
            tr(LocaleKeys.learningScreen_quiz_pointResult,
                args: [answer.result.mark.toString()]),
            style: TextStyle(fontFamily: 'Manrope', fontWeight: FontWeight.w600),
          )),
          SizedBox(
            width: 20,
          ),
          if (answer.explanation != "" && answer.explanation != null)
            ElevatedButton(
                onPressed: () => _dialogBuilder(context, answer.explanation),
                child: Row(children: [
                  Icon(Icons.north_east),
                  Text(tr(LocaleKeys.learningScreen_quiz_explanation))
                ]))
        ],
      ),
    ));
    return listWidget;
  }

  Widget itemOption(item, userAnswer, index) {
    return GestureDetector(
      onTap: () {
        // Handle tap event
      },
      child: Container(
        margin: const EdgeInsets.only(top: 20.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            (userAnswer.result.correct != null &&
                    userAnswer.result.answered.contains(item.value) &&
                    userAnswer.options[index]?.is_true == 'yes')
                ? Icon(
                    Icons.check_circle_outline,
                    size: 14,
                    color: item.is_true == "yes" ? Colors.green : Colors.red,
                  )
                : userAnswer.result.answered.contains(item.value)
                    ? const Icon(
                        Icons.cancel_outlined,
                        size: 14,
                        color: MedsKaiColors.error,
                      )
                    : Icon(
                        Icons.radio_button_unchecked,
                        size: 14,
                        color: context.kaiColors.textSecondary,
                      ),
            const SizedBox(width: 9),
            Text(
              item.title,
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 13,
                height: 1.46,
                color: context.kaiColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> handleRenderQuestion(value) {
    final colors = context.kaiColors;
    List<Widget> listQuestion = [];
    // Pre-compute selected answer values as Set for O(1) lookups
    final selectedAnswerValues = <dynamic>{};
    if (learningQuizStore.itemQuestion?.answer != null) {
      for (final a in learningQuizStore.itemQuestion!.answer) {
        selectedAnswerValues.add(a.value);
      }
    }

    listQuestion.add(HtmlWidget(
      learningQuizStore.itemQuestion?.title?.toString() ?? '',
      textStyle: TextStyle(fontFamily: 'Manrope', fontWeight: FontWeight.w600),
    ));
    listQuestion.add(SizedBox(
      height: 10,
    ));
    if (learningQuizStore.itemQuestion?.content != null)
      listQuestion
          .add(HtmlWidget(learningQuizStore.itemQuestion!.content.toString()));
    if (learningQuizStore.itemQuestion?.type == 'single_choice')
      listQuestion.add(Wrap(
        direction: Axis.vertical,
        children: List.generate(
            learningQuizStore.itemQuestion?.options?.length ?? 0,
            (index) => GestureDetector(
                  onTap: () {
                    value.isDisable()
                        ? null
                        : value.selectQuestion(
                            learningQuizStore.itemQuestion?.options?[index]);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Row(
                      children: [
                        Icon(
                          selectedAnswerValues.contains(
                                  learningQuizStore.itemQuestion?.options?[index].value)
                              ? Icons.radio_button_checked
                              : Icons.radio_button_unchecked,
                          size: 14,
                          color: colors.textSecondary,
                        ),
                        const SizedBox(width: 5),
                        SizedBox(
                          width: screenWidth - 50,
                          child: Text(
                            learningQuizStore
                                .itemQuestion?.options?[index].title ?? '',
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
      ));
    if (learningQuizStore.itemQuestion?.type == 'true_or_false')
      listQuestion.add(Wrap(
        direction: Axis.vertical,
        children: List.generate(
            learningQuizStore.itemQuestion?.options?.length ?? 0,
            (index) => GestureDetector(
                  onTap: () {
                    value.isDisable()
                        ? null
                        : value.selectQuestion(
                            learningQuizStore.itemQuestion?.options?[index]);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Row(
                      children: [
                        Icon(
                          selectedAnswerValues.contains(
                                  learningQuizStore.itemQuestion?.options?[index].value)
                              ? Icons.radio_button_checked
                              : Icons.radio_button_unchecked,
                          size: 14,
                          color: colors.textSecondary,
                        ),
                        const SizedBox(width: 5),
                        SizedBox(
                          width: screenWidth - 50,
                          child: Text(
                            learningQuizStore
                                .itemQuestion?.options?[index].title ?? '',
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
      ));
    if (learningQuizStore.itemQuestion?.type == 'multi_choice')
      listQuestion.add(Wrap(
        direction: Axis.vertical,
        children: List.generate(
            learningQuizStore.itemQuestion?.options?.length ?? 0,
            (index) => GestureDetector(
                  onTap: () {
                    value.isDisable()
                        ? null
                        : value.selectQuestion(
                            learningQuizStore.itemQuestion?.options?[index]);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Row(
                      children: [
                        Icon(
                          selectedAnswerValues.contains(
                                  learningQuizStore.itemQuestion?.options?[index].value)
                              ? Icons.check_box
                              : Icons.check_box_outline_blank,
                          size: 14,
                          color: colors.textSecondary,
                        ),
                        const SizedBox(width: 5),
                        SizedBox(
                          width: screenWidth - 50,
                          child: Text(
                            learningQuizStore
                                .itemQuestion?.options?[index].title ?? '',
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
      ));
    if (learningQuizStore.itemQuestion?.type == 'sorting_choice') {
      listQuestion.add(ReorderableListView(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        // padding: const EdgeInsets.symmetric(horizontal: 40),
        children: <Widget>[
          for (int index = 0;
              index < (learningQuizStore.itemQuestion?.options?.length ?? 0);
              index += 1)
            Card(
              key: Key('$index'),
              shape:
                  ShapeBorder.lerp(Border.symmetric(), Border.symmetric(), 5),
              child: ListTile(
                title:
                    Text(learningQuizStore.itemQuestion?.options?[index].title ?? ''),
                leading: Icon(
                  Icons.reorder_outlined,
                  color: context.kaiColors.textPrimary,
                ),
              ),
            )
        ],
        onReorder: (int oldIndex, int newIndex) {
          if (value.isDisable()) return;
          setState(() {
            if (oldIndex < newIndex) {
              newIndex -= 1;
            }
            var item =
                learningQuizStore.itemQuestion?.options?.removeAt(oldIndex);
            if (item != null) {
              learningQuizStore.itemQuestion?.options?.insert(newIndex, item);
            }

            //handle list sort answer
            List<String> list = (learningQuizStore.itemQuestion?.options ?? [])
                .map((e) => e.value.toString())
                .toList();
            value.onHandleSortingChoice(list.toString());
          });
        },
      ));
    }
    if (learningQuizStore.itemQuestion?.type == 'fill_in_blanks')
      listQuestion.add(renderFillInBlanks(value));
    listQuestion.add(SizedBox(
      height: 36,
    ));
    return listQuestion;
  }

  Widget renderFillInBlanks(valueController) {
    final itemQuestion = learningQuizStore.itemQuestion;
    var lstIdKeys = <Map<String, dynamic>>[];
    final options = (itemQuestion?.options?.isNotEmpty ?? false) ? itemQuestion!.options![0] : null;
    final ids = options?.ids;
    var titleApi = options?.title_api;

    ids?.forEach((id) {
      lstIdKeys.add({'id': id, 'key': '{{FIB_$id}}'});
    });

    if (titleApi == null) return Wrap(children: []);
    final words = titleApi.split(' ');

    List<Widget> list = [];
    int index = 0;
    for (var e in words) {
      var word = words[index];
      var itemKey = lstIdKeys.firstWhereOrNull((item) => item['key'] == word);
      if (itemKey != null) {
        final itemId = itemKey['id'];
        list.add(SizedBox(
          width: 100,
          child: TextField(
            controller: valueController.handleRenderFieldControl(itemId),
            key: Key(index.toString()),
            // enabled: !this.itemCheck.any((x) => x['id'] == itemQuestion['id']),
            style: TextStyle(color: context.kaiColors.textPrimary),
            decoration: const InputDecoration(
              //contentPadding: EdgeInsets.zero,
              isDense: true,
              border: UnderlineInputBorder(borderSide: BorderSide(width: 1)),
            ),
            onChanged: (value) =>
                valueController.onChangeFillBlank(itemId, value),
          ),
        ));
      } else {
        list.add(Text(e));
      }

      index++;
    }

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 1.5,
      runSpacing: 3,
      children: list,
    );
  }

  Widget renderFillInBlanksAnswer(question) {
    final itemQuestion = question;
    var lstIdKeys = <Map<String, dynamic>>[];
    final options = (itemQuestion?.options?.isNotEmpty ?? false) ? itemQuestion!.options![0] : null;
    final ids = options?.ids;
    final titleApi = options?.title_api;

    ids?.forEach((id) {
      lstIdKeys.add({'id': id, 'key': '{{FIB_$id}}'});
    });

    if (titleApi == null) return Container();
    final words = titleApi.split(' ');

    List<Widget> list = [];
    int index = 0;

    for (var e in words) {
      var word = words[index];
      var itemKey = lstIdKeys.firstWhereOrNull((x) => x['key'] == word);

      if (itemKey != null) {
        final itemId = itemKey['id'];
        list.add(SizedBox(
            width: calculateWidth(options?.answers[itemId]['answer']) +
                calculateWidth(options?.answers[itemId]['correct']) +
                50,
            child: Container(
              color: context.kaiColors.sectionBg,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 10,
                  ),
                  Text(options?.answers[itemId]['answer'],
                      overflow: TextOverflow.ellipsis,
                      style:
                          TextStyle(color: context.kaiColors.textPrimary, fontFamily: 'Manrope')),
                  Icon(Icons.arrow_forward),
                  Text(
                    options?.answers[itemId]['correct'],
                    style: TextStyle(color: MedsKaiColors.success, fontFamily: 'Manrope'),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            )));
      } else {
        list.add(Text(e));
      }

      index++;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 1.5,
        runSpacing: 3,
        children: list,
      ),
    );
  }

  Widget itemOptionMultiChoice(item, userAnswer, index) {
    return GestureDetector(
      onTap: () {
        // Handle tap event
      },
      child: Container(
        width: screenWidth,
        margin: const EdgeInsets.only(top: 20.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            (userAnswer.result.correct &&
                    userAnswer.result.answered != null &&
                    userAnswer.result.answered.contains(item.value))
                ? const Icon(
                    Icons.check_circle_outline,
                    size: 14,
                    color: MedsKaiColors.success,
                  )
                : userAnswer.options[index]?.is_true == 'yes'
                    ? Icon(
                        Icons.check_circle_outline,
                        size: 14,
                        color: userAnswer.result.answered.contains(item.value)
                            ? Colors.green
                            : Colors.red,
                      )
                    : Icon(
                        Icons.radio_button_unchecked,
                        size: 14,
                        color: userAnswer.result.answered.contains(item.value)
                            ? Colors.red
                            : Colors.grey,
                      ),
            const SizedBox(width: 9),
            SizedBox(
              width: screenWidth - 32,
              child: Text(
                item.title,
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 13,
                  color: context.kaiColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> handleSortingChoice(dataSortingChoice) {
    List<Widget> list = [];
    String cleanedString = dataSortingChoice.result.answered
        .replaceAll("[", "")
        .replaceAll("]", "")
        .replaceAll(" ", "");
    List<String> answered = cleanedString.split(",");
    List<dynamic> options = [];
    if (dataSortingChoice.options != null) {
      dataSortingChoice.options.forEach((item) {
        options.add(item);
      });
    }
    for (int index = 0; index < answered.length; index += 1) {
      var itemAnswered = options
          .firstWhereOrNull((element) => element.value == answered[index]);
      if (itemAnswered != null) {
        list.add(Card(
          key: Key('$index'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5.0),
            side: BorderSide(color: context.kaiColors.sectionBg, width: 1.0),
          ),
          child: ListTile(
            title: Text(itemAnswered.title!),
            leading: Icon(
              Icons.reorder_outlined,
              color: context.kaiColors.textPrimary,
            ),
          ),
        ));
      }

      var itemCorrect =
          options.firstWhereOrNull((element) => element.sorting == index);
      if (itemCorrect != null) {
        list.add(Card(
          key: Key('12$index'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5.0),
            side: BorderSide(color: MedsKaiColors.success, width: 1.0),
          ),
          child: ListTile(
            title: Text(itemCorrect.title!),
          ),
        ));
      }
    }
    return list;
  }

  double calculateWidth(String text) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(
          text: text,
          style: TextStyle(color: context.kaiColors.textPrimary, fontFamily: 'Manrope')),
      textDirection: TextDirection.ltr,
    )..layout();

    return textPainter.width;
  }

  @override
  void initState() {
    final LearningController learningController =
        Get.find<LearningController>();
    learningController.handleOnInitAnswered();
    super.initState();
  }
}

class LearningStartQuiz extends StatefulWidget {
  const LearningStartQuiz(
      {super.key,
      required this.data,
      required this.dataQuiz,
      this.itemQuestion});

  final LearningLessonModel data;
  final QuizModel dataQuiz;
  final QuestionModel? itemQuestion;

  @override
  State<LearningStartQuiz> createState() => _LearningStartQuiz();
}
