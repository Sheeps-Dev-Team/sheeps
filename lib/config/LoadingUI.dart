import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sheeps_app/config/GlobalAsset.dart';
import 'package:sheeps_app/config/SheepsTextStyle.dart';

class DialogBuilder {
  DialogBuilder(this.context);

  final BuildContext context;

  void showLoadingIndicator([String? text]) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black38,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          content: text == null ? null : LoadingIndicator(text: text),
        );
      },
    );
  }

  void hideOpenDialog() {
    Navigator.of(context).pop();
  }
}

// ignore: must_be_immutable
class LoadingIndicator extends StatefulWidget {
  String text;

  LoadingIndicator({Key? key, required this.text}) : super(key: key);

  @override
  _LoadingIndicatorState createState() => _LoadingIndicatorState();
}

class _LoadingIndicatorState extends State<LoadingIndicator> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    _controller = AnimationController(vsync: this, duration: Duration(seconds: 2))..repeat();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var displayedText = widget.text;

    return Container(
        color: Colors.transparent,
        child: Column(mainAxisAlignment: MainAxisAlignment.center, mainAxisSize: MainAxisSize.min, children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (_, child) {
              return Transform(
                alignment: Alignment.center,
                transform: Matrix4.rotationY(_controller.value * 4 * pi),
                child: child,
              );
            },
            child: SvgPicture.asset(svgSheepsLoadingIcon),
          ),
          //_getText(widget.text)
        ]));
  }

  Text _getText(String displayedText) {
    return Text(
      displayedText,
      style: SheepsTextStyle.b4().copyWith(color: Colors.white),
      textAlign: TextAlign.center,
    );
  }
}
