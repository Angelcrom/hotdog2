import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'pages/calendar_page.dart';
import 'pages/hotdog_graph.dart';
import 'pages/blog_page.dart';
import 'pages/hotdog_forecast.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hotdog Log',
      theme: ThemeData(
        scaffoldBackgroundColor: Color(0xFFFFF9E1),
        primaryColor: Color(0xFFA62B2B),
      ),
      home: Scaffold(body: Center(child: Text("HELLO"))),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Widget currentPage = CalendarPage();

  void navigateTo(Widget page) {
    setState(() {
      currentPage = page;
    });
    Navigator.pop(context); // close drawer
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "HOTDOG LOG",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color(0xFFA62B2B),
      ),

      /// 🍔 MENU (your dropdown → drawer)
      drawer: Drawer(
        child: Container(
          color: Color(0xFFDFBB38),
          child: ListView(
            children: [
              DrawerHeader(child: Text("Menu", style: TextStyle(fontSize: 24))),

              ListTile(
                title: Text("Calendar"),
                onTap: () => navigateTo(CalendarPage()),
              ),

              ListTile(
                title: Text("Hotdog Graph"),
                onTap: () => navigateTo(HotdogGraph()),
              ),

              ListTile(
                title: Text("Blog"),
                onTap: () => navigateTo(BlogPage()),
              ),

              ListTile(
                title: Text("Hotdog Forecast"),
                onTap: () => navigateTo(HotdogForecast()),
              ),
            ],
          ),
        ),
      ),

      /// 📄 PAGE CONTENT (like Routes)
      body: currentPage,
    );
  }
}
