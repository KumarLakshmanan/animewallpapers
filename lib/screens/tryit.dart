// ignore: implementation_imports
import 'package:highlight/src/mode.dart';
// ignore: implementation_imports
import 'package:highlight/src/common_modes.dart';

import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import 'package:flutter_highlight/themes/an-old-hope.dart';
import 'package:flutter_highlight/themes/atom-one-dark.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter/material.dart';
import 'package:frontendforever/constants.dart';
import 'package:frontendforever/controllers/data_controller.dart';
import 'package:intl/intl.dart';
import 'package:neopop/neopop.dart';
import 'package:get/get.dart';
import 'package:pluto_code_editor/pluto_code_editor.dart';
import 'package:webviewx/webviewx.dart';

const myAtomOneDarkTheme = {
  'root': TextStyle(
    color: Color(0xffabb2bf),
    backgroundColor: Color(0xff282c34),
  ),
  'comment': TextStyle(color: Color(0xff5c6370), fontStyle: FontStyle.italic),
  'quote': TextStyle(color: Color(0xff5c6370), fontStyle: FontStyle.italic),
  'doctag': TextStyle(color: Color(0xffc678dd)),
  'keyword': TextStyle(color: Color(0xffc678dd)),
  'formula': TextStyle(color: Color(0xffc678dd)),
  'section': TextStyle(color: Color(0xffe06c75)),
  'name': TextStyle(color: Color(0xffe06c75)),
  'selector-tag': TextStyle(color: Color(0xffe06c75)),
  'deletion': TextStyle(color: Color(0xffe06c75)),
  'subst': TextStyle(color: Color(0xffe06c75)),
  'literal': TextStyle(color: Color(0xff56b6c2)),
  'string': TextStyle(color: Color(0xff98c379)),
  'regexp': TextStyle(color: Color(0xff98c379)),
  'addition': TextStyle(color: Color(0xff98c379)),
  'attribute': TextStyle(color: Color(0xff98c379)),
  'meta-string': TextStyle(color: Color(0xff98c379)),
  'built_in': TextStyle(color: Color(0xffe6c07b)),
  'attr': TextStyle(color: Color(0xffd19a66)),
  'variable': TextStyle(color: Color(0xffd19a66)),
  'template-variable': TextStyle(color: Color(0xffd19a66)),
  'type': TextStyle(color: Color(0xffd19a66)),
  'selector-class': TextStyle(color: Color(0xffd19a66)),
  'selector-attr': TextStyle(color: Color(0xffd19a66)),
  'selector-pseudo': TextStyle(color: Color(0xffd19a66)),
  'number': TextStyle(color: Color(0xffd19a66)),
  'symbol': TextStyle(color: Color(0xff61aeee)),
  'bullet': TextStyle(color: Color(0xff61aeee)),
  'link': TextStyle(color: Color(0xff61aeee)),
  'meta': TextStyle(color: Color(0xff61aeee)),
  'selector-id': TextStyle(color: Color(0xff61aeee)),
  'title': TextStyle(color: Color(0xff61aeee)),
  'emphasis': TextStyle(fontStyle: FontStyle.italic),
  'strong': TextStyle(fontWeight: FontWeight.bold),
};

class TryIt extends StatefulWidget {
  final String html;
  final String css;
  final String js;
  const TryIt({
    Key? key,
    required this.html,
    required this.css,
    required this.js,
  }) : super(key: key);

  @override
  State<TryIt> createState() => _TryItState();
}

class _TryItState extends State<TryIt> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  PlutoCodeEditorController htmlContoller = PlutoCodeEditorController(
    code: "",
    theme: EditorTheme(
      syntaxTheme: myAtomOneDarkTheme,
      lineNumberStyle: const TextStyle(
        fontSize: 10,
        height: 1,
        color: Color(0xff61aeee),
      ),
    ),
    language: 'html',
  );
  PlutoCodeEditorController cssContoller = PlutoCodeEditorController(
    code: "",
    theme: EditorTheme(
      syntaxTheme: myAtomOneDarkTheme,
      lineNumberStyle: const TextStyle(
        fontSize: 10,
        height: 1,
        color: Color(0xff61aeee),
      ),
    ),
    language: 'css',
  );
  PlutoCodeEditorController jsContoller = PlutoCodeEditorController(
    code: "",
    theme: EditorTheme(
      syntaxTheme: myAtomOneDarkTheme,
      lineNumberStyle: const TextStyle(
        fontSize: 10,
        height: 1,
        color: Color(0xff61aeee),
      ),
    ),
    language: 'javascript',
  );

  StreamController streamController = StreamController.broadcast();
  bool loading = true;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 3);
    htmlContoller.setControllers(widget.html);
    cssContoller.setControllers(widget.css);
    jsContoller.setControllers(widget.js);
  }

  final d = Get.put(DataController());
  bool isRunning = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(int.parse(d.prelogin!.theme.primary)),
        title: const Text("Code Editor"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          labelColor: Colors.white,
          indicatorSize: TabBarIndicatorSize.tab,
          indicatorColor: Color(int.parse(d.prelogin!.theme.bottombaractive)),
          controller: _tabController,
          tabs: const [
            Tab(
              child: Text(
                'HTML',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
            Tab(
              child: Text(
                'CSS',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
            Tab(
              child: Text(
                'JS',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          PlutoCodeEditor(
            controller: htmlContoller,
          ),
          PlutoCodeEditor(
            controller: cssContoller,
          ),
          PlutoCodeEditor(
            controller: jsContoller,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(int.parse(d.prelogin!.theme.bottombaractive)),
        onPressed: () {
          Get.dialog(
            Scaffold(
              appBar: AppBar(
                backgroundColor: Color(int.parse(d.prelogin!.theme.primary)),
                title: const Text("Output"),
              ),
              body: WebViewX(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                initialContent: getAllCodes(htmlContoller) +
                    "<style>" +
                    getAllCodes(cssContoller) +
                    "</style>" +
                    "<script>" +
                    getAllCodes(jsContoller) +
                    "</script>",
                initialSourceType: SourceType.html,
                onPageFinished: (src) {
                  setState(() {
                    loading = false;
                  });
                },
              ),
            ),
          );
        },
        child: const Icon(Icons.play_arrow),
      ),
    );
  }

  getAllCodes(PlutoCodeEditorController controller) {
    String val = "";
    for (var i = 0; i < controller.controllers.length; i++) {
      val += controller.controllers[i].textEditingController.text;
    }
    return val;
  }
}
