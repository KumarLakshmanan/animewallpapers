import 'package:flutter/material.dart';
import 'package:frontendforever/constants.dart';

class SearchBox extends StatefulWidget implements PreferredSizeWidget {
  final TextEditingController controller;
  final Function(String) onChanged;
  final FocusNode searchFocusNode;
  const SearchBox({
    super.key,
    required this.controller,
    required this.searchFocusNode,
    required this.onChanged,
  });

  @override
  State<SearchBox> createState() => _SearchBoxState();

  @override
  Size get preferredSize => const Size.fromHeight(60);
}

class _SearchBoxState extends State<SearchBox> {
  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(60),
      child: Container(
        margin: const EdgeInsets.only(
          left: 10,
          right: 10,
          bottom: 10,
        ),
        decoration: BoxDecoration(
          color: secondaryColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            const SizedBox(width: 10),
            GestureDetector(
              onTap: () {
                widget.onChanged(widget.controller.text);
              },
              child: Icon(
                Icons.search,
                color: Colors.white.withOpacity(0.6),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                focusNode: widget.searchFocusNode,
                controller: widget.controller,
                onSubmitted: (value) {
                  widget.onChanged(value);
                },
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintStyle: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.6),
                  ),
                  hintText: 'Search...',
                ),
                cursorColor: Colors.white,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.6),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
