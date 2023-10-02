import 'package:flutter/material.dart';

class MaterialBtn extends StatefulWidget {
  final String text;
  final Color border;
  final Color background;
  final Color textColor;
  final Widget child;
  final EdgeInsets margin;
  final Function onPressed;
  final BorderRadius radius;
  final double height;
  const MaterialBtn({
    Key? key,
    this.text = '',
    this.border = Colors.transparent,
    this.background = Colors.white,
    this.textColor = Colors.black,
    this.child = const SizedBox(),
    this.height = 40,
    this.margin = const EdgeInsets.symmetric(horizontal: 10),
    required this.onPressed,
    this.radius = const BorderRadius.all(Radius.circular(5)),
  }) : super(key: key);

  @override
  State<MaterialBtn> createState() => _MaterialBtnState();
}

class _MaterialBtnState extends State<MaterialBtn> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.margin,
      child: InkWell(
        onTap: () {
          widget.onPressed();
        },
        child: Ink(
          height: widget.height,
          decoration: BoxDecoration(
            color: widget.background,
            borderRadius: widget.radius,
            border: Border.all(
              color: widget.border,
            ),
          ),
          child: Center(
            child: widget.text != ""
                ? Text(
                    widget.text,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: widget.textColor,
                    ),
                  )
                : widget.child,
          ),
        ),
      ),
    );
  }
}
