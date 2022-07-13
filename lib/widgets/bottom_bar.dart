import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:frontendforever/controllers/theme_controller.dart';

class CustomBottomBar extends StatelessWidget {
  const CustomBottomBar({
    Key? key,
    this.selectedIndex = 0,
    this.itemCornerRadius = 50,
    required this.items,
    required this.onItemSelected,
  })  : assert(items.length >= 2 && items.length <= 5),
        super(key: key);

  final int selectedIndex;
  final List<BottomNavyBarItem> items;
  final Function onItemSelected;
  final double itemCornerRadius;

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.put(ThemeController());
    SubTheme subTheme = Get.isDarkMode
        ? themeController.currentTheme.dark
        : themeController.currentTheme.light;
    return SafeArea(
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: items.map((item) {
            var index = items.indexOf(item);
            return InkWell(
              onTap: () {
                onItemSelected(index);
              },
              child: Ink(
                color: index == selectedIndex
                    ? subTheme.secondary
                    : Colors.transparent,
                height: double.maxFinite,
                width: MediaQuery.of(context).size.width / items.length,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    item.icon,
                    const SizedBox(height: 4),
                    Text(
                      item.title,
                      style: TextStyle(
                        fontSize: 12,
                        color: index == selectedIndex
                            ? Colors.white
                            : Colors.white38,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class BottomNavyBarItem {
  BottomNavyBarItem({
    required this.title,
    required this.icon,
  });
  final String title;
  final Widget icon;
}
