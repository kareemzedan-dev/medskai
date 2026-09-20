import 'package:flutter/material.dart';
import 'package:flutter_app/app/util/theme.dart';
import 'package:get/get.dart';
import 'package:indexed/indexed.dart';

class TeamMember {
  final String name;
  final String title;
  final String image;

  const TeamMember({
    required this.name,
    required this.title,
    required this.image,
  });
}
class TeamScreen extends StatelessWidget {
  const TeamScreen({super.key});

  static const List<TeamMember> team = [
    TeamMember(
      name: "Mohamed Hammam",
      title: "CEO Of MedSkAi Academy",
      image: "assets/images/team/9.webp",
    ),
    TeamMember(
      name: "Mostafa Alaa",
      title: "CTO Of MedSkAi Academy",
      image: "assets/images/team/Untitled-design-3.webp",
    ),
    TeamMember(
      name: "Mostafa Shebl",
      title: "CAO Of MedSkAi Academy",
      image: "assets/images/team/Untitled-design.webp",
    ),
    TeamMember(
      name: "Mohamed Toema",
      title: "CMO Of MedSkAi Academy",
      image: "assets/images/team/Untitled-design-1-1.webp",
    ),
    TeamMember(
      name: "Dr. Ahmed Emara",
      title: "Academic Reviewer",
      image: "assets/images/team/Untitled-design-2.webp",
    ),
    TeamMember(
      name: "Dr. Galal Khedr",
      title: "Head Of Production",
      image: "assets/images/team/Untitled-design-4-2.webp",
    ),
    TeamMember(
      name: "Dr. Nagla Usama",
      title: "PhD In Applied Biochemistry",
      image: "assets/images/team/7.webp",
    ),
    TeamMember(
      name: "Ramzy Elmezayen",
      title: "Academic Team Member",
      image: "assets/images/team/8.webp",
    ),
    TeamMember(
      name: "Mohamed Omar",
      title: "Academic Team Member",
      image: "assets/images/team/13.webp",
    ),
    TeamMember(
      name: "Mostafa Emad",
      title: "Technical Team Member",

      image: "assets/images/team/10.webp",
    ),
    TeamMember(
      name: "Abdelrahman Mosad",
      title: "Technical Team Member",
      image: "assets/images/team/Untitled-design-5.webp",
    ),
  ];
  @override
  Widget build(BuildContext context) {
    final colors = context.kaiColors;
    final top = MediaQuery.of(context).viewPadding.top;

    return Scaffold(
      backgroundColor: colors.background,
      body: Stack(
        children: [
          // Background gradient
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 240,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    MedsKaiColors.primary.withOpacity(0.12),
                    colors.background,
                  ],
                ),
              ),
            ),
          ),

          // Content
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Top bar
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Get.back(),
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: colors.surface,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.06),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 18,
                            color: colors.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Our Team',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: colors.textPrimary,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Hero
                  _buildHero(colors),

                  const SizedBox(height: 28),

                  // Grid
                  _buildGrid(colors),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildHero(MedsKaiThemeColors colors) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                MedsKaiColors.primary,
                MedsKaiColors.purpleAccent,
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: MedsKaiColors.primary.withOpacity(0.25),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            Icons.groups_rounded,
            size: 28,
            color: Colors.white,
          ),
        ),

        const SizedBox(height: 14),

        Text(
          'Meet Our Team',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: colors.textPrimary,
          ),
        ),

        const SizedBox(height: 6),

        Text(
          'The people behind MedsKai Academy',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            color: colors.textSecondary,
            height: 1.4,
          ),
        ),

        const SizedBox(height: 12),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: MedsKaiColors.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.person_rounded,
                size: 14,
                color: MedsKaiColors.primary,
              ),
              const SizedBox(width: 6),
              Text(
                '${team.length} Members',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: MedsKaiColors.primary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  Widget _buildGrid(MedsKaiThemeColors colors) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: team.length,
      padding: const EdgeInsets.only(top: 24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 0.78,
      ),
      itemBuilder: (context, index) {
        final member = team[index];
        return _buildCard(member);
      },
    );
  }
  Widget _buildCard(TeamMember member) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 82,
            height: 82,
            padding: const EdgeInsets.all(2.5),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  Color(0xFF6C5CE7),
                  Color(0xFFA66EFE),
                ],
              ),
            ),
            child: ClipOval(
              child: Image.asset(
                member.image,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) =>
                const Icon(Icons.person),
              ),
            ),
          ),

          const SizedBox(height: 12),

          Text(
            member.name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 4),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Text(
              member.title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11.5,
                color: Colors.grey.shade600,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }}
