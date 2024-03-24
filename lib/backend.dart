import 'dart:ffi';

import 'package:http/http.dart' as http;
import 'dart:convert';

//요청 정보
String secret_key_dev = "DEV2FBC989549F4A740E49122250C4B1D720EB8E";
String url = 'https://open-api.kakaopay.com/online/v1/payment/ready';

// 요청 헤더
Map<String, String> requestHeaders = {
  'Authorization': 'SECRET_KEY $secret_key_dev',
  'Content-Type': 'application/json',
};

//요청 바디
var requestBody = jsonEncode({
  "cid": "TC0ONETIME",
  "partner_order_id": "partner_order_id",
  "partner_user_id": "partner_user_id",
  "item_name": "초코파이",
  "quantity": "1",
  "total_amount": "2200",
  "vat_amount": "200",
  "tax_free_amount": "0",
  "approval_url": "https://naver.com",
  "fail_url": "https://naver.com",
  "cancel_url": "https://naver.com"
});

Future<String> postKakao() async {
  //요청 보내기
  var response = await http.post(
    Uri.parse(url),
    headers: requestHeaders,
    body: requestBody,
  );

  Map<String, dynamic> map_obj;

  //응답 처리
  if (response.statusCode == 200) {
    map_obj = jsonDecode(response.body);
    String url = map_obj['next_redirect_mobile_url'];
    return url;
  } else {
    print('Failed to post data: ${response.statusCode}');
    return "none";
  }
}
