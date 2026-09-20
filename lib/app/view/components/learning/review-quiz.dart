import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_app/app/backend/mobx-store/course_store.dart';
import 'package:flutter_app/app/backend/mobx-store/init_store.dart';
import 'package:flutter_app/app/backend/models/learning-lesson-model.dart';
import 'package:flutter_app/app/util/theme.dart';
import 'package:flutter_app/l10n/locale_keys.g.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:get/get.dart';

import 'package:get_it_mixin/get_it_mixin.dart';

typedef OnNavigateCallback = void Function();

class ReviewQuiz extends StatefulWidget with GetItStatefulWidgetMixin {
  final LearningLessonModel data;
  final OnNavigateCallback onClose;

  ReviewQuiz({super.key, required this.data, required this.onClose});

  @override
  _ReviewQuizState createState() => _ReviewQuizState();

}

class _ReviewQuizState extends State<ReviewQuiz> {
  static ReviewQuiz createWithData(
      LearningLessonModel data, OnNavigateCallback onClose) {
    return ReviewQuiz(data: data, onClose: onClose);
  }

  final courseStore = locator<CourseStore>();
  double get screenWidth => MediaQuery.of(context).size.width;
  int pageActive = 0;
  QuestionModel? question;

  @override
  void initState() {
    super.initState();
    setState(() {
      question = (widget.data.questions != null && widget.data.questions!.isNotEmpty)
          ? widget.data.questions![0]
          : null;
      pageActive = 0;
    });
  }

  Future<void> _dialogBuilder(BuildContext context) {
    String content = widget.data.results?.answered[question?.id.toString()]?['explanation']?.toString() ?? '';
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            tr(LocaleKeys.learningScreen_quiz_explanation),
            style: const TextStyle(fontFamily: 'Manrope', fontWeight: FontWeight.w700, fontSize: 20),
          ),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              child: Text(tr(LocaleKeys.alert_ok)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> onActiveQuiz(item, index) async {
    setState(() {
      question = item;
      pageActive = index;
    });
  }

  Future<void> onPrevQuiz() async {
    if (pageActive - 1 < 0) return;
    final questions = widget.data.questions;
    if (questions == null || pageActive - 1 >= questions.length) return;
    setState(() {
      question = questions[pageActive - 1];
      pageActive = pageActive - 1;
    });
  }

  Future<void> onNextQuiz() async {
    final questions = widget.data.questions;
    if (questions == null || pageActive + 1 >= questions.length) return;
    setState(() {
      question = questions[pageActive + 1];
      pageActive = pageActive + 1;
    });
  }

  Widget renderFillInBlanks() {
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
        list.add(
            SizedBox(
              width: calculateWidth(options?.answers[itemId]['answer']) +
                  calculateWidth(options?.answers[itemId]['correct']) +
                  70,
              child: Container(
                color: context.kaiColors.sectionBg,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 10,
                    ),
                    Flexible(
                      child: Text(options?.answers[itemId]['answer'],
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: context.kaiColors.textPrimary,
                              fontFamily: 'Manrope',
                              fontWeight: FontWeight.w600)),
                    ),
                    const Icon(Icons.arrow_forward, size: 20),
                    Flexible(
                      child: Text(
                        options?.answers[itemId]['correct'],
                        style: const TextStyle(
                            color: MedsKaiColors.success,
                            fontFamily: 'Manrope',
                            fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            )
        );
      }else{
        list.add(Text(e));
      }

      index++;
    }


    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8,vertical: 4),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 1.5,
        runSpacing: 3,
        children: list,
      ),
    );
  }

  Widget itemOption(item) {

    dynamic userAnswer =
        widget.data.results?.answered?[question?.id.toString()];
    if (userAnswer == null) {
      return GestureDetector(
        onTap: () {},
        child: Container(
          margin: const EdgeInsets.only(top: 20.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Icons.radio_button_unchecked, size: 14, color: context.kaiColors.textSecondary),
              const SizedBox(width: 9),
              Text(item.title, style: TextStyle(fontFamily: 'Manrope', fontSize: 13, height: 1.46, color: context.kaiColors.textSecondary)),
            ],
          ),
        ),
      );
    }
    return GestureDetector(
      onTap: () {
        // Handle tap event
      },
      child: Container(
        margin: const EdgeInsets.only(top: 20.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            (userAnswer["correct"] != null &&
                        userAnswer["answered"].contains(item.value)) ||
                    item?.is_true == 'yes'
                ?  Icon(
                    Icons.check_circle_outline,
                    size: 14,
                    color: item.is_true == "yes" ?
                    MedsKaiColors.success:
                    MedsKaiColors.error,
                  )
                : userAnswer["answered"].contains(item.value)
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

  Widget itemOptionMultiChoice(item) {
    dynamic userAnswer =
        widget.data.results?.answered?[question?.id.toString()];
    if (userAnswer == null) {
      return GestureDetector(
        onTap: () {},
        child: Container(
          width: screenWidth,
          margin: const EdgeInsets.only(top: 20.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(Icons.radio_button_unchecked, size: 14, color: Colors.grey),
              const SizedBox(width: 9),
              SizedBox(width: screenWidth - 32, child: Text(item.title, style: TextStyle(fontFamily: 'Manrope', fontSize: 13, color: context.kaiColors.textSecondary))),
            ],
          ),
        ),
      );
    }
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
            (userAnswer['correct'] &&
                    userAnswer['answered'] != null &&
                    userAnswer['answered'].contains(item.value))
                ? const Icon(
                    Icons.check_circle_outline,
                    size: 14,
                    color: MedsKaiColors.success,
                  )
                : item?.is_true == 'yes'
                    ? Icon(
                        Icons.check_circle_outline,
                        size: 14,
                        color: userAnswer['answered'].contains(item.value)
                            ? MedsKaiColors.success
                            : MedsKaiColors.error,
                      )
                    : Icon(
                        Icons.radio_button_unchecked,
                        size: 14,
                        color: userAnswer['answered'].contains(item.value)
                            ? MedsKaiColors.error
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

  @override
  Widget build(BuildContext context) {
    final colors = context.kaiColors;
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IconButton(
            onPressed: () => {widget.onClose()}, icon: const Icon(Icons.close)),
        Expanded(
            child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 100),
                scrollDirection: Axis.vertical,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          widget.data.name ?? '',
                          style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                              fontFamily: 'Manrope'),
                        ),
                      ),
                      if ((widget.data.questions?.length ?? 0) > 1)
                        Container(
                          width: screenWidth,
                          margin: const EdgeInsets.symmetric(vertical: 10.0),
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                // width: 10,
                                // height: 20,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 4, vertical: 6),
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(4)),
                                  color: colors.surface,
                                  border: Border.all(
                                    color: colors.border,
                                  ),
                                ),
                                child: GestureDetector(
                                  onTap: () =>
                                      pageActive == 0 ? null : onPrevQuiz(),
                                  child: const Icon(
                                    Icons.chevron_left,
                                    size: 18,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: screenWidth - 100,
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        child: SizedBox(
                                          height: 34,
                                          child: ListView.builder(
                                            scrollDirection: Axis.horizontal,
                                            itemCount: widget.data.questions?.length ?? 0,
                                            itemBuilder: (context, index) => GestureDetector(
                                              key: ValueKey(index),
                                              onTap: () {
                                                onActiveQuiz(
                                                    widget.data.questions?[index],
                                                    index);
                                              },
                                              child: Container(
                                                margin: const EdgeInsets.symmetric(horizontal: 2),
                                                padding: const EdgeInsets.symmetric(
                                                    horizontal: 8, vertical: 6),
                                                decoration: BoxDecoration(
                                                  borderRadius: const BorderRadius.all(
                                                      Radius.circular(4)),
                                                  color: pageActive == index
                                                      ? MedsKaiColors.accent
                                                      : colors.surface,
                                                  border: Border.all(
                                                    color: pageActive == index
                                                        ? const Color(0xFFFBC815)
                                                        : colors.border,
                                                  ),
                                                ),
                                                child: Text('${index + 1}'),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Container(
                                // width: 30,
                                // height: 35,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 4, vertical: 6),
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(4)),
                                  color: colors.surface,
                                  border: Border.all(
                                    color: colors.border,
                                  ),
                                ),
                                child: GestureDetector(
                                  onTap: () => pageActive ==
                                          (widget.data.questions?.length ?? 0) - 1
                                      ? null
                                      : onNextQuiz(),
                                  child: const Icon(
                                    Icons.chevron_right,
                                    size: 18,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (question != null)
                        Container(
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            child: Column(children: [
                              HtmlWidget(
                                question!.title.toString(),
                                textStyle: TextStyle(fontFamily: 'Manrope', fontWeight: FontWeight.w600),
                              ),
                            ])),
                      if (question?.content != null)
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          child: HtmlWidget(question!.content.toString()),
                        ),
                      if (question?.type == 'single_choice' ||
                          question?.type == 'true_or_false')
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          child: Wrap(
                              direction: Axis.vertical,
                              children: List.generate(
                                  question?.options?.length ?? 0,
                                  (index) =>
                                      itemOption(question?.options?[index]))),
                        ),
                      if (question?.type == 'multi_choice')
                        Wrap(
                            direction: Axis.vertical,
                            children: List.generate(
                                question?.options?.length ?? 0,
                                (index) => itemOptionMultiChoice(
                                    question?.options?[index]))),
                      if (question?.type == 'sorting_choice')
                        Container(
                          child: Column(
                           children: [
                             ...handleSortingChoice()
                           ],
                          ),
                        ),
                      if (question?.type == 'fill_in_blanks')
                        renderFillInBlanks(),
                      Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 32),
                        child: Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: (widget.data.results?.answered?[question?.id.toString()] is Map && widget.data.results?.answered?[question?.id.toString()]['correct'] == true)
                                    ?MedsKaiColors.info
                                    :MedsKaiColors.error,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: () {},
                              child: Text(
                                (widget.data.results?.answered?[question?.id.toString()] is Map && widget.data.results?.answered?[question?.id.toString()]['correct'] == true)
                                    ? tr( LocaleKeys.reviewQuiz_status_success)
                                    : tr(LocaleKeys.reviewQuiz_status_failed),
                                style: TextStyle(fontFamily: 'Manrope', fontWeight: FontWeight.w600),
                              ),
                            ),
                            Text(
                              (widget.data.results?.answered[question?.id.toString()]?['mark']?.toString() ?? '0')+'/1 point',
                              style: TextStyle(fontFamily: 'Manrope', fontWeight: FontWeight.w600),
                            ),
                            ElevatedButton(
                                onPressed: () => _dialogBuilder(context),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.north_east, size: 18),
                                    SizedBox(width: 4),
                                    Text(tr(LocaleKeys.learningScreen_quiz_explanation))
                                  ],
                                ))
                          ],
                        ),
                      )
                    ],
                  ),
                ))),
      ],
    );
  }

  List<Widget> handleSortingChoice(){
    List<Widget> list = [];
    var dataSortingChoice = widget.data.results?.answered?[question?.id.toString()];
    if (dataSortingChoice == null || dataSortingChoice is! Map) return list;

    List<dynamic> options = [];
    List<dynamic> answered = [];
    if(dataSortingChoice['answered'] is String){
      String cleanedString = dataSortingChoice['answered'].replaceAll("[", "").replaceAll("]", "").replaceAll(" ", "");
      answered = cleanedString.split(",");
    }
    if(dataSortingChoice['answered'] is List){
      answered = dataSortingChoice['answered'];
    }

    if(dataSortingChoice['options'] != null){
      dataSortingChoice['options'].forEach((item){
        options.add(item);
      });
    }

    for (int index = 0; index < answered.length; index += 1)
    {
      var itemAnswered = options.firstWhereOrNull((element) => element['value'] == answered[index]);
      if(itemAnswered != null) list.add(Card(
        key: Key('$index'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5.0),
          side: BorderSide(color: context.kaiColors.sectionBg, width: 1.0),
        ),
        child: ListTile(
          title: Text(itemAnswered['title']!),
          leading: Icon(
            Icons.reorder_outlined,
            color: context.kaiColors.textPrimary,
          ),
        ),
      ));

      var itemCorrect = options.firstWhereOrNull((element) => element['sorting'] == index);
      if(itemCorrect != null) list.add(
          Card(
            key: Key('12$index'),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0),
                side: BorderSide(color: MedsKaiColors.success, width: 1.0),
              ),
            child: ListTile(
                    title: Text(itemCorrect['title']!),
                  ),
          )
      );

    }
    return list;
  }

  double calculateWidth(String text) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(
          text: text,
          style: TextStyle(color: context.kaiColors.textPrimary, fontFamily: 'Manrope', fontWeight: FontWeight.w600)
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    return textPainter.width;
  }
}
