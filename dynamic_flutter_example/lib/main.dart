import 'package:dynamic_sdk/dynamic_sdk.dart';
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

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
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
                          ? Column(
                              children: [
                                const LogoutButton(),
                                const SizedBox(height: 24),
                                Text('AUTH TOKEN: $authToken'),
                              ],
                            )
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
