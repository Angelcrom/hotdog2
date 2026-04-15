import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HotdogForecast extends StatefulWidget {
  const HotdogForecast({super.key});

  @override
  State<HotdogForecast> createState() => _HotdogForecastState();
}

class _HotdogForecastState extends State<HotdogForecast> {
  List forecast = [];

  @override
  void initState() {
    super.initState();
    fetchForecast();
  }

  Future<void> fetchForecast() async {
    try {
      final url =
          "https://cors-anywhere.herokuapp.com/https://api.openweathermap.org/data/2.5/forecast?lat=46.8721&lon=-113.9940&units=imperial&appid=5f96a4add92e982c603ba85327405c14";

      final res = await http.get(Uri.parse(url));

      if (res.statusCode != 200) {
        throw Exception("Failed request: ${res.statusCode}");
      }

      final data = jsonDecode(res.body);

      final daily = (data["list"] as List)
          .where((item) => item["dt_txt"].toString().contains("12:00:00"))
          .toList();

      setState(() {
        forecast = daily;
      });

      debugPrint("Forecast loaded: ${forecast.length} days");
    } catch (e) {
      debugPrint("Weather error: $e");
    }
  }

  String getHotdogRating(String weather) {
    if (weather.contains("Clear")) return "🌭 perfect day for a hotdog";
    if (weather.contains("Cloud")) return "🌭 good day for a hotdog";
    if (weather.contains("Rain") || weather.contains("Snow")) {
      return "🌭 ok day for a hotdog";
    }
    return "🌭 tread carefully";
  }

  String getWeekday(DateTime date) {
    const days = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
    return days[date.weekday % 7];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("🌭 HOTDOG FORECAST 🌭"),
        centerTitle: true,
      ),

      body: forecast.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),

                      const Text(
                        "Know the best day for hot dogging this week",
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 20),

                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 10,
                        runSpacing: 10,
                        children: forecast.map((day) {
                          final weather = day["weather"][0]["main"];
                          final temp = day["main"]["temp_max"];
                          final date = DateTime.parse(day["dt_txt"]);

                          return Container(
                            width: 140,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  getWeekday(date),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(weather, textAlign: TextAlign.center),
                                Text(
                                  "${temp.round()}°F",
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  getHotdogRating(weather),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
