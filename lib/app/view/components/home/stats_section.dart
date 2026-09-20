import 'package:flutter/material.dart';
import '../../../backend/models/testimonial_model.dart';

class StatsSection extends StatefulWidget {
  final PlatformStatsModel stats;

  const StatsSection({Key? key, required this.stats}) : super(key: key);

  @override
  State<StatsSection> createState() => _StatsSectionState();
}

class _StatsSectionState extends State<StatsSection> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      color: Theme.of(context).primaryColor.withOpacity(0.05),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('${widget.stats.studentsEnrolled}+', 'Students\nEnrolled', Icons.people),
          _buildStatItem('${widget.stats.classesCompleted}+', 'Classes\nCompleted', Icons.school),
          _buildStatItem('${widget.stats.satisfactionRate}%', 'Satisfaction\nRate', Icons.thumb_up),
          _buildStatItem('${widget.stats.topInstructors}+', 'Top\nInstructors', Icons.person),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label, IconData icon) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _controller.value,
          child: Column(
            children: [
              Icon(icon, size: 28, color: Theme.of(context).primaryColor),
              const SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11, color: Colors.grey[600]),
              ),
            ],
          ),
        );
      },
    );
  }
}
