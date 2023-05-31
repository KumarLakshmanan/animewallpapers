import 'package:flutter/material.dart';
import '../constants.dart';

class InlineDropDown extends StatefulWidget {
  final List<String> items;
  final String? selectedItem;
  final Function(String?) onChanged;
  final bool isDark;
  const InlineDropDown({
    Key? key,
    required this.items,
    required this.selectedItem,
    required this.onChanged,
    this.isDark = true,
  }) : super(key: key);

  @override
  _InlineDropDownState createState() => _InlineDropDownState();
}

class _InlineDropDownState extends State<InlineDropDown> {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
          color: primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(4.0),
          boxShadow: widget.isDark
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    offset: const Offset(0, 4),
                    blurRadius: 16,
                  ),
                ]),
      child: DropdownButton<String>(
        value: widget.selectedItem,
        icon: const Padding(
          padding: EdgeInsets.only(bottom: 4.0),
          child: Icon(
            Icons.arrow_drop_down_rounded,
            color: Colors.black,
          ),
        ),
        iconSize: 24,
        style: Theme.of(context).textTheme.bodyMedium,
        onChanged: (String? newValue) {
          widget.onChanged(newValue);
        },
        selectedItemBuilder: (context) {
          return widget.items.map<Widget>((String item) {
            return Center(
              child: Text(
                item,
                style: const TextStyle(
                  color: Colors.black,
                ),
              ),
            );
          }).toList();
        },
        underline: Container(),
        items: widget.items.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value, style: Theme.of(context).textTheme.bodyMedium),
          );
        }).toList(),
      ),
    );
  }
}
