import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';

import 'pages/calendar_page.dart';
import 'pages/blog_page.dart';
import 'pages/hotdog_graph.dart';
import 'pages/hotdog_forecast.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeTest(),
    );
  }
}

class HomeTest extends StatelessWidget {
  const HomeTest({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          ListTile(
            title: const Text("CalendarPage"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CalendarPage()),
              );
            },
          ),
          ListTile(
            title: const Text("BlogPage"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BlogPage()),
              );
            },
          ),
          ListTile(
            title: const Text("HotdogGraph"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HotdogGraph()),
              );
            },
          ),
          ListTile(
            title: const Text("HotdogForecast"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HotdogForecast()),
              );
            },
          ),
        ],
      ),
    );
  }
}
