import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:image_picker/image_picker.dart'; // XFile for web
import 'package:shared_preferences/shared_preferences.dart';

import '../APIs/apis.dart'; // Make sure AddBikeAPI is defined here

class AddBike {
  Future<void> addBikes({
    required BuildContext context,
    required String name,
    required String vehicle_number,
    required String ratings,
    required String review,
    required String description,
    required String rate,
    required String location,
    required String extras,
    required String milage,
    required String geartype,
    required String fueltype,
    required String bhp,
    required String distance,
    required String max_speed,
    required String maintaince_status,
    required List<dynamic> imageFiles, // File (Mobile) or XFile (Web)
    required List<Map<String, dynamic>> centersList,
    required String latitude,
    required String longitude,
  }) async {

  print("Add Bike Parameters");
  print("name: $name");
  print("ratings: $ratings");
  print("review: $review");
  print("description: $description");
  print("rate: $rate");
  print("location: $location");
  print("extras: $extras");
  print("milage: $milage");
  print("geartype: $geartype");
  print("fueltype: $fueltype");
  print("bhp: $bhp");
  print("distance: $distance");
  print("max_speed: $max_speed");
  print("maintaince_status: $maintaince_status");
  print("latitude: $latitude");
  print("longitude: $longitude");

  print("centersList: $centersList");
  print("imageFiles count: ${imageFiles.length}");

    var url = AddBikeAPI;
    var request = http.MultipartRequest('POST', Uri.parse(url));

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }

List<int> centerids = centersList.map((item) => item['l_id'] as int).toList();
      print(centerids);
    
    request.fields['name'] = name;
    request.fields['vehicle_number'] = vehicle_number;
    request.fields['description'] = description;
    request.fields['rate'] = rate;
    request.fields['location'] = location;
    request.fields['extras'] = extras;
    request.fields['milage'] = milage;
    request.fields['geartype'] = geartype;
    request.fields['fueltype'] = fueltype;
    request.fields['bhp'] = bhp;
    request.fields['distance'] = distance;
    request.fields['max_speed'] = max_speed;
    request.fields['maintaince_status'] = maintaince_status;
    request.fields['latitude'] = latitude;
    request.fields['longitude'] = longitude;
    request.fields['centerList'] = centerids.toString();

//  name, description, rate, location, extras, milage, geartype, fueltype, bhp, distance, 
// max_speed, maintaince_status, centerList, latitude, longitude 
// image:
    // Add images
    for (var imageFile in imageFiles) {
      String? path;
      Uint8List? bytes;
      String filename = "image.jpg";

      if (kIsWeb) {
        // Web: XFile from image_picker
        bytes = await imageFile.readAsBytes();
        filename = imageFile.name;
        path = imageFile.name; // optional
      } else {
        // Mobile/Desktop: File from dart:io
        path = imageFile.path;
        filename = path!.split('/').last;
      }

      final mimeType = lookupMimeType(path ?? '') ?? 'image/jpeg';
      final typeSplit = mimeType.split('/');

      if (kIsWeb && bytes != null) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'image',
            bytes,
            filename: filename,
            contentType: MediaType(typeSplit[0], typeSplit[1]),
          ),
        );
      } else if (path != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'image',
            path,
            contentType: MediaType(typeSplit[0], typeSplit[1]),
          ),
        );
      }
    }

    // Send request
    try {
      var response = await request.send();
      var responseData = await response.stream.bytesToString();

      print("POST URL: $url");
      print("Status Code: ${response.statusCode}");
      print("Response: $responseData");

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(responseData);
        if (jsonData['result'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(jsonData['message'] ?? "Bike added successfully")),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(jsonData['message'] ?? "Something went wrong")),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Server Error: ${response.statusCode}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }
}
