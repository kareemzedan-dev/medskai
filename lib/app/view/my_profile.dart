import 'package:flutter/material.dart';
import 'package:flutter_app/app/controller/my_profile_controller.dart';
import 'package:flutter_app/app/controller/profile_controller.dart';
import 'package:flutter_app/app/view/components/profile/my-order-screen.dart';
import 'package:flutter_app/app/view/components/profile/profile-screen.dart';
import 'package:get/get.dart';
import 'package:get_it_mixin/get_it_mixin.dart';

import 'components/profile/settings-screen.dart';

class MyProfileScreen extends StatefulWidget with GetItStatefulWidgetMixin {
  MyProfileScreen({Key? key}) : super(key: key);

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  late PageController _pageController;
  late ProfileController _profileController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentPage);
    _profileController = Get.find<ProfileController>();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToPage(int page) {
    _pageController.animateToPage(
      page,
      duration: Duration(milliseconds: 100),
      curve: Curves.easeInOut,
    );
    _currentPage = page;
  }

  void _goBack() {
    _pageController.animateToPage(
      0,
      duration: Duration(milliseconds: 100),
      curve: Curves.easeInOut,
    );
    _currentPage = 0;
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MyProfileController>(builder: (value) {
      return Column(children: [
        Expanded(
            child: PageView(
          physics: const NeverScrollableScrollPhysics(),
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _currentPage = index;
            });
          },
          children: [
            Profile(
              myProfileParser: value.parser,
              goToPage: (page) => _goToPage(page),
              goBack: (page) => _goBack(),
              profileController: _profileController,
            ),
            SettingsScreen(
                pageController: _pageController, goBack: (page) => _goBack()),
            MyOrderScreen(
                pageController: _pageController, goBack: (page) => _goBack()),
          ],
        )),
      ]);
    });
  }
}
