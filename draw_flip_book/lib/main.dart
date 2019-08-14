import 'dart:ui';

import 'package:flutter/material.dart';

import 'flip_book_painter.dart';

void main() => runApp(new FlipBookApp());

class FlipBookApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Draw and Flip',
      theme: new ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or press Run > Flutter Hot Reload in IntelliJ). Notice that the
        // counter didn't reset back to zero; the application is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: new FlipBookPage(title: 'Flutter Demo Home Page'),
    );
  }
}

class FlipBookPage extends StatefulWidget {
  FlipBookPage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _FlipBookPageState createState() => new _FlipBookPageState();
}

class _FlipBookPageState extends State<FlipBookPage> {
  final _offsets = <Offset>[];

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return new Scaffold(
      body: buildGestureDetector(
          context,
          buildCustomPaint(context)
      ),
    );
  }

  GestureDetector buildGestureDetector(
      BuildContext context,
      Widget child
  ) {
    return GestureDetector(
      onPanDown: (details) {
        final renderBox = context.findRenderObject() as RenderBox;
        final localPosition = renderBox.globalToLocal(details.globalPosition);
        print("localPosition: $localPosition");
        setState(() {
          _offsets.add(localPosition);
        });
      },
      onPanUpdate: (details) {
        setState(() {
          final renderBox = context.findRenderObject() as RenderBox;
          final localPosition =
              renderBox.globalToLocal(details.globalPosition);
          print("localPosition: $localPosition");
          _offsets.add(localPosition);
        });
      },
      onPanEnd: (details) {
        setState(() {
          _offsets.add(null);
        });
      },
      child: Center(
        child: child,
      ),
    );
  }

  CustomPaint buildCustomPaint(BuildContext context) {
    return CustomPaint(
      painter: FlipBookPainter(_offsets),
      child: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
      ),
    );
  }
}
