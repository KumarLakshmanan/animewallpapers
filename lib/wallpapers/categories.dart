import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:frontendforever/constants.dart';
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
    return Container(
      height: 80,
      padding: const EdgeInsets.only(top: 10, bottom: 10),
      decoration: BoxDecoration(
        color: secondaryColor,
      ),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          if (loading == true) ...[
            for (var i = 0; i < 5; i++) ...[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Shimmer(
                  duration: const Duration(seconds: 2),
                  enabled: true,
                  child: Container(
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
            CategoryCard(
              category: category,
            ),
          ]
        ],
      ),
    );
  }
}

class CategoryCard extends StatelessWidget {
  final Map category;
  const CategoryCard({Key? key, required this.category}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(left: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        image: DecorationImage(
          image: CachedNetworkImageProvider(
            "${webUrl}img/${category['category']}.png",
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
          ),
        ),
      ),
    );
  }
}
