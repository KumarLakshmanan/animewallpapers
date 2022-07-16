import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:frontendforever/constants.dart';
import 'package:frontendforever/controllers/data_controller.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:frontendforever/constants.dart';
import 'package:frontendforever/controllers/theme_controller.dart';
import 'package:frontendforever/pages/main_screen.dart';

const kAnimationDuration = Duration(milliseconds: 200);

class OnBoardingPage extends StatefulWidget {
  const OnBoardingPage({Key? key}) : super(key: key);

  @override
  State<OnBoardingPage> createState() => _OnBoardingPageState();
}

class _OnBoardingPageState extends State<OnBoardingPage> {
  int currentIndex = 0;
  final pageController = PageController();
  final dc = Get.put(DataController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      backgroundColor: Color(int.parse(dc.prelogin!.theme.background)),
      body: Stack(
        children: [
          Positioned.fill(
            child: PageView.builder(
              onPageChanged: (value) {
                setState(() {
                  currentIndex = value;
                });
              },
              controller: pageController,
              itemCount: dc.prelogindynamic['onboarding'].length,
              itemBuilder: (context, index) {
                return PageBuilderWidget(
                  title: dc.prelogindynamic['onboarding'][index]['title'],
                  imgurl: dc.prelogindynamic['onboarding'][index]['image'],
                );
              },
            ),
          ),
          Positioned(
            bottom: 20,
            width: MediaQuery.of(context).size.width,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 50,
                  width: 100,
                  child: MaterialButton(
                    elevation: 0,
                    focusElevation: 0,
                    hoverElevation: 0,
                    highlightElevation: 0,
                    onPressed: () {
                      Get.offAll(
                        const MainScreen(),
                        transition: Transition.rightToLeft,
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Skip",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color:
                                Color(int.parse(dc.prelogin!.theme.secondary)),
                          ),
                          textAlign: TextAlign.end,
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      dc.prelogindynamic['onboarding'].length,
                      (index) => buildDot(index: index),
                    ),
                  ),
                ),
                SizedBox(
                  height: 50,
                  width: 100,
                  child: MaterialButton(
                    elevation: 0,
                    focusElevation: 0,
                    hoverElevation: 0,
                    highlightElevation: 0,
                    onPressed: () {
                      if (currentIndex ==
                          dc.prelogindynamic['onboarding'].length - 1) {
                        Get.offAll(
                          const MainScreen(),
                          transition: Transition.rightToLeft,
                        );
                      } else {
                        pageController.nextPage(
                          duration: kAnimationDuration,
                          curve: Curves.fastLinearToSlowEaseIn,
                        );
                      }
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Next",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color:
                                Color(int.parse(dc.prelogin!.theme.secondary)),
                          ),
                          textAlign: TextAlign.end,
                        ),
                        const SizedBox(width: 5),
                        CachedNetworkImage(
                          imageUrl: webUrl +
                              dc.prelogindynamic['assets']['next'],
                          width: 25,
                          color: Color(int.parse(dc.prelogin!.theme.secondary)),
                          height: 25,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  AnimatedContainer buildDot({int? index}) {
    return AnimatedContainer(
      duration: kAnimationDuration,
      margin: const EdgeInsets.only(right: 5),
      height: 12,
      width: 12,
      decoration: BoxDecoration(
        color: currentIndex == index
            ? Color(int.parse(dc.prelogin!.theme.secondary))
            : Colors.transparent,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: Color(int.parse(dc.prelogin!.theme.secondary)),
          width: 1,
        ),
      ),
    );
  }
}

class PageBuilderWidget extends StatelessWidget {
  final String title;
  final String imgurl;
  PageBuilderWidget({
    Key? key,
    required this.title,
    required this.imgurl,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
          left: 15, right: 15, bottom: MediaQuery.of(context).padding.top),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Color(int.parse(
                  Get.find<DataController>().prelogin!.theme.primary)),
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Container(
            margin: const EdgeInsets.only(top: 20),
            child: CachedNetworkImage(
              imageUrl: webUrl + imgurl,
              height: MediaQuery.of(context).size.height * 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
