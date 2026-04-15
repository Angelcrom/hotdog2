import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BlogPage extends StatefulWidget {
  const BlogPage({super.key});

  @override
  State<BlogPage> createState() => _BlogPageState();
}

class _BlogPageState extends State<BlogPage> {
  final FirebaseFirestore db = FirebaseFirestore.instance;

  List<Map<String, dynamic>> events = [];

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

  Future<void> deleteEvent(String id) async {
    bool confirmDelete = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Delete Event"),
        content: Text("Delete this event?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text("Delete"),
          ),
        ],
      ),
    );

    if (confirmDelete != true) return;

    try {
      await db.collection("events").doc(id).delete();
    } catch (e) {
      print("Error deleting event: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final sortedEvents = [...events];

    sortedEvents.sort((a, b) {
      DateTime dateA = DateTime.parse(a["date"]);
      DateTime dateB = DateTime.parse(b["date"]);
      return dateB.compareTo(dateA);
    });

    return Scaffold(
      appBar: AppBar(title: Text("HOTBOLG"), centerTitle: true),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: sortedEvents.isEmpty
            ? Center(child: Text("No events yet"))
            : ListView.builder(
                itemCount: sortedEvents.length,
                itemBuilder: (context, index) {
                  final event = sortedEvents[index];

                  return Container(
                    margin: EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(blurRadius: 6, color: Colors.black12),
                      ],
                      color: Colors.white,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.all(10),
                          child: Text(
                            event["person"] ?? "",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),

                        /// content
                        Padding(
                          padding: EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Hotdogs: ${event["hotdogsAte"] ?? 0}"),
                              SizedBox(height: 5),
                              Text(event["description"] ?? ""),

                              SizedBox(height: 10),

                              ElevatedButton(
                                onPressed: () => deleteEvent(event["id"]),
                                child: Text("Delete Event"),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}
