import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/events_controller.dart';
import '../helper/router.dart';
import '../backend/models/event_model.dart';
import '../../l10n/locale_keys.g.dart';
import 'components/events/event_card.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({Key? key}) : super(key: key);

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      Get.find<EventsController>().loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<EventsController>(
      builder: (controller) {
        if (controller.hasError && controller.eventsList.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: Text(tr(LocaleKeys.events_title))),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.cloud_off_rounded, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(controller.errorMessage, textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => controller.loadEvents(forceRefresh: true),
                    child: Text(tr(LocaleKeys.common_retry)),
                  ),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(title: Text(tr(LocaleKeys.events_title))),
          body: controller.isLoading
              ? const Center(child: CircularProgressIndicator())
              : controller.eventsList.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.event_busy, size: 64, color: Colors.grey),
                          const SizedBox(height: 16),
                          Text(tr(LocaleKeys.events_noEvents)),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () => controller.refresh(),
                      child: ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: controller.eventsList.length +
                            (controller.isLoadingMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == controller.eventsList.length) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }
                          return EventCard(
                            key: ValueKey(controller.eventsList[index].id ?? index),
                            event: controller.eventsList[index],
                            onTap: () {
                              Get.toNamed(
                                AppRouter.eventDetail,
                                arguments: controller.eventsList[index],
                              );
                            },
                          );
                        },
                      ),
                    ),
        );
      },
    );
  }
}
