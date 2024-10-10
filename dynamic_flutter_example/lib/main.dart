import 'dart:typed_data';

import 'package:dynamic_sdk/dynamic_sdk.dart';
import 'package:dynamic_sdk_web3dart/dynamic_sdk_web3dart.dart';
import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  DynamicSDK.init(
    props: ClientProps(
      environmentId: '3e219b76-dcf1-40ab-aad6-652c4dfab4cc',
      appLogoUrl: 'https://demo.dynamic.xyz/favicon-32x32.png',
      appName: 'Dynamic Flutter Demo',
      logLevel: LoggerLevel.debug, //the intended logger level
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: Stack(
        children: [
          // Make sure the SDK is ready before using it
          StreamBuilder<bool?>(
            stream: DynamicSDK.instance.sdk.readyChanges,
            builder: (context, snapshot) {
              final sdkReady = snapshot.data ?? false;
              return sdkReady
                  ? const MyHomePage(title: 'Flutter Demo Home Page')
                  : const SizedBox.shrink();
            },
          ),
          // DynamicSDK widget must be available all the time
          DynamicSDK.instance.dynamicWidget,
        ],
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Column(
                children: [
                  // Listen to auth token changes
                  StreamBuilder<String?>(
                    stream: DynamicSDK.instance.auth.tokenChanges,
                    builder: (context, snapshot) {
                      final authToken = snapshot.data;
                      // Show the auth token when logged in
                      return authToken != null
                          ? Content(authToken: authToken)
                          // Show Dynamic UI for sign in
                          : const LoginButton();
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class Content extends StatefulWidget {
  const Content({
    super.key,
    required this.authToken,
  });

  final String? authToken;

  @override
  State<StatefulWidget> createState() => _ContentState();
}

class _ContentState extends State<Content> {
  late TextEditingController _controller;
  String? _signedMessage, _exception;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController()..text = 'Hello World';
  }

  void _signMessage() async {
    try {
      final requestChannel = RequestChannel(
        DynamicSDK.instance.messageTransport,
      );
      final response = await DynamicCredential.fromWallet(
        requestChannel: requestChannel,
        wallet: DynamicSDK.instance.wallets.userWallets.first,
      ).signMessage(
        payload: Uint8List.fromList(
          _controller.text.trim().codeUnits,
        ),
      );
      setState(() {
        _signedMessage = response;
        _exception = null;
      });
    } catch (e) {
      setState(() {
        _exception = e.toString().split('@')[0];
        _signedMessage = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _controller,
            decoration: InputDecoration(
              counterText: '',
              suffixIcon: Visibility(
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_circle_right_outlined,
                  ),
                  onPressed: _signMessage,
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(_signedMessage ?? _exception ?? ''),
        ),
        const LogoutButton(),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text('AUTH TOKEN: ${widget.authToken}'),
        ),
      ],
    );
  }
}

// Show Dynamic UI for sign in
class LoginButton extends StatelessWidget {
  const LoginButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => DynamicSDK.instance.ui.showAuth(),
      child: const Text('Dynamic Login'),
    );
  }
}

// Headless logout function
class LogoutButton extends StatelessWidget {
  const LogoutButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => DynamicSDK.instance.auth.logout(),
      child: const Text('Logout'),
    );
  }
}
