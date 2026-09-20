import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/app/util/theme.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:url_launcher/url_launcher.dart';
import '../backend/models/event_model.dart';
import '../../l10n/locale_keys.g.dart';
import 'package:get/get.dart';

class EventDetailScreen extends StatelessWidget {
  const EventDetailScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colors = context.kaiColors;
    final args = Get.arguments;
    if (args is! EventModel) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(tr(LocaleKeys.ui_eventNotFound))),
      );
    }
    final EventModel event = args;

    return Scaffold(
      appBar: AppBar(title: Text(event.title ?? '')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (event.image != null)
              CachedNetworkImage(
                imageUrl: event.image!,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(
                  height: 200,
                  color: colors.sectionBg,
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (_, __, ___) => Container(
                  height: 200,
                  color: colors.sectionBg,
                  child: const Icon(Icons.event, size: 64, color: Colors.grey),
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title ?? '',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  // Date & Time
                  _buildInfoRow(Icons.calendar_today, event.formattedDate, colors),
                  if (!event.allDay)
                    _buildInfoRow(Icons.access_time, event.formattedTimeRange, colors)
                  else
                    _buildInfoRow(Icons.access_time, tr(LocaleKeys.events_allDay), colors),

                  // Location
                  if (event.venue != null)
                    _buildInfoRow(Icons.location_on, event.venue!.fullAddress, colors),

                  // Cost
                  if (event.cost != null && event.cost!.isNotEmpty)
                    _buildInfoRow(Icons.attach_money, event.cost!, colors),

                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),

                  // Description
                  if (event.description != null)
                    HtmlWidget(event.description!),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, MedsKaiThemeColors colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: colors.textSecondary),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: TextStyle(fontSize: 15, color: colors.textPrimary))),
        ],
      ),
    );
  }
}
