import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:getbike_admin/APIs/apis.dart';
import 'package:getbike_admin/utils/navigations.dart';
import 'package:getbike_admin/views/home.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

void updatebookingstatus(
  BuildContext context,
  String user_id,
  String status,
  String booking_id,
  int navindex,
) async {
  print("====================================");
  print("🔄 Update Booking Status");
  print("====================================");
  print("Booking ID: $booking_id");
  print("User ID: $user_id");
  print("Status: $status");
  print("Navigation Index: $navindex");

  var data = {"b_id": booking_id, "b_status": status, "b_u_id": user_id};

  var url = BookingStatusAPI;

  // Get token from SharedPreferences
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString("token");

  if (token == null || token.isEmpty) {
    print("❌ ERROR: No token found in SharedPreferences!");
    print("Cannot proceed without authentication token");

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Authentication required. Please login again."),
        backgroundColor: Colors.red,
      ),
    );

    // Optionally navigate to login page
    // Navigations.pushAndRemoveUntil(const SignInPage(), context);
    return;
  }

  print("🔑 Token found: $token.");
  try {
    print("🌐 Sending request to: $url");
    print("📤 Request data: $data");
    print("📤 Headers: Authorization: Bearer $token");

    var response = await http.post(
      Uri.parse(url),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(data),
    );

    print("📥 Response status code: ${response.statusCode}");
    print("📥 Response body: ${response.body}");

    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);

      if (jsonData['result'] == true) {
        print("✅ Booking status updated successfully");
        print("Message: ${jsonData['message']}");

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(jsonData["message"] ?? "Status updated successfully"),
            backgroundColor: Colors.green,
          ),
        );

        Navigations.pushAndRemoveUntil(HomeScreen(navindex: navindex), context);
      } else {
        print("❌ API returned false result");
        print("Message: ${jsonData['message']}");

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(jsonData["message"] ?? "Failed to update status"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else if (response.statusCode == 401) {
      print("🔒 Unauthorized - Token might be expired or invalid");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Session expired. Please login again."),
          backgroundColor: Colors.red,
        ),
      );

      // Optionally navigate to login page
      // Navigations.pushAndRemoveUntil(const SignInPage(), context);
    } else {
      print("❌ Server error: ${response.statusCode}");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Server error: ${response.statusCode}"),
          backgroundColor: Colors.red,
        ),
      );
    }
  } catch (e) {
    print("❌ Network error: $e");

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Network error: ${e.toString()}"),
        backgroundColor: Colors.red,
      ),
    );
  }
}
