import 'dart:convert';
import 'dart:io';
import 'package:getbike_admin/views/home.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:getbike_admin/APIs/apis.dart';
import 'package:getbike_admin/utils/navigations.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> updateBike(
  BuildContext context,
  String bikeId,
  String bikename,
  String description,
  String rate,
  String location,
  String extras,
  String milage,
  String geartype,
  String fueltype,
  String bhp,
  String distance,
  String maxSpeed,
  String maintainceStatus,
  String latitude,
  String longitude,
  List<dynamic> bikecenter,
  List<File> oldimagepath, // Only File objects for old images
  List<File> newimageFiles, // Only File objects for new images
) async {
  print('----------- Bike Details -----------');
  print('Bike ID: $bikeId');
  print('Bike Name: $bikename');
  print('Description: $description');
  print('Rate: $rate');
  print('Location: $location');
  print('Extras: $extras');
  print('Milage: $milage');
  print('Gear Type: $geartype');
  print('Fuel Type: $fueltype');
  print('BHP: $bhp');
  print('Distance: $distance');
  print('Max Speed: $maxSpeed');
  print('Maintenance Status: $maintainceStatus');
  print('Latitude: $latitude');
  print('Longitude: $longitude');
  print('Bike Center: $bikecenter');
  
  print('\n--- Old Image Paths ---');
  for (var file in oldimagepath) {
    print(file.path);
  }

  print('\n--- New Image Files ---');
  for (var file in newimageFiles) {
    print(file.path);
  }

  print('------------------------------------');

  var url = Uri.parse(EditBikesAPI);

  try {

  print("Starting bike update process");

    // Create multipart request
    var request = http.MultipartRequest('POST', url);

    // Add text fields
    request.fields['b_id'] = bikeId;
    request.fields['name'] = bikename;
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

    // Convert bikecenter to JSON string
    print("Bike Center Data: ${jsonEncode(bikecenter)}");
    request.fields['bikecenter'] = jsonEncode(bikecenter);

    // Add old image files - simplified since we only accept File objects
    for (var file in oldimagepath) {
      request.files.add(await http.MultipartFile.fromPath('oildimagepath', file.path));
    }

    // Add new image files
    for (var file in newimageFiles) {
      request.files.add(await http.MultipartFile.fromPath('image', file.path));
    }


    var response = await request.send();
    print("Request sent, waiting for response...");

    var responseBody = await response.stream.bytesToString();
    print("Status Code: ${response.statusCode}");
    print("Response Body: $responseBody");

    if (response.statusCode == 200) {
      var jsonData = jsonDecode(responseBody);
      print("Parsed JSON Data: $jsonData");

      if (jsonData['result'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(jsonData['message'] ?? "Bike updated successfully")),
        );

        Navigations.pushAndRemoveUntil(HomeScreen(navindex: 6), context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(jsonData['message'] ?? "Update failed")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Server error: ${response.statusCode}")),
      );
    }
  } catch (e) {
    print("Error: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Network Error: $e")),
    );
  }
}