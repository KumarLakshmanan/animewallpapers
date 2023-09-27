import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:animewallpapers/controllers/data_controller.dart';
import 'package:animewallpapers/widgets/on_tap_scale.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:animewallpapers/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class CategoriesListView extends StatefulWidget {
  const CategoriesListView({Key? key}) : super(key: key);

  @override
  State<CategoriesListView> createState() => _CategoriesListViewState();
}

class _CategoriesListViewState extends State<CategoriesListView> {
  List categories = [];
  bool loading = true;
  @override
  initState() {
    super.initState();
    getDataFromAPI();
  }

  getDataFromAPI() async {
    final prefs = await SharedPreferences.getInstance();
    String allCategories = prefs.getString('allCategories') ?? '';
    if (allCategories.isNotEmpty) {
      categories = json.decode(allCategories);
      loading = false;
      setState(() {});
    }
    var response = await http.post(
      Uri.parse(apiUrl),
      body: {'mode': 'getAllCategories'},
    );
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      if (data['error']['code'] == '#200') {
        categories = data['data'];
        prefs.setString('allCategories', json.encode(categories));
        loading = false;
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
        init: DataController(),
        builder: (dc) {
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
                if (loading == true) ...[
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
                ] else ...[
                  OnTapScale(
                    onTap: () {
                      dc.category = "random";
                      dc.pageNo = 1;
                      dc.codes = [];
                      dc.loaded = false;
                      dc.getDataFromAPI(
                        scategory: "random",
                      );
                      dc.update();
                    },
                    child: Container(
                      width: 160,
                      margin: const EdgeInsets.only(left: 10),
                      decoration: BoxDecoration(
                        border: dc.category == "random"
                            ? Border.all(
                                color: cherryColor,
                                width: 2,
                              )
                            : null,
                        borderRadius: BorderRadius.circular(6),
                        image: DecorationImage(
                          image: CachedNetworkImageProvider(
                            "${webUrl}img/Random.png",
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
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 8,
                          ),
                          child: Text(
                            "Random",
                            style: TextStyle(
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
                ],
                for (var category in categories) ...[
                  OnTapScale(
                    onTap: () {
                      dc.category = category['category'];
                      dc.pageNo = 1;
                      dc.codes = [];
                      dc.loaded = false;
                      dc.getDataFromAPI(
                        scategory: category['category'],
                      );
                      dc.update();
                    },
                    child: Container(
                      width: 160,
                      margin: const EdgeInsets.only(left: 10),
                      decoration: BoxDecoration(
                        border: dc.category == category['category']
                            ? Border.all(
                                color: cherryColor,
                                width: 2,
                              )
                            : null,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Stack(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: CachedNetworkImage(
                                  imageUrl:
                                      '${webUrl}uploads/images/${category["image1"]}',
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Expanded(
                                child: CachedNetworkImage(
                                  imageUrl:
                                      '${webUrl}uploads/images/${category["image2"]}',
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            decoration: BoxDecoration(
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
                        ],
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
