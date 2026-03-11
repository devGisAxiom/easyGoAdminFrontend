import 'package:flutter/material.dart';
import 'package:getbike_admin/controllers/controllers.dart';
import 'package:getbike_admin/models/models.dart';
import 'package:getbike_admin/utils/navigations.dart';
import 'package:getbike_admin/views/image.dart';
import 'package:getbike_admin/utils/utilities.dart';

class VehiclesList extends StatefulWidget {
  @override
  State<VehiclesList> createState() => _VehiclesListState();
}

class _VehiclesListState extends State<VehiclesList> {
  BikeController _bikeController = BikeController();
  TextEditingController _searchController = TextEditingController();

  List<BikeModel> _allBikes = [];
  List<BikeModel> _filteredBikes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchdata();
    _searchController.addListener(_onSearchChanged);
  }

  Future<void> fetchdata() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _bikeController.fetchBikes();
      // No need to fetch centers if we are not adding/assigning centers

      _allBikes = List.from(_bikeController.bikeList);
      _filteredBikes = List.from(_allBikes);
    } catch (e) {
      print('Error fetching data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredBikes = List.from(_allBikes);
      } else {
        _filteredBikes =
            _allBikes.where((bike) {
              return (bike.bName).toLowerCase().contains(query) ||
                  (bike.bId.toString()).contains(query) ||
                  (bike.bGeartype).toLowerCase().contains(query) ||
                  (bike.bStatus).toLowerCase().contains(query);
            }).toList();
      }
    });
  }

  Widget _buildImageWidget(BikeModel bike) {
    if (bike.bikeimages.isNotEmpty) {
      final imagePath = bike.bikeimages[0].imagePath;
      final imageUrl = "https://lunarsenterprises.com:7006$imagePath";
      return GestureDetector(
        onTap: () {
          Navigations.push(ImageView(image: imagePath), context);
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Image.network(
              imageUrl,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return _buildPlaceholderIcon();
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    value:
                        loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                  ),
                );
              },
            ),
          ),
        ),
      );
    } else {
      return _buildPlaceholderIcon();
    }
  }

  Widget _buildPlaceholderIcon() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Icon(Icons.two_wheeler, color: Colors.grey, size: 24),
    );
  }

  Widget _buildRatingStars(double rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          rating.toStringAsFixed(1),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.amber[700],
          ),
        ),
        SizedBox(width: 4),
        Icon(Icons.star, color: Colors.amber, size: 16),
      ],
    );
  }

  Widget _buildStatusBox(String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      constraints: BoxConstraints(minWidth: 60, maxWidth: 120),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'available':
      case 'active':
        return Colors.green;
      case 'unavailable':
      case 'inactive':
      case 'maintenance':
        return Colors.red;
      case 'booked':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Color _getMaintenanceColor(String status) {
    switch (status.toLowerCase()) {
      case 'good':
      case 'excellent':
      case 'well maintained':
        return Colors.green;
      case 'fair':
        return Colors.orange;
      case 'poor':
      case 'needs maintenance':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _showBikeDetails(BuildContext context, BikeModel bike) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Bike Details'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow('Bike ID', bike.bId.toString()),
                  _buildDetailRow('Bike Name', bike.bName),
                  _buildDetailRow('Type', bike.bGeartype),
                  _buildDetailRow(
                    'Rent/Day',
                    '₹${bike.bRentAmount.toString()}',
                  ),
                  _buildDetailRow(
                    'Mileage/Range',
                    '${bike.bMilage} kmpl', // Label updated to range logic eventually
                  ),
                  _buildDetailRow('Max Speed', '${bike.maxSpeed} km/h'),
                  _buildDetailRow('BHP', bike.bBhp.toString()),
                  _buildDetailRow('Fuel Type', bike.bFueltype),
                  _buildDetailRow('Location', bike.bLocation),
                  _buildDetailRow('Extras', bike.bExtras),
                  _buildDetailRow('Rating', '${bike.bRatings} ⭐'),
                  _buildDetailRow('Maintenance', bike.maintainceStatus),
                  _buildDetailRow('Status', bike.bStatus),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Close'),
              ),
            ],
          ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          Expanded(
            child: Text(value, style: TextStyle(color: Colors.grey[800])),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Vehicle Management',
          style: TextStyle(
            color: primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 2,
        iconTheme: IconThemeData(color: primaryColor),
      ),
      body:
          _isLoading
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                      strokeWidth: 3,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Loading Vehicles...',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                  ],
                ),
              )
              : Column(
                children: [
                  // Search Section (Add button removed)
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              labelText: 'Search Vehicles',
                              hintText: 'Search by name, ID, type, status...',
                              prefixIcon: Icon(
                                Icons.search,
                                color: primaryColor,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.grey[400]!,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: primaryColor,
                                  width: 2,
                                ),
                              ),
                              filled: true,
                              fillColor: Colors.grey[50],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 8),

                  // Results Count
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${_filteredBikes.length} vehicle(s) found',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[600],
                          ),
                        ),
                        if (_searchController.text.isNotEmpty)
                          TextButton(
                            onPressed: () {
                              _searchController.clear();
                            },
                            child: Text(
                              'Clear Search',
                              style: TextStyle(color: primaryColor),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Data Table
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child:
                          _filteredBikes.isEmpty
                              ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.two_wheeler_outlined,
                                      size: 64,
                                      color: Colors.grey[400],
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      _allBikes.isEmpty
                                          ? 'No vehicles found'
                                          : 'No matching vehicles found',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    if (_allBikes.isEmpty)
                                      TextButton(
                                        onPressed: fetchdata,
                                        child: Text(
                                          'Retry',
                                          style: TextStyle(color: primaryColor),
                                        ),
                                      ),
                                  ],
                                ),
                              )
                              : SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.vertical,
                                  child: DataTable(
                                    columnSpacing: 20,
                                    horizontalMargin: 16,
                                    headingRowHeight: 50,
                                    dataRowMinHeight: 70,
                                    dataRowMaxHeight: 70,
                                    headingRowColor: MaterialStateProperty.all(
                                      Colors.grey[50],
                                    ),
                                    headingTextStyle: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[700],
                                      fontSize: 12,
                                    ),
                                    dataTextStyle: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[800],
                                    ),
                                    columns: const [
                                      DataColumn(
                                        label: Text('ID'),
                                        numeric: true,
                                      ),
                                      DataColumn(label: Text('Name')),
                                      DataColumn(label: Text('Image')),
                                      DataColumn(label: Text('Type')),
                                      DataColumn(
                                        label: Text('Rent/Day'),
                                        numeric: true,
                                      ),
                                      DataColumn(
                                        label: Text('Mileage/Range'),
                                        numeric: true,
                                      ),
                                      DataColumn(
                                        label: Text('Speed'),
                                        numeric: true,
                                      ),
                                      DataColumn(label: Text('Extras')),
                                      DataColumn(
                                        label: Text('Rating'),
                                        numeric: true,
                                      ),
                                      DataColumn(label: Text('Maintenance')),
                                      DataColumn(label: Text('Status')),
                                      DataColumn(label: Text('View')),
                                    ],
                                    rows:
                                        _filteredBikes.map((bike) {
                                          return DataRow(
                                            cells: [
                                              DataCell(
                                                SizedBox(
                                                  width: 40,
                                                  child: Text(
                                                    bike.bId.toString(),
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              DataCell(
                                                SizedBox(
                                                  width: 120,
                                                  child: Text(
                                                    bike.bName,
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ),
                                              DataCell(
                                                SizedBox(
                                                  width: 60,
                                                  height: 60,
                                                  child: _buildImageWidget(
                                                    bike,
                                                  ),
                                                ),
                                              ),
                                              DataCell(
                                                SizedBox(
                                                  width: 80,
                                                  child: Text(
                                                    bike.bGeartype,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ),
                                              DataCell(
                                                SizedBox(
                                                  width: 70,
                                                  child: Text(
                                                    '₹${bike.bRentAmount}',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Colors.green[700],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              DataCell(
                                                SizedBox(
                                                  width: 60,
                                                  child: Text(bike.bMilage),
                                                ),
                                              ),
                                              DataCell(
                                                SizedBox(
                                                  width: 60,
                                                  child: Text(
                                                    '${bike.maxSpeed} km/h',
                                                  ),
                                                ),
                                              ),
                                              DataCell(
                                                SizedBox(
                                                  width: 100,
                                                  child: Text(
                                                    bike.bExtras,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ),
                                              DataCell(
                                                SizedBox(
                                                  width: 60,
                                                  child: _buildRatingStars(
                                                    bike.bRatings,
                                                  ),
                                                ),
                                              ),
                                              DataCell(
                                                SizedBox(
                                                  width: 90,
                                                  child: _buildStatusBox(
                                                    bike.maintainceStatus,
                                                    _getMaintenanceColor(
                                                      bike.maintainceStatus,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              DataCell(
                                                SizedBox(
                                                  width: 90,
                                                  child: _buildStatusBox(
                                                    bike.bStatus,
                                                    _getStatusColor(
                                                      bike.bStatus,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              DataCell(
                                                IconButton(
                                                  icon: Icon(
                                                    Icons.visibility,
                                                    size: 18,
                                                  ),
                                                  color: Colors.blue,
                                                  onPressed: () {
                                                    _showBikeDetails(
                                                      context,
                                                      bike,
                                                    );
                                                  },
                                                ),
                                              ),
                                            ],
                                          );
                                        }).toList(),
                                  ),
                                ),
                              ),
                    ),
                  ),
                ],
              ),
    );
  }
}
