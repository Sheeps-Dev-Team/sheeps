
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:iamport_flutter/Iamport_certification.dart';
import 'package:iamport_flutter/model/certification_data.dart';

class iamportCertificationNamePage extends StatefulWidget {
  String resultPage;
  CertificationData data;

  iamportCertificationNamePage({Key key, @required this.resultPage, @required this.data}) : super(key : key);

  @override
  _iamportCertificationNamePageState createState() => _iamportCertificationNamePageState();
}

class _iamportCertificationNamePageState extends State<iamportCertificationNamePage> {
  String userCode = 'imp10391932';

  @override
  Widget build(BuildContext context) {

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: WillPopScope(
        onWillPop: null,
        child: IamportCertification(
          initialChild: Container(
            child: MediaQuery(
              data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),//사용자 스케일팩터 무시
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/images/LoginReg/iamport-logo.png'),
                    Container(
                      padding: EdgeInsets.fromLTRB(0.0, 30.0, 0.0, 0.0),
                      child: Text('잠시만 기다려주세요...', style: TextStyle(fontSize: 20.0)),
                    ),
                  ],
                ),
              ),
            ),
          ),
          userCode: userCode,
          data: widget.data,
          callback: (Map<String, String> result) async {
            if(result['success'] == 'true'){
              Navigator.pushReplacementNamed(
                context,
                widget.resultPage,
                arguments: result,
              );
            }else{
              Fluttertoast.showToast(msg: "핸드폰 인증에 실패하셨습니다. 다시 시도 해 주세요.", toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.BOTTOM, timeInSecForIosWeb: 1, backgroundColor: Color.fromRGBO(0, 0, 0, 0.51), textColor: Colors.white );
              Get.back();
            }
          },
        ),
      ),
    );
  }
}
