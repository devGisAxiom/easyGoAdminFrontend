import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../APIs/apis.dart';

class EditBike {
  Future<bool> editBike({
    required BuildContext context,
    required String bikeId,
    required String name,
    required String vehicleNumber,
    required String description,
    required String rate,
    required String location,
    required String extras,
    required String milage,
    required String geartype,
    required String fueltype,
    required String bhp,
    required String distance,
    required String maxSpeed,
    required String maintainceStatus,
    required String latitude,
    required String longitude,
    required List<Map<String, dynamic>> centersList,
    XFile? newImage,
  }) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(EditBikesAPI));

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      request.fields['b_id'] = bikeId;
      request.fields['name'] = name;
      request.fields['vehicle_number'] = vehicleNumber;
      request.fields['description'] = description;
      request.fields['rate'] = rate;
      request.fields['location'] = location;
      request.fields['extras'] = extras;
      request.fields['milage'] = milage;
      request.fields['geartype'] = geartype;
      request.fields['fueltype'] = fueltype;
      request.fields['bhp'] = bhp;
      request.fields['distance'] = distance;
      request.fields['max_speed'] = maxSpeed;
      request.fields['maintaince_status'] = maintainceStatus;
      request.fields['latitude'] = latitude;
      request.fields['longitude'] = longitude;

      // centers format expected by backend: [{b_id, center_id}]
      final int parsedBikeId = int.tryParse(bikeId) ?? 0;
      List<Map<String, dynamic>> centersPayload = centersList.map((c) => {
        'b_id': parsedBikeId,
        'center_id': c['l_id'],
      }).toList();
      request.fields['bikecenter'] = jsonEncode(centersPayload);

      // Attach new image if provided
      if (newImage != null) {
        Uint8List bytes = await newImage.readAsBytes();
        String filename = newImage.name.isNotEmpty ? newImage.name : 'bike.jpg';
        String? mimeType = lookupMimeType(filename) ?? 'image/jpeg';
        List<String> mimeParts = mimeType.split('/');
        request.files.add(
          http.MultipartFile.fromBytes(
            'image',
            bytes,
            filename: filename,
            contentType: MediaType(mimeParts[0], mimeParts[1]),
          ),
        );
      }

      var streamedResponse = await request.send();
      var responseBody = await streamedResponse.stream.bytesToString();
      var jsonData = jsonDecode(responseBody);

      if (jsonData['result'] == true) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Bike updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
        return true;
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(jsonData['message'] ?? 'Update failed'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return false;
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return false;
    }
  }
}
