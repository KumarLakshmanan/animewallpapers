import 'package:flutter/material.dart';

// class EntryField extends StatefulWidget {
//   final String title;
//   final TextEditingController controller;
//   final bool isPassword;
//   final bool isEmail;
//   final Function(String)? isSubmit;
//   final bool isPhone;
//   final Color color;
//   final bool autoFocus;
//   final FocusNode? focusNode;
//   const EntryField({
//     Key? key,
//     required this.title,
//     required this.controller,
//     this.autoFocus = false,
//     this.isPassword = false,
//     this.isEmail = false,
//     this.isSubmit,
//     this.isPhone = false,
//     this.color = Colors.transparent,
//     this.focusNode,
//   }) : super(key: key);

//   @override
//   _EntryFieldState createState() => _EntryFieldState();
// }

// class _EntryFieldState extends State<EntryField> {
//   bool isObsure = false;
//   @override
//   void initState() {
//     super.initState();
//     isObsure = widget.isPassword;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.symmetric(vertical: 5),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: <Widget>[
//           TextFormField(
//             focusNode: widget.focusNode,
//             autofocus: widget.autoFocus,
//             controller: widget.controller,
//             obscureText: isObsure,
//             keyboardType: widget.isEmail
//                 ? TextInputType.emailAddress
//                 : widget.isPassword
//                     ? TextInputType.visiblePassword
//                     : widget.isPhone
//                         ? TextInputType.phone
//                         : TextInputType.text,
//             textInputAction: widget.isSubmit.runtimeType == Null
//                 ? TextInputAction.next
//                 : TextInputAction.done,
//             style: Theme.of(context).textTheme.headline6!.copyWith(
//                   color: Colors.black,
//                   fontSize: 12,
//                 ),
//             onFieldSubmitted: widget.isSubmit,
//             decoration: InputDecoration(
//               suffixIconConstraints: const BoxConstraints(maxHeight: 35),
//               fillColor: widget.color,
//               filled: true,
//               border: _myBorder(),
//               enabledBorder: _myBorder(),
//               disabledBorder: _myBorder(),
//               focusedBorder: _myBorder(),
//               focusedErrorBorder: _myBorder(),
//               hintText: widget.title,
//               hintStyle: Theme.of(context).textTheme.button!.copyWith(
//                     color: const Color(0xFF323231).withOpacity(0.5),
//                     height: 1.8,
//                   ),
//               prefixIcon: widget.isPhone
//                   ? null
//                   : Icon(
//                       widget.isEmail
//                           ? Icons.email_rounded
//                           : widget.isPassword
//                               ? Icons.vpn_key_rounded
//                               : Icons.person_rounded,
//                       color: Colors.black,
//                       size: 20,
//                     ),
//             ),
//           )
//         ],
//       ),
//     );
//   }

//   UnderlineInputBorder _myBorder() {
//     return UnderlineInputBorder(
//       borderRadius: BorderRadius.circular(5),
//       borderSide: const BorderSide(
//         color: Colors.transparent,
//       ),
//     );
//   }
// }
