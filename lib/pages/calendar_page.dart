import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  final FirebaseFirestore db = FirebaseFirestore.instance;

  List<Map<String, dynamic>> events = [];

  bool showModal = false;
  DateTime? selectedDate;

  String hotdogsAte = "";
  String selectedPerson = "";
  String description = "";

  final String hotdogIcon =
      "https://cdn11.bigcommerce.com/s-c9a80/images/stencil/original/products/18799/71070/Hot_Dog_Stinky_Sticker__29902.1709871365.jpg";

  @override
  void initState() {
    super.initState();

    db.collection("events").snapshots().listen((snapshot) {
      final eventsList = snapshot.docs.map((doc) {
        return {"id": doc.id, ...doc.data(), "iconUrl": hotdogIcon};
      }).toList();

      setState(() {
        events = eventsList;
      });
    });
  }

  void handleDateClick(DateTime date) {
    setState(() {
      selectedDate = date;
      showModal = true;
    });
  }

  Future<void> handleSubmit() async {
    debugPrint("SUBMIT CLICKED");

    if (selectedDate == null || selectedPerson.isEmpty) {
      debugPrint("Missing required fields");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a person and date")),
      );
      return;
    }

    final newEvent = {
      "person": selectedPerson,
      "date": selectedDate!.toIso8601String(),
      "hotdogsAte": int.tryParse(hotdogsAte) ?? 0,
      "description": description,
      "iconUrl": hotdogIcon,
    };

    try {
      final docRef = await db.collection("events").add(newEvent);

      debugPrint("Event added: ${docRef.id}");

      setState(() {
        events.add({"id": docRef.id, ...newEvent});
        hotdogsAte = "";
        description = "";
        selectedPerson = "";
        showModal = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Hotdog logged 🌭")));
    } catch (e) {
      debugPrint("Error adding event: $e");

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  List<dynamic> getEventsForDay(DateTime day) {
    return events.where((event) {
      final dateStr = event["date"] ?? "";
      final eventDate = DateTime.tryParse(dateStr);

      if (eventDate == null) return false;

      return isSameDay(eventDate, day);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("🌭 HOTDOG CALENDAR 🌭"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          const Text("Race to 100 hotdogs in 2026"),
          const Text("Click on a date to log your dog"),
          const SizedBox(height: 20),

          /// calendar
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: DateTime.now(),
            onDaySelected: (selectedDay, focusedDay) {
              handleDateClick(selectedDay);
            },
            eventLoader: getEventsForDay,
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, date, events) {
                if (events.isEmpty) return null;

                return Center(
                  child: Image.network(hotdogIcon, width: 30, height: 30),
                );
              },
            ),
          ),
        ],
      ),

      /// modal
      floatingActionButton: showModal
          ? GestureDetector(
              onTap: () {
                setState(() {
                  showModal = false;
                });
              },
              child: Container(
                color: Colors.black54,
                child: Center(
                  child: GestureDetector(
                    onTap: () {},
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      width: 300,
                      color: Colors.white,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            "Log Hotdogs",
                            style: TextStyle(fontSize: 18),
                          ),

                          DropdownButton<String>(
                            value: selectedPerson.isEmpty
                                ? null
                                : selectedPerson,
                            hint: const Text("Select a person"),
                            isExpanded: true,
                            items: ["Angel", "Inga", "Jules", "Mia"]
                                .map(
                                  (person) => DropdownMenuItem(
                                    value: person,
                                    child: Text(person),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedPerson = value!;
                              });
                            },
                          ),

                          TextField(
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: "Number of Hotdogs",
                            ),
                            onChanged: (value) {
                              hotdogsAte = value;
                            },
                          ),

                          TextField(
                            decoration: const InputDecoration(
                              labelText: "Description",
                            ),
                            onChanged: (value) {
                              description = value;
                            },
                          ),

                          const SizedBox(height: 10),
                          Text("Date: ${selectedDate?.toString() ?? ""}"),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ElevatedButton(
                                onPressed: handleSubmit,
                                child: const Text("Add Event"),
                              ),
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    showModal = false;
                                  });
                                },
                                child: const Text("Cancel"),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            )
          : null,
    );
  }
}
