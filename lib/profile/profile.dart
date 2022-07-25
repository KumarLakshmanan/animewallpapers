import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontendforever/constants.dart';
import 'package:frontendforever/profile/about_profile.dart';
import 'package:frontendforever/profile/activity_profile.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter_initicon/flutter_initicon.dart';
import 'package:get/get.dart';
import 'package:frontendforever/controllers/data_controller.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  final d = Get.find<DataController>();
  PackageInfo? packageInfo;
  late TabController _tabController;
  @override
  void initState() {
    super.initState();
    initPackageInfo();
    _tabController = TabController(length: 2, vsync: this);
  }

  Future<void> initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      packageInfo = info;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(int.parse(d.prelogin!.theme.primary)),
      body: Column(
        children: <Widget>[
          Stack(
            children: [
              Center(
                child: SizedBox(
                  height: 120,
                  width: 120,
                  child: Stack(
                    clipBehavior: Clip.antiAlias,
                    children: [
                      Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(60),
                          child: CachedNetworkImage(
                            imageUrl: webUrl +
                                "api/avatar.php?username=" +
                                d.credentials!.username,
                            fit: BoxFit.cover,
                            height: 120,
                            width: 120,
                          ),
                        ),
                      ),
                      if (d.credentials!.pro)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: Colors.yellow,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.yellow[900]!,
                                width: 2,
                              ),
                            ),
                            child: Center(
                              child: CachedNetworkImage(
                                imageUrl: webUrl +
                                    d.prelogindynamic['assets']['royal'],
                                fit: BoxFit.contain,
                                height: 20,
                                width: 20,
                                color: Colors.yellow[900],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: InkWell(
                  onTap: () {},
                  child: Row(
                    children: [
                      Icon(
                        Icons.edit,
                        size: 16,
                        color: Color(
                          int.parse(
                            d.prelogin!.theme.bottombaractive,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "Edit",
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                              color: Color(
                                int.parse(
                                  d.prelogin!.theme.bottombaractive,
                                ),
                              ),
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Center(
            child: Text(
              d.credentials!.name,
              style: TextStyle(
                fontFamily: GoogleFonts.nunito().fontFamily,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 5),
          Center(
            child: Text(
              "@" + d.credentials!.username,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: Color(int.parse(d.prelogin!.theme.secondary)),
              unselectedLabelColor: Colors.grey,
              indicatorColor: Color(int.parse(d.prelogin!.theme.secondary)),
              indicatorWeight: 3,
              indicatorSize: TabBarIndicatorSize.tab,
              tabs: [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.person),
                      SizedBox(width: 5),
                      Text(
                        "About",
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.list),
                      SizedBox(width: 5),
                      Text(
                        "Activities",
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                Container(
                  color: const Color(0xFFf4f2f7),
                  child: const AboutProfile(),
                ),
                Container(
                  color: const Color(0xFFf4f2f7),
                  child: const ActivityProfile(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
