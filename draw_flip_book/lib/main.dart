import 'dart:ui';

import 'package:flutter/material.dart';

import 'flip_book_painter.dart';

void main() => runApp(new FlipBookApp());

const _FADE_DURATION = 20;
const double _FRAME_TOP = 100;
const double _SIZE = 300;

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
  int currentFrame = 3;
  StrokeCap strokeCap = StrokeCap.round;

  // TODO: Generalize/Scale
  bool _isVisible2 = true;
  bool _isVisible3 = true;
  bool _replayFrames = false;

  // TODO: Generalize/Scale into lists of List<Offset>
  List<Offset> points1 = List();
  List<Offset> points2 = List();
  List<Offset> points3 = List();

  // TODO: Generalize/Scale
  // For accessing the RenderBox of each frame
  GlobalKey key3 = GlobalKey();
  GlobalKey key2 = GlobalKey();
  GlobalKey key1 = GlobalKey();

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return new Scaffold(
      body: _buildGestureDetector(
        context,
        Container(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                height: 500,
                child: _framesStack(context),
              ),
              Expanded(
                child: Container(child: _buttonRow()),
              )
            ],
          ),
        ),
      ),
    );
  }

  Row _buttonRow() {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Container(
          child: FloatingActionButton(
            onPressed: () {
              setState(() {
                _toggleFramesVisibility();
              });
            },
            child: Icon(Icons.navigate_next),
          ),
        ),
        Container(
          child: FloatingActionButton(
            onPressed: () {
              setState(() {
                // TODO: loop all the frames in sequence
              });
            },
            child: Icon(Icons.play_arrow),
          ),
        ),
        Container(
          child: FloatingActionButton(
            onPressed: () {
              setState(() {
                _clear();
                currentFrame = 3;
                _isVisible3 = true;
                _replayFrames = false;
              });
            },
            child: Icon(Icons.clear),
          ),
        ),
      ],
    );
  }

  Stack _framesStack(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        // TODO: Generalize/Scale
        _buildPositionedFrame(context, key1, points1, true, Colors.green),
        _buildPositionedFrame(
            context, key2, points2, _isVisible2, Colors.lightBlue),
        _buildPositionedFrame(
            context, key3, points3, _isVisible3, Colors.amberAccent),
      ],
    );
  }

  GestureDetector _buildGestureDetector(BuildContext context, Widget child) {
    return GestureDetector(
      onPanDown: (details) {
        setState(() {
          _addPointsForCurrentFrame(details.globalPosition);
        });
      },
      onPanUpdate: (details) {
        setState(() {
          _addPointsForCurrentFrame(details.globalPosition);
        });
      },
      onPanEnd: (details) {
        setState(() {
          _getPointsForFrame(currentFrame)..add(null);
        });
      },
      child: Center(
        child: child,
      ),
    );
  }

  void _toggleFramesVisibility() {
    if (_replayFrames) {
      if (currentFrame == 1) {
        currentFrame = 3;
        _isVisible3 = true;
        _replayFrames = false;
      }
    } else {
      if (currentFrame == 3) {
        currentFrame = 2;
        _isVisible2 = true;
        _isVisible3 = false;
      } else if (currentFrame == 2) {
        currentFrame = 1;
        _isVisible2 = false;
        _replayFrames = true;
      }
    }
  }

  void _addPointsForCurrentFrame(Offset globalPosition) {
    final RenderBox renderBox =
        _getWidgetKeyForFrame(currentFrame).currentContext.findRenderObject();
    final offset = renderBox.globalToLocal(globalPosition);

    _getPointsForFrame(currentFrame)..add(offset);
  }

  List<Offset> _getPointsForFrame(int card) {
    if (card == 1)
      return points1;
    else if (card == 2)
      return points2;
    else
      return points3;
  }

  GlobalKey _getWidgetKeyForFrame(int card) {
    if (card == 1)
      return key1;
    else if (card == 2)
      return key2;
    else
      return key3;
  }

  Positioned _buildPositionedFrame(BuildContext context, GlobalKey key,
      List<Offset> points, bool isVisible, Color color) {
    return Positioned(
      top: _FRAME_TOP,
      child: AnimatedOpacity(
        opacity: isVisible ? 1.0 : 0.0,
        duration: Duration(milliseconds: _FADE_DURATION),
        child: Container(
          key: key,
          width: _SIZE,
          height: _SIZE,
          color: color,
          child: FittedBox(
            child: SizedBox(
              child: ClipRect(child: _buildCustomPaint(context, points)),
              width: _SIZE,
              height: _SIZE,
            ),
          ),
        ),
      ),
    );
  }

  CustomPaint _buildCustomPaint(BuildContext context, List<Offset> points) {
    return CustomPaint(
      painter: FlipBookPainter(points),
      child: Container(
        height: _SIZE,
        width: _SIZE,
      ),
    );
  }

  void _clear() {
    points1.clear();
    points2.clear();
    points3.clear();
  }
}
