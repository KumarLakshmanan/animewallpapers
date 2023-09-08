import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:animewallpapers/constants.dart';

class SideSlide extends StatefulWidget {
  final String title;
  final int cpage;
  final List<String> images;
  final int id;
  const SideSlide({
    Key? key,
    required this.title,
    required this.images,
    required this.cpage,
    required this.id,
  }) : super(key: key);

  @override
  State<SideSlide> createState() => _SideSlideState();
}

class _SideSlideState extends State<SideSlide> {
  late int currentPage;
  late PageController pageController;
  @override
  void initState() {
    super.initState();
    pageController = PageController(
      initialPage: widget.cpage,
    );
    currentPage = widget.cpage;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          GestureDetector(
            child: const Icon(
              Icons.arrow_back_ios,
              size: 20,
            ),
            onTap: () {
              pageController.previousPage(
                duration: const Duration(milliseconds: 100),
                curve: Curves.easeInOut,
              );
            },
          ),
          Center(
            child: Text(
              '${currentPage + 1}/${widget.images.length}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          GestureDetector(
            child: const Icon(
              Icons.arrow_forward_ios,
              size: 20,
            ),
            onTap: () {
              pageController.nextPage(
                duration: const Duration(milliseconds: 100),
                curve: Curves.easeInOut,
              );
            },
          ),
        ],
        title: Text(widget.title),
      ),
      backgroundColor: Colors.grey.shade800,
      body: PageView(
        onPageChanged: (i) {
          setState(() {
            currentPage = i;
          });
        },
        controller: pageController,
        children: [
          for (final image in widget.images)
            Container(
              padding: const EdgeInsets.all(8.0),
              child: Hero(
                tag: image + widget.id.toString(),
                child: InteractiveViewer(
                  maxScale: 5,
                  child: CachedNetworkImage(
                    imageUrl: "${webUrl}uploads/images/$image",
                    fit: BoxFit.fitWidth,
                    placeholder: (context, url) => const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
