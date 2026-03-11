import 'dart:convert';
import 'package:getbike_admin/views/home.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:getbike_admin/APIs/apis.dart';
class Deletebike {
  void deleteBike(BuildContext context, String bikeId) async {
    print("1");
    var data = {"b_id": bikeId};
    var url = deleteBikeAPI;

    print("2");

    var response = await http.post(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );

    print("3");
    print("sts coed  ::::::${response.statusCode}");
    print("sts bd  ::::::${response.body}");

    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);

      print(jsonData["result"]);

      if (jsonData['result'] == true) {
        if (!context.mounted) return; // ✅ Prevent crash if widget is gone
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(jsonData['message'] ?? "Bike deleted successfully")),
        );

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen(navindex: 6)),
          (Route<dynamic> route) => false,
        );
      }
    } else {
      var jsonData = jsonDecode(response.body);
      if (!context.mounted) return; // ✅ Check again
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(jsonData['message'] ?? "Network error")),
      );
    }
  }
}
