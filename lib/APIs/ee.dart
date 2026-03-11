import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:getbike_admin/controllers/controllers.dart';
import 'package:getbike_admin/models/models.dart';
import 'package:getbike_admin/views/insidepages/map_picker_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:getbike_admin/controllers_post/add_bike.dart';
import 'package:getbike_admin/utils/utilities.dart';

class AddBikeDialog extends StatefulWidget {
  
  const AddBikeDialog({super.key});

  @override
  State<AddBikeDialog> createState() => _AddBikeDialogState();
}

class _AddBikeDialogState extends State<AddBikeDialog> {
  final TextEditingController bikeNameController = TextEditingController();
  final TextEditingController typeController = TextEditingController();
  final TextEditingController rentController = TextEditingController();
  final TextEditingController mileageController = TextEditingController();
  final TextEditingController powerController = TextEditingController();
  final TextEditingController bhpController = TextEditingController();
  final TextEditingController maxSpeedController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController gearTypeController = TextEditingController();
  final TextEditingController fuelTypeController = TextEditingController();
  final TextEditingController maintenanceStatusController = TextEditingController();
  final TextEditingController extrasController = TextEditingController();

  // Location coordinates
  double? latitude;
  double? longitude;

  // Current bike location dropdown
  LocationModel? selectedCurrentLocation;

  // Centers checkbox
  final AllCentersController centersController = AllCentersController();
  List<LocationModel> selectedCenters = [];

  // Image picker
  List<XFile> selectedImages = [];

  @override
  void initState() {
    super.initState();
    _loadCenters();
  }

  Future<void> _loadCenters() async {
    await centersController.fetchdb();
    setState(() {});
  }

  Future<void> pickImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile>? images = await picker.pickMultiImage();
    if (images != null) {
      setState(() {
        selectedImages = images;
      });
    }
  }

  void _toggleCenterSelection(LocationModel center) {
    setState(() {
      if (selectedCenters.contains(center)) {
        selectedCenters.remove(center);
      } else {
        selectedCenters.add(center);
      }
    });
  }

  bool _isCenterSelected(LocationModel center) {
    return selectedCenters.contains(center);
  }

  @override
  void dispose() {
    bikeNameController.dispose();
    typeController.dispose();
    rentController.dispose();
    mileageController.dispose();
    powerController.dispose();
    bhpController.dispose();
    maxSpeedController.dispose();
    descriptionController.dispose();
    gearTypeController.dispose();
    fuelTypeController.dispose();
    maintenanceStatusController.dispose();
    extrasController.dispose();
    super.dispose();
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon,
      {int maxLines = 1, bool readOnly = false, VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: TextFormField(
        controller: controller,
        readOnly: readOnly,
        onTap: onTap,
        maxLines: maxLines,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: primaryColor),
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _buildLocationDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: DropdownButtonFormField<LocationModel>(
        value: selectedCurrentLocation,
        onChanged: (LocationModel? newValue) {
          setState(() {
            selectedCurrentLocation = newValue;
          });
        },
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.location_on, color: primaryColor),
          labelText: "Current Bike Location",
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        items: centersController.centerslocationList.map<DropdownMenuItem<LocationModel>>((LocationModel center) {
          return DropdownMenuItem<LocationModel>(
            value: center,
            child: Text(
              "${center.lLocation ?? 'Unknown Location'} - ${center.lDistrict ?? 'Unknown District'}",
              style: const TextStyle(fontSize: 14),
            ),
          );
        }).toList(),
        validator: (value) {
          if (value == null) {
            return 'Please select a location';
          }
          return null;
        },
      ),
    );
  }

  void _submitBikeData() {
    // Validate required fields
    if (bikeNameController.text.isEmpty ||
        typeController.text.isEmpty ||
        rentController.text.isEmpty ||
        descriptionController.text.isEmpty ||
        selectedCurrentLocation == null ||
        selectedCenters.isEmpty ||
        selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Please fill all required fields, select current location, select at least one service center, and select at least one image'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Prepare centers list for API
    List<Map<String, dynamic>> centersList = selectedCenters.map((center) {
      return {
        'l_id': center.lId,
        'l_location': center.lLocation,
        'l_district': center.lDistrict,
      };
    }).toList();

    // Call the AddBike controller
    AddBike().addBikes(
      context: context, 
      name: bikeNameController.text, 
      ratings: "", 
      review: "", 
      description: descriptionController.text,
      rate: rentController.text, 
      location: selectedCurrentLocation!.lLocation ?? "", 
      extras: extrasController.text, 
      milage: mileageController.text, 
      geartype: gearTypeController.text, 
      fueltype: fuelTypeController.text, 
      bhp: bhpController.text, 
      distance: "", 
      max_speed: powerController.text, 
      maintaince_status: maintenanceStatusController.text, 
      imageFiles: selectedImages, 
      centersList: centersList, 
      latitude: latitude.toString(), 
      longitude: longitude.toString()
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text("Add New Bike", style: TextStyle(fontWeight: FontWeight.bold)),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.75,
        child: SingleChildScrollView(
          child: Column(
            children: [
              // General Info
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      _buildTextField(bikeNameController, "Bike Name", Icons.pedal_bike),
                      _buildTextField(typeController, "Type", Icons.category),
                      _buildTextField(rentController, "Rent/Day", Icons.currency_rupee),
                      _buildLocationDropdown(), // Added location dropdown here
                      _buildTextField(descriptionController, "Description", Icons.description,
                          maxLines: 3),
                      _buildTextField(extrasController, "Extras", Icons.extension, maxLines: 2),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Specifications
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      _buildTextField(mileageController, "Mileage", Icons.speed),
                      _buildTextField(gearTypeController, "Gear Type", Icons.settings),
                      _buildTextField(fuelTypeController, "Fuel Type", Icons.local_gas_station),
                      _buildTextField(powerController, "Power", Icons.bolt),
                      _buildTextField(bhpController, "BHP", Icons.flash_on),
                      _buildTextField(maxSpeedController, "Max Speed", Icons.speed),
                      _buildTextField(maintenanceStatusController, "Maintenance Status",
                          Icons.build_circle),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Centers Section
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text("Service Centers",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(width: 8),
                          Chip(
                            label: Text("${selectedCenters.length} selected",
                                style: const TextStyle(color: Colors.white)),
                            backgroundColor: primaryColor,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (centersController.centerslocationList.isEmpty)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      else
                        Column(
                          children: centersController.centerslocationList.map((center) {
                            return CheckboxListTile(
                              value: _isCenterSelected(center),
                              onChanged: (bool? value) => _toggleCenterSelection(center),
                              title: Text(center.lLocation ?? 'Unknown Location'),
                              subtitle: Text(center.lDistrict ?? 'Unknown District'),
                              controlAffinity: ListTileControlAffinity.leading,
                              dense: true,
                            );
                          }).toList(),
                        ),
                      if (selectedCenters.isNotEmpty)
                        Wrap(
                          spacing: 6,
                          children: selectedCenters.map((center) {
                            return Chip(
                              label: Text("${center.lLocation}",
                                  style: const TextStyle(color: Colors.white)),
                              backgroundColor: primaryColor,
                              onDeleted: () => _toggleCenterSelection(center),
                            );
                          }).toList(),
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Image Picker
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Bike Images",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: pickImages,
                        icon: const Icon(Icons.image),
                        label: Text("Pick Images (${selectedImages.length})", style: smalltextwhite),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (selectedImages.isNotEmpty)
                        SizedBox(
                          height: 100,
                          child: ListView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            scrollDirection: Axis.horizontal,
                            itemCount: selectedImages.length,
                            itemBuilder: (context, index) => FutureBuilder<Uint8List>(
                              future: selectedImages[index].readAsBytes(),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) return const CircularProgressIndicator();
                                return Stack(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Image.memory(snapshot.data!,
                                            width: 90, height: 90, fit: BoxFit.cover),
                                      ),
                                    ),
                                    Positioned(
                                      right: 0,
                                      top: 0,
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            selectedImages.removeAt(index);
                                          });
                                        },
                                        child: const CircleAvatar(
                                          radius: 10,
                                          backgroundColor: Colors.red,
                                          child: Icon(Icons.close, size: 14, color: Colors.white),
                                        ),
                                      ),
                                    )
                                  ],
                                );
                              },
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
          onPressed: _submitBikeData,
          child: Text("Submit", style: smalltextwhite),
        ),
      ],
    );
  }
}