import 'dart:ui';

import 'package:flutter/material.dart';

import 'flip_book_painter.dart';

void main() => runApp(FlipBookApp());

const _fadeDuration = Duration(milliseconds: 20);
const _frameTop = 100.0;
const _size = 300.0;

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

class _FlipBookPageState extends State<FlipBookPage> {
  int _currentFrame = 3;

  // TODO: Generalize/Scale
  bool _isVisible2 = true;
  bool _isVisible3 = true;
  bool _replayFrames = false;

  // TODO: Generalize/Scale into lists of <Offset>[]
  final points1 = <Offset>[];
  final points2 = <Offset>[];
  final points3 = <Offset>[];

  // TODO: Generalize/Scale
  // For accessing the RenderBox of each frame
  final key3 = GlobalKey();
  final key2 = GlobalKey();
  final key1 = GlobalKey();

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
            // TODO: loop all the frames in sequence
          });
        },
        child: Icon(Icons.play_arrow),
      ),
    );
    final clearFramesButton = Container(
      child: FloatingActionButton(
        onPressed: () {
          setState(() {
            _clear();
            _currentFrame = 3;
            _isVisible3 = true;
            _replayFrames = false;
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
        clearFramesButton,
      ],
    );
  }

  Widget _framesStack(BuildContext context) => Stack(
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

  void _toggleFramesVisibility() {
    if (_replayFrames) {
      if (_currentFrame == 1) {
        _currentFrame = 3;
        _isVisible3 = true;
        _replayFrames = false;
      }
    } else {
      if (_currentFrame == 3) {
        _currentFrame = 2;
        _isVisible2 = true;
        _isVisible3 = false;
      } else if (_currentFrame == 2) {
        _currentFrame = 1;
        _isVisible2 = false;
        _replayFrames = true;
      }
    }
  }

  void _addPointsForCurrentFrame(Offset globalPosition) {
    final RenderBox renderBox =
        _getWidgetKeyForFrame(_currentFrame).currentContext.findRenderObject();
    final offset = renderBox.globalToLocal(globalPosition);

    _getPointsForFrame(_currentFrame)..add(offset);
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

  Widget _buildPositionedFrame(BuildContext context, GlobalKey key,
      List<Offset> points, bool isVisible, Color color) {
    return Positioned(
      top: _frameTop,
      child: AnimatedOpacity(
        opacity: isVisible ? 1 : 0,
        duration: _fadeDuration,
        child: Container(
          key: key,
          width: _size,
          height: _size,
          color: color,
          child: FittedBox(
            child: SizedBox(
              child: ClipRect(child: _buildCustomPaint(context, points)),
              width: _size,
              height: _size,
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
          height: _size,
          width: _size,
        ),
      );

  void _clear() {
    points1.clear();
    points2.clear();
    points3.clear();
  }
}
