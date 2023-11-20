import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music/utils/utils.dart';
import 'package:window_manager/window_manager.dart';

import 'page/home/controller.dart';

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
        children: [widget.child, sb(width: 20), widget.child]);
  }
}

class WindowsTab extends StatefulWidget {
  const WindowsTab({super.key});

  @override
  State<WindowsTab> createState() => _WindowsTabState();
}

class _WindowsTabState extends State<WindowsTab> with WindowListener {
  bool _isMax = false;
  final homeController = Get.find<HomeController>();

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  void onWindowClose() {}

  @override
  void onWindowMaximize() {
    _isMax = true;
    setState(() {});
  }

  @override
  void onWindowUnmaximize() {
    _isMax = false;
    setState(() {});
  }

  @override
  void onWindowMinimize() {}

  @override
  void onWindowRestore() {}

  @override
  void onWindowResize() {}

  @override
  void onWindowMove() {}

  Widget _button(
      {required IconData icon, double? size, required VoidCallback onPressed}) {
    return GestureDetector(
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: Icon(icon,
              color: const Color.fromRGBO(195, 175, 177, 1), size: size ?? 20),
        ));
  }

  Widget _settingButton() {
    return _button(icon: Icons.settings, onPressed: () {});
  }

  // ignore: unused_element
  Widget _miniButton() {
    return _button(icon: Icons.crop_5_4, onPressed: () {});
  }

  Widget _minButton() {
    return _button(
        icon: Icons.horizontal_rule,
        onPressed: () {
          windowManager.minimize();
        });
  }

  Widget _maxButton() {
    return RotatedBox(
        quarterTurns: 2,
        child: _button(
            icon: _isMax ? Icons.filter_none : Icons.crop_din,
            size: 16,
            onPressed: () async {
              if (_isMax) {
                windowManager.unmaximize();
              } else {
                windowManager.maximize();
              }
              final windowsSize = await windowManager.getSize();
              homeController.windowsWidth.value = windowsSize.width;
            }));
  }

  Widget _closeButton() {
    return _button(
        icon: Icons.close,
        onPressed: () {
          windowManager.destroy();
        });
  }

  Widget _windowsButton() {
    return Row(mainAxisAlignment: MainAxisAlignment.end, children: [
      _settingButton(),
      // _miniButton(),
      _minButton(),
      _maxButton(),
      _closeButton(),
      sb(width: 30)
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return _windowsButton();
  }
}

class WDCustomTrackShape extends RoundedRectSliderTrackShape {
  double addHeight;
  WDCustomTrackShape({this.addHeight = 0});

  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final double trackHeight = sliderTheme.trackHeight ?? 1;
    final double trackLeft = offset.dx;
    final double trackTop =
        offset.dy + (parentBox.size.height - trackHeight) / 2;
    final double trackWidth = parentBox.size.width;
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }
}
