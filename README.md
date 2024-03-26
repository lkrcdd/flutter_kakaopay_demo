# flutter_kakaopay_demo

### 스킵 항목
시작하기 - API 공통 가이드 외 스킵
로그인 스킵
송금 스킵
기술 스킵

### 시작하기 - API 공통 가이드 (에러코드, 쿼터 스킵)
1. 사전 준비
- 어플 등록 -> secret key dev 사용 -> OAuth 과정 없이 API 호출
- 카카오페이에서 제공하는 OPEN API는 REST API 기반으로 HTTP 요청을 보낼 수 있는 환경이라면 어디서든 이용 가능합니다.
클라이언트에서 서버(카카오)로, 또는 서버에서 서버(카카오)로 요청을 보낼 수 있습니다.

2. REST API
- API 호출시 클라이언트에서는 HTTP 요청 메시지 형식에 따라 다음과 같은 정보를 포함해야 합니다.
Request-Line : {HTTP Method, Request URI, 프로토콜 정보} 명시 -> Method : get, post, delete
Request-Header : 카카오페이에서 제공하는 제품의 API 요청 파라미터 형식이나 인증 등 부가 정보를 전달 시 헤더에 작성 -> secret key, client id 등
HTTP Message : HTTP Method 방식에 따라 필요한 정보 메시지 내용을 전달합니다.
- 카카오페이 API 호출에 대한 응답(Response) -> JSON
- 호스트 도메인은 open-api.kakaopay.com 으로 호출해야 합니다. *개발환경은 지원하고 있지 않습니다.*

3. Authorization
- 카카오페이 API는 사용자 로그인 방식과 앱 시크릿 키 방식의 API로 구분됩니다.
- 사용자 로그인 방식은 토큰 발급
- 앱 시크릿 키 방식의 API는 "로그인 과정 없이 직접 호출이 가능한 경우" 사용
- 테스트 환경은 <auth-scheme> 영역에 DEV_SECRET_KEY 혹은 SECRET_KEY 고정 값으로 명시하고, <authorization-parameters>는 발급받은 Secret Key(dev)를 전달해야 합니다.
- [API 공통 가이드 -> API 종류]에 지원 함수들 명시되어있음
https://developers.kakaopay.com/docs/getting-started/api-common-guide/api-type

### 결제
- Secret key와 CID를 통해 API를 호출합니다.
1. TID	결제 건에 대한 고유번호. 결제 준비 API가 성공적으로 호출되면 발급.
2. AID	승인/취소/정기 결제 API 호출에 대한 고유번호. 각 API 호출 성공시 발급.
3. SID	정기 결제에 사용되는 고유번호. 정기 결제 1회차 프로세스가 완료되면 발급. 2회차 정기 결제부터는 SID를 이용해 결제 요청.

- 결제 프로세스
1. 결제 준비
가맹점 코드(CID), 가맹점이 부여한 주문번호(partner_order_id), 상품 총액(total_amount) 등 상세 정보로 결제 준비(ready) API를 호출합니다.
응답이 오면 요청한 결제와 TID를 매핑(Mapping)하여 저장하고, 추후 결제 승인 API 호출 및 거래상태조회, 대사 작업에 사용합니다.
MobileWeb/APP : 응답으로 받은 next_redirect_mobile_url, next_redirect_app_url 값으로 결제 대기 화면을 띄우면 브릿지페이지와 함께 결제 수단으로 전환됩니다.

2. 사용자 결제 수단 전환
모바일/앱은 카카오페이 결제 수단으로 자동전환 됩니다.
전환되는 과정의 브릿지페이지에서 아래와 같은 동작이 발생할수 있습니다.
요청 취소 : cancel_url로 redirect
요청 유효 시간(15분) 경과 : fail_url로 redirect

3. 결제 수단 선택 및 인증
카카오페이 결제 수단 선택과 인증이 이뤄지게 됩니다. 목업(테스트)의 경우 인증(비밀번호,생체인증)은 Skip 됩니다.

4. 인증 완료 Redirect
사용자의 인증이 완료가 되었음을 가맹점페이지로 Redirect 응답되는 단계입니다.
Redirect시 approval_url에 쿼리스트링(Query string)으로 pg_token을 전달드립니다.
요청 성공 : approval_url로 redirect
요청 취소/실패 : "2. 사용자 결제 수단 전환" 참고

5. 결제 승인(approve)
결제 필수값(TID, pg_token)으로 카카오페이 서버에 승인요청하여 최종적인 결제완료 처리를 합니다.
승인응답을 받으면 결제 결과를 저장하고 제휴사의 내부처리후 사용자에게 결제 완료 화면을 보여줍니다.
승인완료시 사용자에게 결제완료 메시지가 발송됩니다.

- 단건 결제, 정기 결제, 결제 취소 만 보면 될듯
* 참고하기 - 타임아웃 등이 document

- 단건 결제
1. ready
- 카카오페이 결제를 시작하기 위해 결제정보를 카카오페이 서버에 전달하고 결제 고유번호(TID)와 URL을 응답받는 단계입니다.
- Secret key를 헤더에 담아 파라미터 값들과 함께 POST로 요청합니다.
- 요청이 성공하면 응답 바디에 JSON 객체로 다음 단계 진행을 위한 값들을 받습니다.
- 서버(Server)는 tid를 저장하고, 클라이언트는 사용자 환경에 맞는 URL로 리다이렉트(redirect)합니다.

### 개발도구
REST API in flutter

ready 시
모바일 웹 환경 : 실패 리다이렉트? -> 웹뷰 중복? or 카톡앱이없어서?
웹 환경 : qr나옴 -> 테스트 진행
모바일 앱 환경 : 실패 리다이렉트 -> 카톡앱이 없어서 그런듯?