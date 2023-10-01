import 'package:flutter/material.dart';

class EntryField extends StatefulWidget {
  final String title;
  final TextEditingController controller;
  final bool isPassword;
  final bool isEmail;
  final bool isPhone;
  final Color color;
  final Function? isSubmit;
  const EntryField({
    Key? key,
    required this.title,
    required this.controller,
    this.isPassword = false,
    this.color = Colors.black,
    this.isEmail = false,
    this.isPhone = false,
    this.isSubmit,
  }) : super(key: key);

  @override
  _EntryFieldState createState() => _EntryFieldState();
}

class _EntryFieldState extends State<EntryField> {
  bool isObsure = false;
  @override
  void initState() {
    super.initState();
    isObsure = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      obscureText: isObsure,
      keyboardType: widget.isPhone
          ? TextInputType.phone
          : widget.isEmail
              ? TextInputType.emailAddress
              : widget.isPassword
                  ? TextInputType.visiblePassword
                  : TextInputType.text,
      onSubmitted: (value) {
        widget.isSubmit!();
      },
      textInputAction:
          widget.isSubmit != null ? TextInputAction.done : TextInputAction.next,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.all(16),
        isDense: true,
        border: const OutlineInputBorder(),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: widget.color,
            width: 1.2,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: widget.color,
            width: 2,
          ),
        ),
        labelText: widget.title,
        suffixIcon: widget.isPassword
            ? GestureDetector(
                onTap: () {
                  setState(() {
                    isObsure = !isObsure;
                  });
                },
                child: Icon(
                  isObsure ? Icons.visibility_off : Icons.visibility,
                  color: widget.color,
                ),
              )
            : const Icon(
                Icons.email,
                color: Colors.transparent,
              ),
      ),
    );
  }
}

Widget submitButton(
    BuildContext context, Function onTap, String text, Widget? child) {
  return InkWell(
    onTap: () {
      onTap();
    },
    child: Container(
      width: MediaQuery.of(context).size.width,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(
          Radius.circular(5),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.grey.shade200,
            offset: const Offset(2, 4),
            blurRadius: 5,
            spreadRadius: 2,
          )
        ],
        gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              const Color(0xFF30475E),
              const Color(0xFF30475E).withOpacity(0.8),
            ]),
      ),
      child: child ??
          Text(
            text,
            style: const TextStyle(fontSize: 20, color: Colors.white),
          ),
    ),
  );
}

Expanded buildDivider({
  Color color = const Color(0xFF989898),
}) {
  return Expanded(
    child: Divider(
      color: color,
      height: 1.5,
    ),
  );
}
