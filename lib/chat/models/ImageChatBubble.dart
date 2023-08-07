
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:page_transition/page_transition.dart';
import 'package:sheeps_app/chat/ImageScaleUpPage.dart';
import 'package:sheeps_app/chat/models/ChatGlobal.dart';
import 'package:sheeps_app/config/GlobalAsset.dart';
import 'package:sheeps_app/userdata/GlobalProfile.dart';
import '../models/ChatRecvMessageModel.dart';
import 'package:sheeps_app/config/AppConfig.dart';
import 'package:sheeps_app/config/SheepsTextStyle.dart';
import 'package:sheeps_app/config/constants.dart';

class ImageChatBubble extends StatefulWidget {

  final bool isMe;
  final bool isContinue;
  final ChatRecvMessageModel message;

  ImageChatBubble({@required this.isMe, @required this.isContinue, @required this.message});

  @override
  _ImageChatBubbleState createState() => _ImageChatBubbleState();
}

class _ImageChatBubbleState extends State<ImageChatBubble> {
  double dx = 1;
  double dy = 1;

  double w = 1;
  double h = 1;

  GlobalKey viewKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback(_afterLayout);
  }
  _afterLayout(_){
    getSize();
  }

  getSize() {
    if(viewKey.currentContext != null){
      RenderBox viewBox = viewKey.currentContext.findRenderObject();
      Offset offset = viewBox.localToGlobal(Offset.zero);

      dx = offset.dx;
      dy = offset.dy;

      w = viewBox.size.width;
      h = viewBox.size.height;
    }
  }

  @override
  Widget build(BuildContext context) {

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      key: viewKey,
      children: <Widget>[
        widget.isMe ? _bubbleEndWidget(context) : Container(),  //작성자에 따른 시간 표시
        GestureDetector(
          onTap: () {

            if(widget.message.fileMessage == null) return;

            double alignmentX = ((dx - MediaQuery.of(context).size.width / 2)) / (MediaQuery.of(context).size.width/2);
            double alignmentY = ((MediaQuery.of(context).size.height / 2) - dy) / (MediaQuery.of(context).size.height/2);

            debugPrint(alignmentY.toString());
            debugPrint(alignmentX.toString());

            Navigator.push(context,
              PageTransition(
                type: PageTransitionType.scale,
                alignment: Alignment(alignmentX,-alignmentY),
                child: ImageScaleUpPage(
                  fileString: widget.message.fileMessage,
                  title: GlobalProfile.getUserByUserID(widget.message.from).name,
                ),
              ),
            );
          },
          child:

          widget.message.fileMessage == null?
            Container(
              padding: EdgeInsets.all(8*sizeUnit),
              margin: EdgeInsets.symmetric(horizontal: 4*sizeUnit),
              width: 120*sizeUnit,
              height: 120*sizeUnit,
              decoration: BoxDecoration(
                  color: sheepsColorGrey,
                  borderRadius: BorderRadius.all(Radius.circular(8*sizeUnit)),
                  border: Border.all(
                    width: 1 * sizeUnit,
                    color: sheepsColorGrey
                  )
              ),
              child: Padding(
                padding: EdgeInsets.all(24*sizeUnit),
                child: SvgPicture.asset(
                  'assets/images/Chat/ImageLoadErrorDefault.svg',
                  color: Colors.black54,
                ),
              ),
            )
          :
            Container(
              padding: EdgeInsets.all(8*sizeUnit),
              margin: EdgeInsets.symmetric(horizontal: 4*sizeUnit),
              width: 120*sizeUnit,
              height: 120*sizeUnit,
              decoration: BoxDecoration(
                  color: sheepsColorGrey,
                  borderRadius: BorderRadius.all(Radius.circular(8*sizeUnit)),
                  image: DecorationImage(
                      image: FileImage(File(widget.message.fileMessage)),
                      fit: BoxFit.cover
                  )
              ),
            ),
        ),
        !widget.isMe ? _bubbleEndWidget(context) : Container(), //작성자에 따른 시간 표시
      ],
    );
  }

  Widget _bubbleEndWidget(BuildContext context) {
    return Column(
      mainAxisAlignment: widget.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment: widget.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: <Widget>[
        widget.message.isContinue ? Text(
          setDateAmPm(widget.message.date, false, null),
          style: SheepsTextStyle.b4().copyWith(fontSize: 10*sizeUnit),
        ) : Container(),
      ],
    );
  }
}
