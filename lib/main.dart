import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'backend.dart';
import 'dart:async';
import 'package:provider/provider.dart';

void main() {
  runApp(ChangeNotifierProvider(
    create: (context) => PayInfo(),
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: HomePage());
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<void> onClicked() async {
    await postKakaoForReady();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (BuildContext context) {
        return WebViewPage();
      }),
    );
  }

  Future<void> onClickedv2() async {
    await postKakaoForApprove();
  }

  @override
  Widget build(BuildContext context) {
    String tid = context.watch<PayInfo>().getTid;
    String pgToken = context.watch<PayInfo>().getPgToken;
    return Scaffold(
      body: Column(children: [
        ElevatedButton(
          onPressed: onClicked,
          child: const Text("send ready"),
        ),
        ElevatedButton(
          onPressed: onClickedv2,
          child: const Text("send approve"),
        ),
        Text("tid : $tid"),
        Text("token : $pgToken"),
      ]),
    );
  }
}

class WebViewPage extends StatefulWidget {
  const WebViewPage({super.key});

  @override
  _WebViewPageState createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  late WebViewController _webViewController;
  PayInfo payInfo = PayInfo();

  @override
  void initState() {
    _webViewController = WebViewController();
    _webViewController.setJavaScriptMode(JavaScriptMode.unrestricted);
    _webViewController.setBackgroundColor(const Color(0x00000000));
    _webViewController.setNavigationDelegate(
      NavigationDelegate(
        onProgress: (int progress) {
          debugPrint('[[[log]]] WebView is loading (progress : $progress%)');
        },
        onPageStarted: (String url) {
          debugPrint('[[[log]]] Page started loading: $url');
        },
        onPageFinished: (String url) {
          urlForConvert = url;
          getPgTokenFromUrl();
          print("[[[log]]] tid : $tempTid");
          print("[[[log]]] pgToken : $tempPgToken");
          debugPrint('[[[log]]] Page finished loading: $url');
        },
        onWebResourceError: (WebResourceError error) {},
        onNavigationRequest: (NavigationRequest request) {
          if (request.url.startsWith('https://www.youtube.com/')) {
            return NavigationDecision.prevent;
          }
          return NavigationDecision.navigate;
        },
      ),
    );
    _webViewController.loadRequest(Uri.parse(tempUrl!));
    super.initState();
  }

  Widget favoriteButton() {
    return FloatingActionButton(
      onPressed: () async {
        final String? url = await _webViewController.currentUrl();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Favorited $url')),
          );
        }
      },
      child: const Icon(Icons.favorite),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Flutter WebView example')),
      body: WebViewWidget(controller: _webViewController),
      floatingActionButton: favoriteButton(),
    );
  }
}
