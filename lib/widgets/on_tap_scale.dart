import 'package:flutter/material.dart';

class OnTapScale extends StatefulWidget {
  final Widget child;
  final Function? onTap;
  const OnTapScale({Key? key, required this.child, this.onTap})
      : super(key: key);

  @override
  State<OnTapScale> createState() => _OnTapScaleState();
}

class _OnTapScaleState extends State<OnTapScale> {
  bool isTapDown = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapUp: (details) {
        setState(() {
          isTapDown = false;
        });
      },
      onTapDown: (details) {
        setState(() {
          isTapDown = true;
        });
      },
      onTapCancel: () {
        setState(() {
          isTapDown = false;
        });
      },
      onTap: () {
        if (widget.onTap != null) {
          widget.onTap!();
        }
      },
      child: LayoutBuilder(builder: (context, constraints) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          child: Transform.scale(
            scale: isTapDown ? 0.975 : 1.0,
            alignment: Alignment.center,
            child: widget.child,
          ),
        );
      }),
    );
  }
}
