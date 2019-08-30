import 'dart:ui';

import 'package:flutter/material.dart';

import 'flip_book_painter.dart';

void main() => runApp(new FlipBookApp());

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

class _FlipBookPageState extends State<FlipBookPage>
    with TickerProviderStateMixin {
  Animation<double> animation1;
  Animation<double> animation2;
  Animation<double> animation3;
  Animation<double> animation4;
  AnimationController controller;

  int currentFrame = 1;
  StrokeCap strokeCap = StrokeCap.round;

  // TODO: Generalize/Scale
  bool _isVisible1 = true;
  bool _isVisible2 = false;
  bool _isVisible3 = false;
  bool _isVisible4 = false;

  bool _isAnimating = false;

  double maxFrameOpacity = 0.7;

  bool _replayFrames = false;

  // TODO: Generalize/Scale into lists of List<Offset>
  List<Offset> points1 = List();
  List<Offset> points2 = List();
  List<Offset> points3 = List();
  List<Offset> points4 = List();

  // TODO: Generalize/Scale
  // For accessing the RenderBox of each frame
  GlobalKey key1 = GlobalKey();
  GlobalKey key2 = GlobalKey();
  GlobalKey key3 = GlobalKey();
  GlobalKey key4 = GlobalKey();

  @override
  void initState() {
    super.initState();
    _buildAnimationController();
    _buildAnimations();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
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

  Widget _buttonRow() {
    final nextFrameButton = Container(
      child: FloatingActionButton(
        onPressed: () {
          setState(() {
            _toggleFramesVisibility();
          });
        },
        child: Icon(Icons.navigate_next),
      ),
    );
    final playButton = Container(
      child: FloatingActionButton(
        onPressed: () {
          setState(() {
            _startAnimation();
          });
        },
        child: Icon(Icons.play_arrow),
      ),
    );
    final stopButton = Container(
      child: FloatingActionButton(
        onPressed: () {
          setState(() {
            // Add "null" to the points to avoid a line being drawn upon
            // post animation paint attempts
            points1..add(null);
            points2..add(null);
            points3..add(null);
            points4..add(null);

            _stopAnimation();
          });
        },
        child: Icon(Icons.stop),
      ),
    );

    final clearFramesButton = Container(
      child: FloatingActionButton(
        onPressed: () {
          setState(() {
            _clearPoints();
            _stopAnimation();
          });
        },
        child: Icon(Icons.clear),
      ),
    );

    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        nextFrameButton,
        playButton,
        stopButton,
        clearFramesButton,
      ],
    );
  }

  void _stopAnimation() {
    controller.stop();
    controller.value = 0.0;
    _resetVisibleFrames();
    _isAnimating = false;
  }

  void _resetVisibleFrames() {
    currentFrame = 1;

    _isVisible1 = true;
    _isVisible2 = false;
    _isVisible3 = false;
    _isVisible4 = false;

    _replayFrames = false;
  }

  Widget _framesStack(BuildContext context) => Stack(
        alignment: Alignment.center,
        children: <Widget>[
          // TODO: Generalize/Scale
          _buildPositionedFrame(
              context, key1, points1, _isVisible1, Colors.white, 1),
          _buildPositionedFrame(
              context, key2, points2, _isVisible2, Colors.white, 2),
          _buildPositionedFrame(
              context, key3, points3, _isVisible3, Colors.white, 3),
          _buildPositionedFrame(
              context, key4, points4, _isVisible4, Colors.white, 4),
        ],
      );

  Widget _buildGestureDetector(BuildContext context, Widget child) {
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
      if (currentFrame == 4) {
        _resetVisibleFrames();
      }
    } else {
      if (currentFrame == 1) {
        currentFrame = 2;
        _isVisible1 = true;
        _isVisible2 = true;
        _isVisible3 = false;
      } else if (currentFrame == 2) {
        currentFrame = 3;
        _isVisible1 = true;
        _isVisible2 = true;
        _isVisible3 = true;
        _isVisible4 = false;
      } else if (currentFrame == 3) {
        currentFrame = 4;
        _isVisible1 = true;
        _isVisible2 = true;
        _isVisible3 = true;
        _isVisible4 = true;
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
    else if (card == 3)
      return points3;
    else
      return points4;
  }

  GlobalKey _getWidgetKeyForFrame(int card) {
    if (card == 1)
      return key1;
    else if (card == 2)
      return key2;
    else if (card == 3)
      return key3;
    else
      return key4;
  }

  Widget _buildPositionedFrame(BuildContext context, GlobalKey key,
      List<Offset> points, bool isVisible, Color color, int card) {
    return Positioned(
      top: _FRAME_TOP,
      child: Opacity(
        opacity: _getFrameOpacity(card, isVisible),
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

  Widget _buildCustomPaint(BuildContext context, List<Offset> points) {
    return CustomPaint(
      painter: FlipBookPainter(points),
      child: Container(
        height: _SIZE,
        width: _SIZE,
      ),
    );
  }

  double _getFrameOpacity(int card, bool isVisible) {
    if (_isAnimating) {
      if (card == 1)
        return animation1.value;
      else if (card == 2)
        return animation2.value;
      else if (card == 3)
        return animation3.value;
      else
        return animation4.value;
    } else {
      return isVisible ? maxFrameOpacity : 0.0;
    }
  }

  void _clearPoints() {
    points1.clear();
    points2.clear();
    points3.clear();
    points4.clear();
  }

  Future _startAnimation() async {
    try {
      await controller.forward().orCancel;
      await controller.repeat().orCancel;
    } on TickerCanceled {}
  }

  void _buildAnimationController() {
    controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          setState(() {
            _isAnimating = false;
          });
        } else if (status == AnimationStatus.forward) {
          _isAnimating = true;
        }
      });
  }

  void _buildAnimations() {
    // TODO: Generalize/Scale for more than 4 frames
    animation1 = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(
          0.0,
          0.25,
          curve: Curves.linear,
        ),
      ),
    );

    animation2 = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(
          0.25,
          0.50,
          curve: Curves.linear,
        ),
      ),
    );

    animation3 = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(
          0.50,
          0.75,
          curve: Curves.linear,
        ),
      ),
    );

    animation4 = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(
          0.75,
          1.0,
          curve: Curves.linear,
        ),
      ),
    );
  }
}
