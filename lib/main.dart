import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    routes: <String, WidgetBuilder>{
      '/': (BuildContext context) => DynamicLink(),
      '/helloworld': (BuildContext context) => DynamicLinkScreen(),
    },
  ));
}

class DynamicLink extends StatefulWidget {
  @override
  State<DynamicLink> createState() => _DynamicLinkState();
}

class _DynamicLinkState extends State<DynamicLink> {
  bool _isCreateLink = false;
  String? _linkMessage;
  String _textMessage = "To long press the link and copy then click to the link"
      "it will open through browser";

  void initState() {
    super.initState();
    initialCheck();
  }

  Future<void> initialCheck() async {
    FirebaseDynamicLinks.instance.onLink;

    final PendingDynamicLinkData? data =
        await FirebaseDynamicLinks.instance.getInitialLink();

    final Uri deepLink = data!.link;
    if (deepLink != null) {
      Navigator.pushNamed(context, deepLink.path);
    }
  }

  FirebaseDynamicLinks dynamicLinks = FirebaseDynamicLinks.instance;

  Future<void> _createDynamicLink(bool short) async {
    setState(() {
      _isCreateLink = true;
    });
    final DynamicLinkParameters parameters = DynamicLinkParameters(
        link: Uri.parse('https://attiya.page.link/helloworld'),
        uriPrefix: 'https://attiya.page.link',
        androidParameters: AndroidParameters(
          packageName: "com.example.dynamic_links_flutter",
          minimumVersion: 0,
        ),
        // dynamicLinkParametersOptions: DynamicLinkParametersOptions(
        //     shortDynamicLinkPathLength: ShortDynamicLinkPathLength.short),
        socialMetaTagParameters: SocialMetaTagParameters(
            title: "The Title of Dynamic Link",
            description: "The random description of dynamic link"));

    Uri? url;
    if (short) {
      final ShortDynamicLink shortDynamicLink =
          await dynamicLinks.buildShortLink(parameters);
      url = shortDynamicLink.shortUrl;
    } else {
      url = await dynamicLinks.buildLink(parameters);
      // url = await parameters.buildUrl();
    }

    setState(() {
      _linkMessage = url.toString();
      _isCreateLink = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dynamic Links'),
      ),
      body: Center(
        child: Column(
          children: [
            ButtonBar(
              children: [
                RaisedButton(
                  onPressed:
                      !_isCreateLink ? () => _createDynamicLink(false) : null,
                  child: Text('Long Link'),
                ),
                RaisedButton(
                  onPressed:
                      !_isCreateLink ? () => _createDynamicLink(true) : null,
                  child: Text('Short Link'),
                ),
              ],
            ),
            InkWell(
              child: Text(
                _linkMessage ?? '',
                style: TextStyle(color: Colors.blue),
              ),
              onTap: () async {
                if (_linkMessage != null) {
                  await launch(_linkMessage!);
                }
              },
              onLongPress: () {
                Clipboard.setData(ClipboardData(text: _linkMessage));
              },
            ),
            Text(_linkMessage == null ? "" : _textMessage),
          ],
        ),
      ),
    );
  }
}

class DynamicLinkScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dynamic Screen'),
      ),
      body: Text('Hello World'),
    );
  }
}
