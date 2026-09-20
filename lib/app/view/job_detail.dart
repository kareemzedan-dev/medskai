import 'package:flutter/material.dart';
import 'package:flutter_app/app/util/theme.dart';
import 'package:get/get.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import '../backend/models/job_model.dart';
import 'package:url_launcher/url_launcher.dart';

class JobDetailScreen extends StatelessWidget {
  const JobDetailScreen({Key? key}) : super(key: key);

  void _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.kaiColors;
    final JobModel job = Get.arguments;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Details'),
        backgroundColor: colors.background,
        foregroundColor: colors.textPrimary,
      ),
      backgroundColor: colors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              job.title ?? 'No title',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(Icons.business, job.companyName ?? 'Unknown Company', colors),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.location_on, job.location ?? 'Remote', colors),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.access_time, job.formattedDate, colors),
            if (job.jobType != null && job.jobType!.isNotEmpty) ...[
              const SizedBox(height: 8),
              _buildInfoRow(Icons.work, job.jobType!, colors),
            ],
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            Text(
              'Job Description',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            HtmlWidget(
              job.content ?? 'No description provided.',
              textStyle: TextStyle(color: colors.textPrimary, fontSize: 15, height: 1.5),
              onTapUrl: (url) {
                _launchUrl(url);
                return true;
              },
            ),
            const SizedBox(height: 40),
            if (job.link != null && job.link!.isNotEmpty)
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => _launchUrl(job.link!),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MedsKaiColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text(
                    'Apply Now',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, MedsKaiThemeColors colors) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: colors.textSecondary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(color: colors.textSecondary, fontSize: 15),
          ),
        ),
      ],
    );
  }
}
