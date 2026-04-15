import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

class HotdogGraph extends StatefulWidget {
  const HotdogGraph({super.key});

  @override
  State<HotdogGraph> createState() => _HotdogGraphState();
}

class _HotdogGraphState extends State<HotdogGraph> {
  final FirebaseFirestore db = FirebaseFirestore.instance;

  List<Map<String, dynamic>> events = [];

  final List<String> people = ["Angel", "Inga", "Jules", "Mia"];

  @override
  void initState() {
    super.initState();

    db.collection("events").snapshots().listen((snapshot) {
      final eventsList = snapshot.docs.map((doc) {
        return {"id": doc.id, ...doc.data()};
      }).toList();

      setState(() {
        events = eventsList;
      });
    });
  }

  List<Map<String, dynamic>> getChartData() {
    return people.map((person) {
      final personEvents = events.where((e) => e["person"] == person).toList();

      final totalHotdogs = personEvents.fold<int>(
        0,
        (sum, e) => sum + ((e["hotdogsAte"] ?? 0) as num).toInt(),
      );

      return {"name": person, "hotdogs": totalHotdogs};
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final data = getChartData();

    final maxY =
        (data.map((e) => e["hotdogs"] as int).fold(0, (a, b) => a > b ? a : b) +
                5)
            .toDouble();

    return Scaffold(
      appBar: AppBar(title: const Text("HOTDOG GRAPH"), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: maxY,

            barTouchData: BarTouchData(enabled: true),

            /// 📊 AXIS CONFIG FIXED
            titlesData: FlTitlesData(
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),

              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    if (value.toInt() >= data.length) {
                      return const SizedBox.shrink();
                    }
                    return Text(data[value.toInt()]["name"]);
                  },
                ),
              ),

              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 45,
                  interval: 1,
                  getTitlesWidget: (value, meta) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: Text(
                        value.toInt().toString(),
                        style: const TextStyle(fontSize: 11),
                      ),
                    );
                  },
                ),
              ),
            ),

            gridData: const FlGridData(drawVerticalLine: false),

            borderData: FlBorderData(show: false),

            /// bars
            barGroups: List.generate(data.length, (index) {
              final hotdogs = data[index]["hotdogs"];

              return BarChartGroupData(
                x: index,
                barRods: [
                  BarChartRodData(
                    toY: hotdogs.toDouble(),
                    width: 20,
                    borderRadius: BorderRadius.circular(6),
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFA62B2B), // ketchup :)
                        Color(0xFFD98D00), // mustard :)
                      ],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                  ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }
}
