import 'package:flutter/material.dart';
import 'package:getbike_admin/controllers/controllers.dart';
import 'package:getbike_admin/controllers_post/updatestatus.dart';
import 'package:getbike_admin/models/models.dart';
import 'package:getbike_admin/utils/navigations.dart';
import 'package:getbike_admin/utils/utilities.dart';
import 'package:getbike_admin/views/image.dart';

class BikesOnride extends StatefulWidget {
  @override
  State<BikesOnride> createState() => _BikesOnrideState();
}

class _BikesOnrideState extends State<BikesOnride> {
  final MyBookingController _bookingController = MyBookingController();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _horizontalScrollController = ScrollController();
  final ScrollController _verticalScrollController = ScrollController();

  List<BookingModel> _allBikes = [];
  List<BookingModel> _filteredBikes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchdata();
    _searchController.addListener(() {
      _onSearchChanged(_searchController.text);
    });
  }

  Future<void> fetchdata() async {
    setState(() => _isLoading = true);
    try {
      await _bookingController.fetchBikes();
      _allBikes = List.from(_bookingController.onrideList);
      _filteredBikes = List.from(_allBikes);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading data: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredBikes = List.from(_allBikes);
      } else {
        final q = query.toLowerCase();
        _filteredBikes =
            _allBikes.where((bike) {
              return (bike.bId?.toString() ?? '').contains(q) ||
                  (bike.uName ?? '').toLowerCase().contains(q) ||
                  (bike.bPickupLocation ?? '').toLowerCase().contains(q) ||
                  (bike.bDropLocation ?? '').toLowerCase().contains(q);
            }).toList();
      }
    });
  }

  // Parse date from string
  DateTime? _parseDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return null;
    try {
      return DateTime.parse(dateString.split(' ')[0]);
    } catch (e) {
      return null;
    }
  }

  // Parse date-time from string
  DateTime? _parseDateTime(String? dateTimeString) {
    if (dateTimeString == null || dateTimeString.isEmpty) return null;
    try {
      return DateTime.parse(dateTimeString);
    } catch (e) {
      return null;
    }
  }

  // Format date to "7th Jan 2026"
  String _formatDate(DateTime? date) {
    if (date == null) return '-';

    try {
      final day = date.day.toString().padLeft(2, '0');
      final month = date.month.toString().padLeft(2, '0');
      final year = date.year;

      return '$day - $month - $year';
    } catch (e) {
      return date.toString();
    }
  }

  // Format time to "1:00 PM"
  String _formatTime(DateTime? dateTime) {
    if (dateTime == null) return '-';

    try {
      final hour = dateTime.hour % 12;
      final displayHour = (hour == 0 ? 12 : hour).toString().padLeft(2, '0');
      final minute = dateTime.minute.toString().padLeft(2, '0');
      final period = dateTime.hour < 12 ? 'AM' : 'PM';

      return '$displayHour : $minute $period';
    } catch (e) {
      return dateTime.toString();
    }
  }

  // Combined date and time format
  String _formatDateTime(String? dateString, String? timeString) {
    try {
      final date = _parseDate(dateString);
      final dateTime = _parseDateTime(timeString);

      if (date != null && dateTime != null) {
        return '${_formatDate(date)} ${_formatTime(dateTime)}';
      } else if (date != null) {
        return _formatDate(date);
      } else if (dateTime != null) {
        return '${_formatDate(dateTime)} ${_formatTime(dateTime)}';
      }
    } catch (e) {
      print('Error formatting date-time: $e');
    }
    return '-';
  }

  int? _calculateDays(BookingModel booking) {
    try {
      final pickupDate = _parseDate(booking.bPickupDate.toString());
      final dropDate = _parseDate(booking.bDropDate.toString());

      if (pickupDate != null && dropDate != null) {
        final difference = dropDate.difference(pickupDate).inDays;
        return difference > 0 ? difference : 1;
      }
    } catch (e) {
      print('Error calculating days: $e');
    }
    return 1;
  }

  // Check if ride is overdue
  bool _isOverdue(BookingModel booking) {
    try {
      final dropDate = booking.bDropDate;
      final dropTime = booking.bDropTime;

      final dropDateTime = DateTime(
        dropDate.year,
        dropDate.month,
        dropDate.day,
        dropTime.hour,
        dropTime.minute,
      );

      if (dropDateTime != null) {
        return DateTime.now().isAfter(dropDateTime);
      }
    } catch (e) {
      print('Error checking overdue: $e');
    }
    return false;
  }

  // Combine date and time
  DateTime? _combineDateAndTime(DateTime? date, String? timeString) {
    if (date == null || timeString == null || timeString.isEmpty) return null;

    try {
      final timeParts = timeString.split(':');
      if (timeParts.length < 2) return null;

      final hour = int.tryParse(timeParts[0]) ?? 0;
      final minute = int.tryParse(timeParts[1]) ?? 0;

      return DateTime(date.year, date.month, date.day, hour, minute);
    } catch (e) {
      return null;
    }
  }

  // Get full image URL
  String _getFullImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) return '';

    if (imagePath.startsWith('http')) {
      return imagePath;
    }

    String baseUrl = "https://lunarsenterprises.com:7006";

    if (imagePath.startsWith('/')) {
      return '$baseUrl$imagePath';
    } else {
      return '$baseUrl/$imagePath';
    }
  }

  Widget _buildDocumentWidget(String? documentUrl, String documentType) {
    final fullUrl = _getFullImageUrl(documentUrl);

    if (documentUrl == null || documentUrl.isEmpty) {
      return _buildPlaceholderIcon(Icons.document_scanner, 'No $documentType');
    }

    return GestureDetector(
      onTap: () {
        Navigations.push(ImageView(image: fullUrl), context);
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Image.network(
            fullUrl,
            width: 50,
            height: 50,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return _buildPlaceholderIcon(
                Icons.broken_image,
                'Error loading image',
              );
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
  }

  Widget _buildPlaceholderIcon(IconData icon, String tooltip) {
    return Tooltip(
      message: tooltip,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Icon(icon, color: Colors.grey, size: 24),
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'on ride':
      case 'onride':
        return Colors.blue;
      case 'pending':
        return Colors.orange;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _markRideCompleted(BookingModel booking) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Confirm Ride Completion'),
            content: Text(
              'Are you sure you want to mark this ride as completed?\n\n'
              'User: ${booking.uName ?? 'N/A'}\n'
              'Booking ID: ${booking.bId ?? 'N/A'}',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel', style: smalltextblk),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  if (booking.bUId != null && booking.bId != null) {
                    updatebookingstatus(
                      context,
                      booking.bUId.toString(),
                      "completed",
                      booking.bId.toString(),
                      2,
                    );
                    fetchdata();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: Missing booking information'),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: Text('Confirm Completed', style: smalltextwhite),
              ),
            ],
          ),
    );
  }

  // Show all documents
  void _showAllDocuments(BookingModel booking) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.folder_open, color: primaryColor),
                SizedBox(width: 8),
                Text('All Documents'),
              ],
            ),
            content: Container(
              width: double.maxFinite,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Booking ID: ${booking.bId ?? 'N/A'}',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'User: ${booking.uName ?? 'N/A'}',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    SizedBox(height: 20),
                    _buildDocumentSection(
                      'User Selfie',
                      booking.bSelfie,
                      Icons.photo_camera,
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Close', style: TextStyle(color: primaryColor)),
              ),
            ],
          ),
    );
  }

  Widget _buildDocumentSection(
    String title,
    String? documentUrl,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: Colors.grey[600]),
              SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
            ],
          ),
          SizedBox(height: 8),
          _buildDocumentWidget(documentUrl, title),
          SizedBox(height: 8),
          if (documentUrl != null && documentUrl.isNotEmpty)
            Text(
              _getFileName(documentUrl),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          Divider(),
        ],
      ),
    );
  }

  String _getFileName(String url) {
    try {
      return url.split('/').last;
    } catch (e) {
      return 'Document';
    }
  }

  // Show full text dialog
  void _showFullTextDialog(String title, String content) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Row(
              children: [
                Icon(
                  title.contains('Location')
                      ? Icons.location_on
                      : Icons.text_fields,
                  color: primaryColor,
                ),
                SizedBox(width: 8),
                Text(title),
              ],
            ),
            content: SingleChildScrollView(
              child: Text(content, style: TextStyle(fontSize: 14)),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Close', style: TextStyle(color: primaryColor)),
              ),
            ],
          ),
    );
  }

  // Show date-time dialog
  void _showDateTimeDialog(String title, String? date, String? time) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.calendar_today, color: primaryColor),
                SizedBox(width: 8),
                Text(title),
              ],
            ),
            content: Container(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _formatDateTime(date, time),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Breakdown:',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: 8),
                  if (date != null && date.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Date:',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          _formatDate(_parseDate(date)) ?? '-',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 8),
                      ],
                    ),
                  if (time != null && time.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Time:',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          time,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 8),
                      ],
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Close', style: TextStyle(color: primaryColor)),
              ),
            ],
          ),
    );
  }

  // Build data columns
  List<DataColumn> _buildDataColumns() {
    return const [
      DataColumn(label: Text('Req ID', textAlign: TextAlign.center)),
      DataColumn(label: Text('Booking Date', textAlign: TextAlign.center)),
      DataColumn(label: Text('Bike Name', textAlign: TextAlign.center)),
      DataColumn(label: Text('Username', textAlign: TextAlign.center)),
      DataColumn(label: Text('User ID', textAlign: TextAlign.center)),
      DataColumn(label: Text('Days', textAlign: TextAlign.center)),
      DataColumn(label: Text('Amount', textAlign: TextAlign.center)),
      DataColumn(label: Text('Pickup Location', textAlign: TextAlign.center)),
      DataColumn(
        label: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Pickup Date & Time'),
            SizedBox(width: 4),
            Icon(Icons.touch_app, size: 12),
          ],
        ),
      ),
      DataColumn(label: Text('Drop Location', textAlign: TextAlign.center)),
      DataColumn(
        label: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Drop Date & Time'),
            SizedBox(width: 4),
            Icon(Icons.touch_app, size: 12),
          ],
        ),
      ),
      DataColumn(label: Text('Rent', textAlign: TextAlign.center)),
      DataColumn(label: Text('Documents', textAlign: TextAlign.center)),
      DataColumn(label: Text('Status', textAlign: TextAlign.center)),
      DataColumn(label: Text('Action', textAlign: TextAlign.center)),
    ];
  }

  @override
  void dispose() {
    _searchController.dispose();
    _horizontalScrollController.dispose();
    _verticalScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Bikes On Ride',
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
                      'Loading Bikes On Ride...',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                  ],
                ),
              )
              : Column(
                children: [
                  // Search Section
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
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        labelText: 'Search Bikes On Ride',
                        hintText: 'Search by ID, user, location...',
                        prefixIcon: Icon(Icons.search, color: primaryColor),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[400]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: primaryColor, width: 2),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
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
                          '${_filteredBikes.length} bike(s) on ride',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[600],
                          ),
                        ),
                        if (_searchController.text.isNotEmpty)
                          TextButton(
                            onPressed: () => _searchController.clear(),
                            child: Text(
                              'Clear Search',
                              style: TextStyle(color: primaryColor),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Data Table with Fixed Header
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
                                      Icons.directions_bike_outlined,
                                      size: 64,
                                      color: Colors.grey[400],
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      _allBikes.isEmpty
                                          ? 'No bikes on ride'
                                          : 'No matching bikes found',
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
                              : Scrollbar(
                                controller: _verticalScrollController,
                                thumbVisibility: true,
                                child: SingleChildScrollView(
                                  controller: _verticalScrollController,
                                  scrollDirection: Axis.vertical,
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    controller: _horizontalScrollController,
                                    child: DataTable(
                                      columnSpacing: 20,
                                      horizontalMargin: 16,
                                      headingRowHeight: 60,
                                      headingTextStyle: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey[700],
                                        fontSize: 12,
                                      ),
                                      dataTextStyle: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[800],
                                      ),
                                      columns: _buildDataColumns(),
                                      rows:
                                          _filteredBikes.map((booking) {
                                            final days = _calculateDays(
                                              booking,
                                            );
                                            final isOverdue = _isOverdue(
                                              booking,
                                            );
                                            final currentStatus =
                                                booking.bStatus
                                                    ?.toLowerCase() ??
                                                'on ride';

                                            return DataRow(
                                              cells: [
                                                DataCell(
                                                  Center(
                                                    child: Text(
                                                      booking.bId?.toString() ??
                                                          '-',
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                DataCell(
                                                  Center(
                                                    child: Text(
                                                      booking.bookingDate
                                                              .toString() ??
                                                          '-',
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ),
                                                DataCell(
                                                  Center(
                                                    child: Text(
                                                      booking.bBkId
                                                              ?.toString() ??
                                                          '-',
                                                    ),
                                                  ),
                                                ),
                                                DataCell(
                                                  Center(
                                                    child: InkWell(
                                                      onTap:
                                                          () =>
                                                              _showFullTextDialog(
                                                                'User Name',
                                                                booking.uName ??
                                                                    '-',
                                                              ),
                                                      child: Text(
                                                        booking.uName ?? '-',
                                                        overflow:
                                                            TextOverflow
                                                                .ellipsis,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                DataCell(
                                                  Center(
                                                    child: Text(
                                                      booking.bUId
                                                              ?.toString() ??
                                                          '-',
                                                    ),
                                                  ),
                                                ),
                                                DataCell(
                                                  Center(
                                                    child: Container(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                            horizontal: 8,
                                                            vertical: 4,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color:
                                                            isOverdue
                                                                ? Colors.red
                                                                    .withOpacity(
                                                                      0.1,
                                                                    )
                                                                : Colors.green
                                                                    .withOpacity(
                                                                      0.1,
                                                                    ),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              8,
                                                            ),
                                                        border: Border.all(
                                                          color:
                                                              isOverdue
                                                                  ? Colors.red
                                                                  : Colors
                                                                      .green,
                                                        ),
                                                      ),
                                                      child: Text(
                                                        days?.toString() ?? '1',
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color:
                                                              isOverdue
                                                                  ? Colors.red
                                                                  : Colors
                                                                      .green,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                DataCell(
                                                  Center(
                                                    child: Text(
                                                      '₹${booking.bRentAmount?.toString() ?? '-'}',
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color:
                                                            Colors.green[700],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                DataCell(
                                                  Container(
                                                    width: 120,
                                                    child: InkWell(
                                                      onTap:
                                                          () => _showFullTextDialog(
                                                            'Pickup Location',
                                                            booking.bPickupLocation ??
                                                                '-',
                                                          ),
                                                      child: Center(
                                                        child: Text(
                                                          booking.bPickupLocation ??
                                                              '-',
                                                          overflow:
                                                              TextOverflow
                                                                  .ellipsis,
                                                          maxLines: 2,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                DataCell(
                                                  Container(
                                                    width: 140,
                                                    child: InkWell(
                                                      onTap:
                                                          () => _showDateTimeDialog(
                                                            'Pickup Date & Time',
                                                            booking.bPickupDate
                                                                .toString()
                                                                .toString(),
                                                            booking.bPicupTime
                                                                .toString()
                                                                .toString(),
                                                          ),
                                                      child: Center(
                                                        child: Text(
                                                          _formatDateTime(
                                                            booking.bPickupDate
                                                                .toString()
                                                                .toString(),
                                                            booking.bPicupTime
                                                                .toString()
                                                                .toString(),
                                                          ),
                                                          style: TextStyle(
                                                            fontSize: 11,
                                                          ),
                                                          overflow:
                                                              TextOverflow
                                                                  .ellipsis,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                DataCell(
                                                  Container(
                                                    width: 120,
                                                    child: InkWell(
                                                      onTap:
                                                          () => _showFullTextDialog(
                                                            'Drop Location',
                                                            booking.bDropLocation ??
                                                                '-',
                                                          ),
                                                      child: Center(
                                                        child: Text(
                                                          booking.bDropLocation ??
                                                              '-',
                                                          overflow:
                                                              TextOverflow
                                                                  .ellipsis,
                                                          maxLines: 2,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                DataCell(
                                                  Container(
                                                    width: 140,
                                                    child: InkWell(
                                                      onTap:
                                                          () => _showDateTimeDialog(
                                                            'Drop Date & Time',
                                                            booking.bDropDate
                                                                .toString()
                                                                .toString(),
                                                            booking.bDropTime
                                                                .toString(),
                                                          ),
                                                      child: Center(
                                                        child: Text(
                                                          _formatDateTime(
                                                            booking.bDropDate
                                                                .toString()
                                                                .toString(),
                                                            booking.bDropTime
                                                                .toString(),
                                                          ),
                                                          style: TextStyle(
                                                            fontSize: 11,
                                                            color:
                                                                isOverdue
                                                                    ? Colors.red
                                                                    : null,
                                                          ),
                                                          overflow:
                                                              TextOverflow
                                                                  .ellipsis,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                DataCell(
                                                  Center(
                                                    child: Text(
                                                      '₹${booking.bRentAmount?.toString() ?? '-'}',
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                DataCell(
                                                  Center(
                                                    child: ElevatedButton.icon(
                                                      onPressed:
                                                          () =>
                                                              _showAllDocuments(
                                                                booking,
                                                              ),
                                                      icon: Icon(
                                                        Icons.folder_open,
                                                        size: 16,
                                                      ),
                                                      label: Text('View All'),
                                                      style: ElevatedButton.styleFrom(
                                                        backgroundColor:
                                                            Colors.blue[50],
                                                        foregroundColor:
                                                            Colors.blue[700],
                                                        padding:
                                                            EdgeInsets.symmetric(
                                                              horizontal: 12,
                                                              vertical: 8,
                                                            ),
                                                        textStyle: TextStyle(
                                                          fontSize: 11,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                DataCell(
                                                  Center(
                                                    child: Container(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                            horizontal: 12,
                                                            vertical: 8,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color: _getStatusColor(
                                                          booking.bStatus,
                                                        ).withOpacity(0.1),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              12,
                                                            ),
                                                        border: Border.all(
                                                          color:
                                                              _getStatusColor(
                                                                booking.bStatus,
                                                              ),
                                                        ),
                                                      ),
                                                      child: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Icon(
                                                            Icons
                                                                .directions_bike,
                                                            size: 16,
                                                            color:
                                                                _getStatusColor(
                                                                  booking
                                                                      .bStatus,
                                                                ),
                                                          ),
                                                          SizedBox(width: 6),
                                                          Text(
                                                            (booking.bStatus ??
                                                                    'ON RIDE')
                                                                .toUpperCase(),
                                                            style: TextStyle(
                                                              color:
                                                                  _getStatusColor(
                                                                    booking
                                                                        .bStatus,
                                                                  ),
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 11,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                DataCell(
                                                  Center(
                                                    child: ElevatedButton(
                                                      onPressed:
                                                          () =>
                                                              _markRideCompleted(
                                                                booking,
                                                              ),
                                                      style: ElevatedButton.styleFrom(
                                                        backgroundColor:
                                                            Colors.green,
                                                        foregroundColor:
                                                            Colors.white,
                                                        padding:
                                                            EdgeInsets.symmetric(
                                                              horizontal: 12,
                                                              vertical: 8,
                                                            ),
                                                        textStyle: TextStyle(
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                      child: Text(
                                                        'Ride Completed',
                                                        style: smalltextwhite,
                                                      ),
                                                    ),
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
                  ),
                ],
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: fetchdata,
        backgroundColor: primaryColor,
        child: Icon(Icons.refresh, color: Colors.white),
      ),
    );
  }
}
