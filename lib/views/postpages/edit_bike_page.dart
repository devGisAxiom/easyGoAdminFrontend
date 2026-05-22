import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:getbike_admin/APIs/apis.dart';
import 'package:getbike_admin/controllers/controllers.dart';
import 'package:getbike_admin/controllers_post/edit_bike.dart';
import 'package:getbike_admin/models/models.dart';
import 'package:getbike_admin/utils/utilities.dart';
import 'package:image_picker/image_picker.dart';

class EditBikeDialog extends StatefulWidget {
  final BikeModel bike;
  const EditBikeDialog({super.key, required this.bike});

  @override
  State<EditBikeDialog> createState() => _EditBikeDialogState();
}

class _EditBikeDialogState extends State<EditBikeDialog> {
  late TextEditingController bikeNameController;
  late TextEditingController vehicleNumberController;
  late TextEditingController typeController;
  late TextEditingController rentController;
  late TextEditingController mileageController;
  late TextEditingController powerController;
  late TextEditingController bhpController;
  late TextEditingController maxSpeedController;
  late TextEditingController descriptionController;
  late TextEditingController gearTypeController;
  late TextEditingController fuelTypeController;
  late TextEditingController maintenanceStatusController;
  late TextEditingController extrasController;

  double? latitude;
  double? longitude;
  LocationModel? selectedCurrentLocation;

  final AllCentersController centersController = AllCentersController();
  List<LocationModel> selectedCenters = [];

  // New image picked by user (replaces main image)
  XFile? newImage;
  Uint8List? newImageBytes;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final b = widget.bike;
    bikeNameController = TextEditingController(text: b.bName);
    vehicleNumberController = TextEditingController(text: b.vehicleNumber ?? '');
    typeController = TextEditingController(text: b.bGeartype);
    rentController = TextEditingController(text: b.bRentAmount.toString());
    mileageController = TextEditingController(text: b.bMilage);
    powerController = TextEditingController(text: b.maxSpeed.toString());
    bhpController = TextEditingController(text: b.bBhp.toString());
    maxSpeedController = TextEditingController(text: b.maxSpeed.toString());
    descriptionController = TextEditingController(text: b.bDescription);
    gearTypeController = TextEditingController(text: b.bGeartype);
    fuelTypeController = TextEditingController(text: b.bFueltype);
    maintenanceStatusController = TextEditingController(text: b.maintainceStatus);
    extrasController = TextEditingController(text: b.bExtras);

    latitude = double.tryParse(b.bLatitude);
    longitude = double.tryParse(b.bLongitude);

    _loadCenters();
  }

  Future<void> _loadCenters() async {
    await centersController.fetchdb();
    if (!mounted) return;
    setState(() {
      // Pre-select the current location
      try {
        selectedCurrentLocation = centersController.centerslocationList.firstWhere(
          (c) => c.lLocation == widget.bike.bLocation,
        );
      } catch (_) {
        selectedCurrentLocation = centersController.centerslocationList.isNotEmpty
            ? centersController.centerslocationList.first
            : null;
      }

      // Pre-select assigned centers by matching lId
      final assignedIds = widget.bike.bikeCenters.map((bc) => bc.lId).toSet();
      selectedCenters = centersController.centerslocationList
          .where((c) => assignedIds.contains(c.lId))
          .toList();
    });
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        newImage = image;
        newImageBytes = bytes;
      });
    }
  }

  void _toggleCenter(LocationModel center) {
    setState(() {
      if (selectedCenters.any((c) => c.lId == center.lId)) {
        selectedCenters.removeWhere((c) => c.lId == center.lId);
      } else {
        selectedCenters.add(center);
      }
    });
  }

  bool _isCenterSelected(LocationModel center) {
    return selectedCenters.any((c) => c.lId == center.lId);
  }

  @override
  void dispose() {
    bikeNameController.dispose();
    vehicleNumberController.dispose();
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
      {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: TextFormField(
        controller: controller,
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
        items: centersController.centerslocationList
            .map<DropdownMenuItem<LocationModel>>((LocationModel center) {
          return DropdownMenuItem<LocationModel>(
            value: center,
            child: Text(
              "${center.lLocation} - ${center.lDistrict}",
              style: const TextStyle(fontSize: 14),
            ),
          );
        }).toList(),
      ),
    );
  }

  Future<void> _submitEdit() async {
    if (bikeNameController.text.isEmpty || rentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bike name and rent are required'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    List<Map<String, dynamic>> centersList = selectedCenters.map((c) => {
      'l_id': c.lId,
      'l_location': c.lLocation,
    }).toList();

    final success = await EditBike().editBike(
      context: context,
      bikeId: widget.bike.bId.toString(),
      name: bikeNameController.text,
      vehicleNumber: vehicleNumberController.text,
      description: descriptionController.text,
      rate: rentController.text,
      location: selectedCurrentLocation?.lLocation ?? widget.bike.bLocation,
      extras: extrasController.text,
      milage: mileageController.text,
      geartype: gearTypeController.text,
      fueltype: fuelTypeController.text,
      bhp: bhpController.text,
      distance: widget.bike.distance.toString(),
      maxSpeed: maxSpeedController.text,
      maintainceStatus: maintenanceStatusController.text,
      latitude: selectedCurrentLocation?.lLatitude ?? widget.bike.bLatitude,
      longitude: selectedCurrentLocation?.lLongitude ?? widget.bike.bLongitude,
      centersList: centersList,
      newImage: newImage,
    );

    if (mounted) setState(() => _isLoading = false);

    if (success && mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(Icons.edit, color: primaryColor),
          const SizedBox(width: 8),
          Text(
            "Edit Bike — ${widget.bike.bId}",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
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
                      _buildTextField(vehicleNumberController, "Vehicle Number", Icons.pin),
                      _buildTextField(rentController, "Rent/Day", Icons.currency_rupee),
                      _buildLocationDropdown(),
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
                      _buildTextField(maxSpeedController, "Max Speed", Icons.speed),
                      _buildTextField(bhpController, "BHP", Icons.flash_on),
                      _buildTextField(maintenanceStatusController, "Maintenance Status",
                          Icons.build_circle),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Centers
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
                        const Center(child: CircularProgressIndicator())
                      else
                        Column(
                          children: centersController.centerslocationList.map((center) {
                            return CheckboxListTile(
                              value: _isCenterSelected(center),
                              onChanged: (_) => _toggleCenter(center),
                              title: Text(center.lLocation),
                              subtitle: Text(center.lDistrict),
                              controlAffinity: ListTileControlAffinity.leading,
                              dense: true,
                            );
                          }).toList(),
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Image section
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Bike Image",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      // Show existing images
                      if (widget.bike.bikeimages.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Current images:",
                                style: TextStyle(fontSize: 12, color: Colors.grey)),
                            const SizedBox(height: 6),
                            SizedBox(
                              height: 80,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: widget.bike.bikeimages.length,
                                itemBuilder: (context, index) {
                                  final imgUrl =
                                      "$IMAGEBASEURL${widget.bike.bikeimages[index].imagePath}";
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        imgUrl,
                                        width: 80,
                                        height: 80,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Container(
                                          width: 80,
                                          height: 80,
                                          color: Colors.grey[200],
                                          child: const Icon(Icons.broken_image),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 8),
                          ],
                        ),
                      // Pick new replacement image
                      ElevatedButton.icon(
                        onPressed: _pickImage,
                        icon: const Icon(Icons.image),
                        label: Text(
                          newImage == null ? "Replace Image (optional)" : "Image selected ✓",
                          style: smalltextwhite,
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: newImage == null ? Colors.grey[600] : Colors.green,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                      if (newImageBytes != null) ...[
                        const SizedBox(height: 8),
                        Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.memory(newImageBytes!,
                                  width: 100, height: 100, fit: BoxFit.cover),
                            ),
                            Positioned(
                              right: 0,
                              top: 0,
                              child: GestureDetector(
                                onTap: () => setState(() {
                                  newImage = null;
                                  newImageBytes = null;
                                }),
                                child: const CircleAvatar(
                                  radius: 12,
                                  backgroundColor: Colors.red,
                                  child: Icon(Icons.close, size: 14, color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
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
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _submitEdit,
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                )
              : const Text('Save Changes', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
