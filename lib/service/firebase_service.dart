import 'dart:convert';
import 'package:http/http.dart' as http;

class FirebaseHttpService {
  final String baseUrl = "https://uasremidi-default-rtdb.firebaseio.com/data";

  // CREATE
  Future<void> createData(Map<String, dynamic> data) async {
    final url = Uri.parse("$baseUrl.json");
    await http.post(url, body: jsonEncode(data));
  }

  // READ
  Future<Map<String, dynamic>> getDataById(String id) async {
    final url = Uri.parse('$baseUrl/$id.json');
    final res = await http.get(url);
    return jsonDecode(res.body);
  }

  Future<Map<String, dynamic>> getAllData() async {
    final url = Uri.parse("$baseUrl.json");
    final response = await http.get(url);
    if (response.statusCode == 200) {
      return jsonDecode(response.body) ?? {};
    } else {
      throw Exception("Failed to load Data");
    }
  }

  // UPDATE
  Future<void> updateData(String id, Map<String, dynamic> updatedData) async {
    final url = Uri.parse("$baseUrl/$id.json");
    await http.patch(url, body: jsonEncode(updatedData));
  }

  // DELETE
  Future<void> deleteData(String id) async {
    final url = Uri.parse("$baseUrl/$id.json");
    await http.delete(url);
  }
}
