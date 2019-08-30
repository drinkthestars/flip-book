import 'dart:ui';

import 'package:flutter/material.dart';

import 'flip_book_painter.dart';

void main() => runApp(new FlipBookApp());

const double _FRAME_TOP = 100;
const double _FRAME_SIZE = 300;
const double _FRAME_STACK_HEIGHT = 500;
const _FRAME_COLOR = Colors.white;
const _FRAMES_ANIMATION_DURATION = 1000;

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
  AnimationController _controller;

  // TODO: Generalize/Scale
  bool _isVisible0 = true;
  bool _isVisible1 = false;
  bool _isVisible2 = false;
  bool _isVisible3 = false;

  int _currentFrame = 0;
  bool _isAnimating = false;

  bool _replayFrames = false;
  double _maxFrameOpacityDuringNoAnimation = 0.7;

  // TODO: Generalize/Scale into lists of List<Offset>
  List<Offset> _points0 = List();
  List<Offset> _points1 = List();
  List<Offset> _points2 = List();
  List<Offset> _points3 = List();

  // TODO: Generalize/Scale
  // For accessing the RenderBox of each frame
  GlobalKey _frame0Key = GlobalKey();
  GlobalKey _frame1Key = GlobalKey();
  GlobalKey _frame2Key = GlobalKey();
  GlobalKey _frame3Key = GlobalKey();

  @override
  void initState() {
    super.initState();
    _buildAnimationController();
  }

  @override
  void dispose() {
    _controller.dispose();
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
                height: _FRAME_STACK_HEIGHT,
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
            _points0.add(null);
            _points1.add(null);
            _points2.add(null);
            _points3.add(null);

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
    _controller.stop();
    _controller.value = 0.0;
    _resetVisibleFrames();
    _isAnimating = false;
  }

  void _resetVisibleFrames() {
    _currentFrame = 0;

    _isVisible0 = true;
    _isVisible1 = false;
    _isVisible2 = false;
    _isVisible3 = false;

    _replayFrames = false;
  }

  Widget _framesStack(BuildContext context) => Stack(
        alignment: Alignment.center,
        children: <Widget>[
          // TODO: Generalize/Scale
          _buildPositionedFrame(
              context: context,
              frameKey: _frame0Key,
              points: _points0,
              isVisible: _isVisible0,
              frameIndex: 0),
          _buildPositionedFrame(
              context: context,
              frameKey: _frame1Key,
              points: _points1,
              isVisible: _isVisible1,
              frameIndex: 1),
          _buildPositionedFrame(
              context: context,
              frameKey: _frame2Key,
              points: _points2,
              isVisible: _isVisible2,
              frameIndex: 2),
          _buildPositionedFrame(
              context: context,
              frameKey: _frame3Key,
              points: _points3,
              isVisible: _isVisible3,
              frameIndex: 3),
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
          _getPointsForFrame(_currentFrame).add(null);
        });
      },
      child: Center(
        child: child,
      ),
    );
  }

  // TODO: Generalize/Scale this
  void _toggleFramesVisibility() {
    if (_replayFrames) {
      if (_currentFrame == 3) {
        _resetVisibleFrames();
      }
    } else {
      if (_currentFrame == 0) {
        _currentFrame = 1;
        _isVisible0 = true;
        _isVisible1 = true;
        _isVisible2 = false;
      } else if (_currentFrame == 1) {
        _currentFrame = 2;
        _isVisible0 = true;
        _isVisible1 = true;
        _isVisible2 = true;
        _isVisible3 = false;
      } else if (_currentFrame == 2) {
        _currentFrame = 3;
        _isVisible0 = true;
        _isVisible1 = true;
        _isVisible2 = true;
        _isVisible3 = true;
        _replayFrames = true;
      }
    }
  }

  void _addPointsForCurrentFrame(Offset globalPosition) {
    final RenderBox renderBox =
        _getWidgetKeyForFrame(_currentFrame).currentContext.findRenderObject();
    final offset = renderBox.globalToLocal(globalPosition);

    _getPointsForFrame(_currentFrame).add(offset);
  }

  List<Offset> _getPointsForFrame(int frameIndex) {
    if (frameIndex == 0)
      return _points0;
    else if (frameIndex == 1)
      return _points1;
    else if (frameIndex == 2)
      return _points2;
    else
      return _points3;
  }

  GlobalKey _getWidgetKeyForFrame(int frameIndex) {
    if (frameIndex == 0)
      return _frame0Key;
    else if (frameIndex == 1)
      return _frame1Key;
    else if (frameIndex == 2)
      return _frame2Key;
    else
      return _frame3Key;
  }

  Widget _buildPositionedFrame(
      {BuildContext context,
      GlobalKey frameKey,
      List<Offset> points,
      bool isVisible,
      int frameIndex}) {
    return Positioned(
      top: _FRAME_TOP,
      child: Opacity(
        opacity: _getFrameOpacity(frameIndex, isVisible),
        child: Container(
          key: frameKey,
          width: _FRAME_SIZE,
          height: _FRAME_SIZE,
          color: _FRAME_COLOR,
          child: FittedBox(
            child: SizedBox(
              child: ClipRect(child: _buildCustomPaint(context, points)),
              width: _FRAME_SIZE,
              height: _FRAME_SIZE,
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
        height: _FRAME_SIZE,
        width: _FRAME_SIZE,
      ),
    );
  }

  double _getFrameOpacity(int frameIndex, bool isVisible) {
    if (_isAnimating) {
      if (frameIndex == 0)
        return _controller.value >= 0.0 ? 1.0 : 0.0;
      else if (frameIndex == 1)
        return _controller.value >= 0.25 ? 1.0 : 0.0;
      else if (frameIndex == 2)
        return _controller.value >= 0.5 ? 1.0 : 0.0;
      else
        return _controller.value >= 0.75 ? 1.0 : 0.0;
    } else {
      return isVisible ? _maxFrameOpacityDuringNoAnimation : 0.0;
    }
  }

  void _clearPoints() {
    _points0.clear();
    _points1.clear();
    _points2.clear();
    _points3.clear();
  }

  Future _startAnimation() async {
    try {
      await _controller.forward().orCancel;
      await _controller.repeat().orCancel;
    } on TickerCanceled {
      print("Frames animation was cancelled!");
    }
  }

  void _buildAnimationController() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: _FRAMES_ANIMATION_DURATION),
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
}
