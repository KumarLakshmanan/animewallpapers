import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontendforever/controllers/theme_controller.dart';
import 'package:frontendforever/screens/login_page.dart';
import 'package:frontendforever/screens/register_page.dart';
import 'package:frontendforever/widgets/all_widget.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final ThemeController themeController = Get.put(ThemeController());
  @override
  void initState() {
    _tabController = TabController(vsync: this, length: 2);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SubTheme subTheme = Get.isDarkMode
        ? themeController.currentTheme.dark
        : themeController.currentTheme.light;
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
        body: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Column(
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * .025),
              buildTitle(context, subTheme),
              Align(
                alignment: Alignment.center,
                child: TabBar(
                  isScrollable: true,
                  labelColor: subTheme.primary,
                  unselectedLabelColor: Colors.grey[800],
                  indicatorWeight: 3.0,
                  indicator: UnderlineTabIndicator(
                    borderSide: BorderSide(
                      color: subTheme.primary,
                      width: 3.0,
                    ),
                    insets: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 8.0,
                    ),
                  ),
                  indicatorSize: TabBarIndicatorSize.label,
                  controller: _tabController,
                  tabs: const [
                    Tab(
                      text: 'Login',
                    ),
                    Tab(
                      text: 'Register',
                    ),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    LoginPage(
                      theme: subTheme,
                    ),
                    RegisterPage(
                      theme: subTheme,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
