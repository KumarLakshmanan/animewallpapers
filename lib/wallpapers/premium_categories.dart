import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:frontendforever/controllers/premium_controller.dart';
import 'package:frontendforever/widgets/on_tap_scale.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:frontendforever/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class PremiumCategoriesListView extends StatefulWidget {
  const PremiumCategoriesListView({Key? key}) : super(key: key);

  @override
  State<PremiumCategoriesListView> createState() =>
      _PremiumCategoriesListViewState();
}

class _PremiumCategoriesListViewState extends State<PremiumCategoriesListView> {
  List categories = [];
  bool loading = true;
  final pc = Get.put(PremiumController());
  @override
  initState() {
    super.initState();
    getDataFromAPI();
  }

  getDataFromAPI() async {
    final prefs = await SharedPreferences.getInstance();
    String allCategories = prefs.getString('allPremiumCategories') ?? '';
    if (allCategories.isNotEmpty) {
      categories = json.decode(allCategories);
      loading = false;
      setState(() {});
    }
    var response = await http.post(
      Uri.parse(apiUrl),
      body: {'mode': 'getAllPremiumCategories'},
    );
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      if (data['error']['code'] == '#200') {
        categories = data['data'];
        prefs.setString('allPremiumCategories', json.encode(categories));
        loading = false;
        setState(() {});
        if (data['data'].isNotEmpty) {
          pc.category = data['data'][0]['category'];
          pc.pageNo = 1;
          pc.codes = [];
          pc.loaded = false;
          pc.getDataFromAPI(
            scategory: data['data'][0]['category'],
          );
          pc.update();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
        init: PremiumController(),
        builder: (pc) {
          return Container(
            height: 80,
            padding: const EdgeInsets.only(top: 10, bottom: 10),
            decoration: BoxDecoration(
              color: secondaryColor,
            ),
            child: ListView(
              physics: const BouncingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              children: [
                if (categories.isEmpty) ...[
                  for (var i = 0; i < 5; i++) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      child: Shimmer(
                        duration: const Duration(seconds: 2),
                        enabled: true,
                        child: Container(
                          width: 160,
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(
                              Radius.circular(6),
                            ),
                            color: Color(0xFF444857),
                          ),
                        ),
                      ),
                    ),
                  ]
                ],
                for (var category in categories) ...[
                  OnTapScale(
                    onTap: () {
                      pc.category = category['category'];
                      pc.pageNo = 1;
                      pc.codes = [];
                      pc.loaded = false;
                      pc.getDataFromAPI(
                        scategory: category['category'],
                      );
                      pc.update();
                    },
                    child: Container(
                      width: 160,
                      margin: const EdgeInsets.only(left: 10),
                      decoration: BoxDecoration(
                        border: pc.category == category['category']
                            ? Border.all(
                                color: cherryColor,
                                width: 2,
                              )
                            : null,
                        borderRadius: BorderRadius.circular(6),
                        image: DecorationImage(
                          image: CachedNetworkImageProvider(
                            category['image'],
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          color: Colors.black.withOpacity(0.5),
                        ),
                        alignment: Alignment.center,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 8,
                          ),
                          child: Text(
                            "${category['category']} (${category['count']})",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ),
                ]
              ],
            ),
          );
        });
  }
}
