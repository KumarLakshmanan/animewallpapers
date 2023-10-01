// import 'package:flutter/material.dart';
// import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
// import 'package:animewallpapers/controllers/data_controller.dart';
// import 'package:animewallpapers/shimmer/restaurant_shimmer.dart';
// import 'package:animewallpapers/wallpapers/single_blog_item.dart';
// import 'package:get/get.dart';

// class SingleCategoryImages extends StatefulWidget {
//   final String category;
//   const SingleCategoryImages({
//     Key? key,
//     required this.category,
//   }) : super(key: key);
//   @override
//   State<SingleCategoryImages> createState() => _SingleCategoryImagesState();
// }

// class _SingleCategoryImagesState extends State<SingleCategoryImages>
//     with WidgetsBindingObserver {
//   final ScrollController _scrollController = ScrollController();
//   final controller = TextEditingController();
//   final searchFocusNode = FocusNode();
//   final dc = Get.put(DataController());

//   @override
//   void initState() {
//     super.initState();
//     dc.getDataFromAPI(
//       scategory: widget.category,
//     );
//     _scrollController.addListener(() {
//       if ((_scrollController.position.pixels + (Get.width)) >=
//           (_scrollController.position.maxScrollExtent)) {
//         dc.getDataFromAPI(
//           scategory: widget.category,
//         );
//       }
//     });
//   }

//   @override
//   void dispose() {
//     _scrollController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         title: Text(
//           widget.category,
//           style: const TextStyle(
//             color: Colors.white,
//             fontSize: 16,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ),
//       body: RefreshIndicator(
//         onRefresh: () async {
//           dc.pageNo = 1;
//           dc.codes = [];
//           dc.loaded = false;
//           dc.getDataFromAPI();
//           dc.update();
//         },
//         child: GetBuilder(
//           init: DataController(),
//           builder: (dc) {
//             if (dc.codes.isNotEmpty || !dc.loaded) {
//               return Padding(
//                 padding: const EdgeInsets.only(
//                   left: 8.0,
//                   right: 8.0,
//                 ),
//                 child: MasonryGridView(
//                   controller: _scrollController,
//                   physics: const BouncingScrollPhysics(),
//                   mainAxisSpacing: 8,
//                   crossAxisSpacing: 8,
//                   gridDelegate:
//                       const SliverSimpleGridDelegateWithFixedCrossAxisCount(
//                     crossAxisCount: 2,
//                   ),
//                   children: [
//                     for (var i = 0; i < dc.codes.length; i++) ...[
//                       SingleBlogItem(
//                         index: i,
//                       ),
//                     ],
//                     if (!dc.loaded) ...[
//                       for (var i = 0; i < 2; i++) const WallpaperShimmer(),
//                     ],
//                   ],
//                 ),
//               );
//             } else {
//               return ListView(
//                 children: [
//                   Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: SizedBox(
//                       height: (Get.width * 0.5) * 2,
//                       width: (Get.width),
//                       child: const Row(
//                         children: [
//                           Expanded(child: WallpaperShimmer()),
//                           SizedBox(
//                             width: 10,
//                           ),
//                           Expanded(child: WallpaperShimmer()),
//                         ],
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 10),
//                   const Text(
//                     "No Wallpapers Found",
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                     ),
//                     textAlign: TextAlign.center,
//                   )
//                 ],
//               );
//             }
//           },
//         ),
//       ),
//     );
//   }
// }
