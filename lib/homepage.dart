import 'package:flutter/material.dart';
import 'package:uasremidi/service/firebase_service.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseHttpService _service = FirebaseHttpService();
  Map<String, dynamic> _data = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  void fetchData() async {
    try {
      final allData = await _service.getAllData();
      setState(() {
        _data = allData;
        _loading = false;
      });
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _loading
            ? Center(child: CircularProgressIndicator())
            : _data.isEmpty
                ? Center(child: Text("Belum ada data"))
                : ListView(
                    padding: EdgeInsets.all(16),
                    children: _data.entries.map((entry) {
                      final item = entry.value;
                      return kontenbesar(context, item, entry.key);
                    }).toList(),
                  ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/add');
        },
        backgroundColor: Color(0xFF201E43),
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget kontenbesar(BuildContext context, Map item, String id) {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.pushNamed(context, '/update/${id}');
        if (result == 'updated') {
          fetchData();
        }
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8),
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Color(0xFF508C9B),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: item['imageUrl'] != null && item['imageUrl'] != ""
                  ? Image.network(item['imageUrl'], width: 84, height: 80, fit: BoxFit.cover)
                  : Image.asset('assets/image/pp.jpg', width: 84, height: 80, fit: BoxFit.cover),
            ),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['title'] ?? '',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white),
                  ),
                  SizedBox(height: 5),
                  Text(
                    item['jenis'] ?? '',
                    style: TextStyle(fontSize: 12, color: Colors.white),
                  ),
                  SizedBox(height: 5),
                  Text(
                    "Tanggal: ${item['tanggal'] ?? ''}",
                    style: TextStyle(fontSize: 12, color: Colors.white),
                  ),
                  SizedBox(height: 5),
                  Text(
                    "Rp. ${item['jumlah'] ?? '0'}",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
