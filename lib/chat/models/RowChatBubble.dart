import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:sheeps_app/chat/models/ChatGlobal.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/ChatRecvMessageModel.dart';
import 'package:sheeps_app/config/AppConfig.dart';
import 'package:sheeps_app/config/SheepsTextStyle.dart';
import 'package:sheeps_app/config/constants.dart';

class RowChatBubble extends StatelessWidget {
  final bool isMe;
  final bool isContinue;
  final ChatRecvMessageModel message;

  RowChatBubble({@required this.isMe, @required this.isContinue, @required this.message});

  @override
  Widget build(BuildContext context) {
    Color boxColor = isMe ? sheepsColorLightGrey : Colors.white;
    bool isHyper = message.message.contains('http://') || message.message.contains('https://') ? true : false;

    int fontSize = message.from == CENTER_MESSAGE ? 10 : 14;
    TextStyle textStyle = isHyper == false ? SheepsTextStyle.b3().copyWith(fontSize: fontSize * sizeUnit) : SheepsTextStyle.b3().copyWith(fontSize: fontSize * sizeUnit, decoration: TextDecoration.underline);

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        isMe ? _bubbleEndWidget(context, isMe) : Container(),  //작성자에 따른 시간 표시
        GestureDetector(
          onLongPress: () {
            Clipboard.setData(new ClipboardData(text : message.message));
            showSheepsToast(context: context, text: '글이 복사 되었습니다.');
          },
          onTap: () {
            if(isHyper == false) return;
            
            String checkPattern = message.message.contains('http://') ? 'http://' : 'https://';
            String subTemp = message.message.substring(message.message.indexOf(checkPattern),message.message.length);
            String checkLastPattern = subTemp.contains(' ') ? ' ' : subTemp.contains('\n') ? '\n' : null;
            String hyperURL = message.message.substring(message.message.indexOf(checkPattern), checkLastPattern == null ? message.message.length : message.message.indexOf(checkLastPattern));

            launch(hyperURL);
          },
          child: Container(
            decoration: BoxDecoration(
              border: isMe ? null : Border.all(color: sheepsColorLightGrey),
              color:  boxColor,
              borderRadius: BorderRadius.circular(12*sizeUnit),
            ),
            constraints: BoxConstraints(
              maxWidth: 240*sizeUnit,
            ),
            child: Padding(
              padding: EdgeInsets.all(8*sizeUnit),
              child: Text(
                message.message,
                style: textStyle,
              ),
            ),
          ),
        ) ,
        !isMe ? _bubbleEndWidget(context, isMe) : Container(), //작성자에 따른 시간 표시
      ],
    );
  }

  Widget _bubbleEndWidget(BuildContext context, bool isMe) {
    String date = isMe ? setDateAmPm(message.date, false, null) + ' ' : ' ' + setDateAmPm(message.date, false, null);
    return Column(
      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: <Widget>[
        message.isContinue ? Text(
          date,
          style: SheepsTextStyle.b4().copyWith(fontSize: 10*sizeUnit),
        ) : Container(),
      ],
    );
  }
}
