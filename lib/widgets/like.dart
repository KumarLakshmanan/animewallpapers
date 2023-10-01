import 'package:animewallpapers/controllers/favorites_controller.dart';
import 'package:animewallpapers/models/single_blog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LikeButton extends StatefulWidget {
  final Color color;
  final ImageType id;
  const LikeButton({Key? key, required this.color, required this.id})
      : super(key: key);

  @override
  State<LikeButton> createState() => _LikeButtonState();
}

class _LikeButtonState extends State<LikeButton>
    with SingleTickerProviderStateMixin {
  final fc = Get.put(FavoritesController());
  late final AnimationController _controller = AnimationController(
    duration: const Duration(milliseconds: 200),
    vsync: this,
    value: 1.0,
  );

  @override
  void initState() {
    fc.init();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: FavoritesController(),
      builder: (fc) {
        return IconButton(
          onPressed: () {
            if (fc.favorites.any((element) => element.id == widget.id.id)) {
              fc.favorites.removeWhere((element) => element.id == widget.id.id);
            } else {
              fc.favorites.add(widget.id);
              _controller.reverse().then((value) => _controller.forward());
            }
            fc.save();
            fc.update();
          },
          icon: ScaleTransition(
            scale: Tween(begin: 0.7, end: 1.0).animate(
              CurvedAnimation(parent: _controller, curve: Curves.easeOut),
            ),
            child: fc.favorites.contains(widget.id)
                ? const Icon(
                    Icons.favorite,
                    color: Colors.red,
                  )
                : Icon(
                    Icons.favorite_border,
                    color: widget.color,
                  ),
          ),
        );
      },
    );
  }
}
