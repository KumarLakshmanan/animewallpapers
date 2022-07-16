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
    theme: EditorTheme(syntaxTheme: atomOneDarkTheme),
    language: 'html',
  );
  PlutoCodeEditorController cssContoller = PlutoCodeEditorController(
    code: "",
    theme: EditorTheme(
      syntaxTheme: atomOneDarkTheme,
    ),
    language: 'css',
  );
  PlutoCodeEditorController jsContoller = PlutoCodeEditorController(
    code: "",
    theme: EditorTheme(syntaxTheme: atomOneDarkTheme),
    language: 'javscript',
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
                initialContent:
                    'https://api.frontendforever.com/render.php?html=' +
                        Uri.encodeComponent(getAllCodes(htmlContoller)) +
                        '&css=' +
                        Uri.encodeComponent(getAllCodes(cssContoller)) +
                        '&js=' +
                        Uri.encodeComponent(getAllCodes(jsContoller)),
                initialSourceType: SourceType.url,
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