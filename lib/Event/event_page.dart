
import 'package:flutter/material.dart';

import 'package:sheeps_app/config/AppConfig.dart';
import 'package:sheeps_app/config/GlobalWidget.dart';
import 'package:sheeps_app/config/SheepsTextStyle.dart';
import 'package:sheeps_app/Event/model/event.dart';


class EventPage extends StatefulWidget {
  final Event event;
  const EventPage({Key? key, required this.event}) : super(key: key);

  @override
  _EventPageState createState() => _EventPageState();
}

class _EventPageState extends State<EventPage> {

  late Event _event;

  @override
  void initState() {
    _event = widget.event;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SheepsAppBar(context, ''),
      body: ListView(
        children: [
          Image.asset(
            _event.img1,
            width: 360 * sizeUnit,
          ),
          Container(
            width: 360 * sizeUnit,
            color: _event.backgroundColor,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () {
                    _event.buttonFunc(context);
                  },
                  child: Container(
                    width: 150 * sizeUnit,
                    height: 48 * sizeUnit,
                    decoration: BoxDecoration(
                      color: _event.buttonColor,
                      borderRadius: BorderRadius.circular(24 * sizeUnit),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          ' 쿠폰 발급 받기',
                          style: SheepsTextStyle.h3().copyWith(color: _event.buttonTextColor),
                        ),
                        SizedBox(width: 4 * sizeUnit),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 24 * sizeUnit,
                          color: _event.buttonTextColor,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Image.asset(
            _event.img2,
            width: 360 * sizeUnit,
          ),
          _event.bottomWidget,
        ],
      ),
    );
  }
}
