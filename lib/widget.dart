import 'dart:async';
import 'package:flutter/material.dart';
import 'package:music/utils/utils.dart';

class MarqueeWidget extends StatefulWidget {
  final Widget child;
  final Axis scrollAxis;
  final double ratioOfBlankToScreen;

  const MarqueeWidget({
    super.key,
    required this.child,
    this.scrollAxis = Axis.horizontal,
    this.ratioOfBlankToScreen = 0.25,
  });

  @override
  State<StatefulWidget> createState() {
    return MarqueeWidgetState();
  }
}

class MarqueeWidgetState extends State<MarqueeWidget>
    with SingleTickerProviderStateMixin {
  late ScrollController scroController;
  late double blankWidth;
  late double blankHeight;
  double position = 0.0;
  late Timer timer;
  final double _moveDistance = 3.0;
  final int _timerRest = 100;
  final GlobalKey _key = GlobalKey();

  @override
  void initState() {
    super.initState();
    scroController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((callback) {
      startTimer();
    });
  }

  void startTimer() {
    double widgetWidth =
        _key.currentContext!.findRenderObject()!.paintBounds.size.width;
    double widgetHeight =
        _key.currentContext!.findRenderObject()!.paintBounds.size.height;

    timer = Timer.periodic(Duration(milliseconds: _timerRest), (timer) {
      double maxScrollExtent = scroController.position.maxScrollExtent;
      double pixels = scroController.position.pixels;
      if (pixels + _moveDistance >= maxScrollExtent) {
        if (widget.scrollAxis == Axis.horizontal) {
          position = (maxScrollExtent - blankWidth - widgetWidth) / 2 +
              pixels -
              maxScrollExtent;
        } else {
          position = (maxScrollExtent - blankHeight - widgetHeight) / 2 +
              pixels -
              maxScrollExtent;
        }
        scroController.jumpTo(position);
      }
      position += _moveDistance;
      scroController.animateTo(position,
          duration: Duration(milliseconds: _timerRest), curve: Curves.linear);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    blankWidth = screenWidth * widget.ratioOfBlankToScreen;
    blankHeight = screenHeight * widget.ratioOfBlankToScreen;
  }

  Widget getCenterChild() {
    if (widget.scrollAxis == Axis.horizontal) {
      return Container(width: blankWidth);
    } else {
      return Container(height: blankHeight);
    }
  }

  @override
  void dispose() {
    super.dispose();
    timer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
        key: _key,
        scrollDirection: widget.scrollAxis,
        controller: scroController,
        physics: const NeverScrollableScrollPhysics(),
        children: <Widget>[widget.child, sb(width: 20), widget.child]);
  }
}
