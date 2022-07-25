import 'package:flutter/material.dart';
import 'package:frontendforever/addprofile/about.dart';
import 'package:frontendforever/addprofile/country.dart';
import 'package:frontendforever/addprofile/skills.dart';
import 'package:frontendforever/addprofile/website.dart';
import 'package:frontendforever/controllers/data_controller.dart';
import 'package:frontendforever/profile/edit_card.dart';
import 'package:get/get.dart';

class AboutProfile extends StatefulWidget {
  const AboutProfile({Key? key}) : super(key: key);

  @override
  State<AboutProfile> createState() => _AboutProfileState();
}

class _AboutProfileState extends State<AboutProfile> {
  final dc = Get.put(DataController());
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GetBuilder(
          init: DataController(),
          builder: (c) {
            return Column(
              children: [
                EditCardWidget(
                  title: "About",
                  value: dc.credentials!.about,
                  noValue:
                      "No About data is added. Add your about to show yourself to your profile visitors.",
                  icon: Icons.info_outline,
                  onTap: () {
                    Get.dialog(
                      const AddAbout(),
                    );
                  },
                ),
                const SizedBox(height: 10),
                EditCardWidget(
                    title: "Country",
                    value: dc.credentials!.country,
                    noValue:
                        "No Country data is added. Add your country list your profile to the leaderboard.",
                    icon: Icons.location_on_outlined,
                    onTap: () {
                      Get.dialog(
                        const AddCountry(),
                      );
                    }),
                const SizedBox(height: 10),
                EditCardWidget(
                    title: "Skills",
                    list: dc.credentials!.skills,
                    icon: Icons.work_outline,
                    noValue:
                        "No Skills data is added. Add your skills to open up more job opportunities.",
                    onTap: () {
                      Get.dialog(
                        const AddSkills(),
                      );
                    }),
                const SizedBox(height: 10),
                EditCardWidget(
                    title: "Website",
                    value: dc.credentials!.website,
                    icon: Icons.public_outlined,
                    noValue:
                        "No Website data is added. Add your website to get more traffic.",
                    onTap: () {
                      Get.dialog(
                        const AddWebsite(),
                      );
                    }),
              ],
            );
          }
        ),
      ),
    );
  }
}
