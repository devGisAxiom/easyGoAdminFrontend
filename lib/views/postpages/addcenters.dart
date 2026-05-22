import 'dart:convert';
import 'package:getbike_admin/utils/navigations.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:getbike_admin/APIs/apis.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddBikeCenterDialog extends StatefulWidget {
  const AddBikeCenterDialog({super.key});

  @override
  State<AddBikeCenterDialog> createState() => _AddBikeCenterDialogState();
}

class _AddBikeCenterDialogState extends State<AddBikeCenterDialog> {
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _destrictController = TextEditingController();
  final TextEditingController _latitudeController = TextEditingController();
  final TextEditingController _longitudeController = TextEditingController();

  bool _isLoading = false;

  Future<void> addBikeCenter({
    required String location,
    required String district,
    required String latitude,
    required String longitude,
  }) async {
    final url = Uri.parse(AddBikeCentersAPI); // replace with your API

    final Map<String, String> data = {
      "location": location,
      "district": district,
      "latitude": latitude,
      "longitude": longitude,
    };

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');

      final response = await http.post(
        url,
        headers: token != null ? {'Authorization': 'Bearer $token'} : {},
        body: data,
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        print("Response: $result"); // check response from your PHP
        Navigations.pop(context);
        
      } else {
        print("Server error: ${response.statusCode}");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Add Bike Center"),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTextField(_locationController, "Location"),
            const SizedBox(height: 10),
            _buildTextField(_destrictController, "District"),
            const SizedBox(height: 10),
            _buildTextField(_latitudeController, "Latitude"),
            const SizedBox(height: 10),
            _buildTextField(_longitudeController, "Longitude"),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context), // Cancel closes dialog
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed:
              _isLoading
                  ? null
                  : () {
                    addBikeCenter(
                      location: _locationController.text,
                      district: _destrictController.text,
                      latitude: _latitudeController.text,
                      longitude: _longitudeController.text,
                    );
                  },
          child:
              _isLoading
                  ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                  : const Text("Add"),
        ),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }
}
