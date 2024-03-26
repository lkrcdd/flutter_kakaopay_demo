import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';

//필수! 키값
String secret_key_dev = "DEV00140AF1652428A41AF97A8E95F6C70E7617F";
//요청 url
String urlReady = 'https://open-api.kakaopay.com/online/v1/payment/ready';
String urlApprove = "https://open-api.kakaopay.com/online/v1/payment/approve";

String? urlForConvert;

String? tempUrl;
String? tempTid;
String? tempPgToken;

class PayInfo extends ChangeNotifier {
  //결제 화면 이동 url
  String _next_redirect_pc_url = "";
  //거래 id?
  String _tid = "";
  //단일 거래 건의 토큰값
  String _pgToken = "";

  //getter
  String get getUrl => _next_redirect_pc_url;
  String get getTid => _tid;
  String get getPgToken => _pgToken;

  //setter
  void setUrl(String url) {
    _next_redirect_pc_url = url;
    notifyListeners();
  }

  void setTid(String tid) {
    _tid = tid;
    notifyListeners();
  }

  void setPgToken(String pgToken) {
    _pgToken = pgToken;
    notifyListeners();
  }
}

// 요청 헤더
Map<String, String> requestHeaders = {
  'Authorization': 'SECRET_KEY $secret_key_dev',
  'Content-Type': 'application/json',
};

//요청 바디
var requestBodyForReady = jsonEncode({
  "cid": "TC0ONETIME",
  "partner_order_id": "partner_order_id",
  "partner_user_id": "partner_user_id",
  "item_name": "초코파이",
  "quantity": "1",
  "total_amount": "2200",
  "vat_amount": "200",
  "tax_free_amount": "0",
  "approval_url": "https://localhost:8080",
  "fail_url": "https://localhost:8080",
  "cancel_url": "https://localhost:8080"
});

//ready 요청 전송 함수
Future<void> postKakaoForReady() async {
  //post request
  var response = await http.post(
    Uri.parse(urlReady),
    headers: requestHeaders,
    body: requestBodyForReady,
  );

  //응답 처리
  if (response.statusCode == 200) {
    Map<String, dynamic> tempMap = jsonDecode(response.body);
    //필요한 정보만 저장
    PayInfo payInfo = PayInfo();
    payInfo.setTid(tempMap['tid']);
    payInfo.setUrl(tempMap['next_redirect_pc_url']);
    tempUrl = tempMap['next_redirect_pc_url'];
    tempTid = tempMap['tid'];
    return;
  } else {
    print('[[[log]]] Failed to post data: ${response.statusCode}');
    return;
  }
}

void getPgTokenFromUrl() {
  Uri _uri = Uri.parse(urlForConvert!);
  tempPgToken = _uri.queryParameters['pg_token'];
  print("[[[log]]] pgtoken : $tempPgToken");
}

Future<void> postKakaoForApprove() async {
  print("[[[log]]] tid : $tempTid");
  print("[[[log]]] pgToken : $tempPgToken");
  var requestBodyForApprove = jsonEncode({
    "cid": "TC0ONETIME",
    "tid": "$tempTid",
    "partner_order_id": "partner_order_id",
    "partner_user_id": "partner_user_id",
    "pg_token": "$tempPgToken"
  });

  var response = await http.post(
    Uri.parse(urlApprove),
    headers: requestHeaders,
    body: requestBodyForApprove,
  );

  if (response.statusCode == 200) {
    print("[[[log]]] success!");
  } else {
    print('[[[log]]] Failed to post data: ${response.statusCode}');
  }
}
