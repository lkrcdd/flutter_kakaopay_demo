import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'backend.dart';
import 'dart:async';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: const HomePage());
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<void> onClicked() async {
    url_temp = await postKakao();
    Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) {
      return WebViewPage();
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ElevatedButton(
        onPressed: onClicked,
        child: const Text("press"),
      ),
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
          url_temp = url;
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
    _webViewController.loadRequest(Uri.parse(url_temp!));
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
