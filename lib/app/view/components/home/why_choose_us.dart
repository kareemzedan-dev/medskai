import 'package:flutter/material.dart';

class WhyChooseUsSection extends StatelessWidget {
  const WhyChooseUsSection({Key? key}) : super(key: key);

  static const List<Map<String, dynamic>> _valueProps = [
    {'icon': Icons.science, 'title': 'Research-Backed Content', 'desc': 'Courses developed from peer-reviewed medical research'},
    {'icon': Icons.analytics, 'title': 'Progress Analytics', 'desc': 'Track your learning journey with detailed insights'},
    {'icon': Icons.supervisor_account, 'title': 'Expert Mentorship', 'desc': 'Learn directly from industry-leading professionals'},
    {'icon': Icons.verified, 'title': 'Admissions Readiness', 'desc': 'Prepare for university applications and exams'},
    {'icon': Icons.build, 'title': 'Project-Based Learning', 'desc': 'Apply knowledge through hands-on practical projects'},
    {'icon': Icons.support_agent, 'title': 'Flexible Support', 'desc': 'Get help whenever you need it on your schedule'},
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Why Choose Us',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.4,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: _valueProps.length,
          itemBuilder: (context, index) {
            final prop = _valueProps[index];
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(prop['icon'] as IconData, size: 28, color: Theme.of(context).primaryColor),
                    const SizedBox(height: 8),
                    Text(
                      prop['title'] as String,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Expanded(
                      child: Text(
                        prop['desc'] as String,
                        style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
