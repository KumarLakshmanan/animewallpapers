import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:animewallpapers/constants.dart';
import 'package:animewallpapers/functions.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class FilterBy extends StatefulWidget {
  final Function(String) onChanged;
  const FilterBy({super.key, required this.onChanged});

  @override
  State<FilterBy> createState() => _FilterByState();
}

class _FilterByState extends State<FilterBy> {
  String selected = "";
  List categories = [];

  getKeywords() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey("keywords")) {
      categories = json.decode(prefs.getString("keywords")!);
      setState(() {});
    }
    var response = await http.get(
      Uri.parse(apiUrl).replace(
        query: "mode=getAllKeyWords",
      ),
    );
    if (kDebugMode) {
      print(response.body);
    }
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      if (data['error']['code'] == '#200') {
        categories = data['data'];
        prefs.setString("keywords", json.encode(categories));
        setState(() {});
      } else {
        // ignore: use_build_context_synchronously
        showErrorDialog(context, data['error']['description']);
      }
    }
  }

  @override
  void initState() {
    getKeywords();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 30,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6.0),
            child: const Text(
              "Filter By: ",
              style: TextStyle(
                letterSpacing: 1,
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                for (var i = 0; i < categories.length; i++)
                  GestureDetector(
                    onTap: () {
                      if (selected == categories[i]) {
                        selected = "";
                      } else {
                        selected = categories[i];
                      }
                      widget.onChanged(selected);
                      setState(() {});
                      return;
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: selected == categories[i]
                            ? const Color(0xFFDD0046)
                            : secondaryColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.only(
                        left: 10.0,
                        right: 10.0,
                        top: 2,
                        bottom: 2,
                      ),
                      alignment: Alignment.center,
                      margin: const EdgeInsets.only(
                        left: 4.0,
                        right: 4.0,
                      ),
                      child: Text(
                        categories[i].toString().toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
