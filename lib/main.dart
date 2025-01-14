import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // allows fixation on portrait mode
import 'package:provider/provider.dart';

import './providers/session_logic.dart';
import './screens/session.dart';
import './screens/home.dart';

const appName = 'Text and Pen';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return Consumer(
      builder: (context, theme, child) => MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (ctx) => ProviderSessionLogic()),
        ],
        child: MaterialApp(
          title: appName,
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlue),
            useMaterial3: true,
          ),
          home: const Home(),
          routes: {
            Home.routeName: (ctx) => const Home(),
            Session.routeName: (ctx) => const Session(),
          },
        ),
      ),
    );
  }
}
