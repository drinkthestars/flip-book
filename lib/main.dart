import 'dart:ui';

import 'package:flutter/material.dart';

import 'flip_book_painter.dart';

void main() => runApp(FlipBookApp());

const _frameTop = 100.0;
const _frameSize = 300.0;
const _frameStackHeight = 500.0;
const _frameColor = Colors.white;
const _framesAnimationDuration = Duration(milliseconds: 1000);

class FlipBookApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Draw and Flip',
      home: FlipBookPage(),
    );
  }
}

class FlipBookPage extends StatefulWidget {
  const FlipBookPage();

  @override
  _FlipBookPageState createState() => _FlipBookPageState();
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

  // TODO: Generalize/Scale into lists of <Offset>[]
  final _points0 = <Offset>[];
  final _points1 = <Offset>[];
  final _points2 = <Offset>[];
  final _points3 = <Offset>[];

  // TODO: Generalize/Scale
  // For accessing the RenderBox of each frame
  final _frame0Key = GlobalKey();
  final _frame1Key = GlobalKey();
  final _frame2Key = GlobalKey();
  final _frame3Key = GlobalKey();

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
    return Scaffold(
      body: _buildGestureDetector(
        context,
        Container(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                height: _frameStackHeight,
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
      top: _frameTop,
      child: Opacity(
        opacity: _getFrameOpacity(frameIndex, isVisible),
        child: Container(
          key: frameKey,
          width: _frameSize,
          height: _frameSize,
          color: _frameColor,
          child: FittedBox(
            child: SizedBox(
              child: ClipRect(child: _buildCustomPaint(context, points)),
              width: _frameSize,
              height: _frameSize,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomPaint(BuildContext context, List<Offset> points) =>
      CustomPaint(
        painter: FlipBookPainter(points),
        child: Container(
          height: _frameSize,
          width: _frameSize,
        ),
      );

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
      duration: _framesAnimationDuration,
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
