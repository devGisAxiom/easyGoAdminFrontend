import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:getbike_admin/controllers/controllers.dart';
import 'package:getbike_admin/controllers_post/update_bike.dart';
import 'package:getbike_admin/controllers_post/updatestatus.dart';
import 'package:getbike_admin/models/models.dart';
import 'package:getbike_admin/utils/utilities.dart';
import 'package:getbike_admin/views/image.dart';

class BookingRequests extends StatefulWidget {
  @override
  State<BookingRequests> createState() => _BookingRequestsState();
}

class _BookingRequestsState extends State<BookingRequests> {
  MyBookingController _bookingController = MyBookingController();
  TextEditingController _searchController = TextEditingController();

  List<BookingModel> _allBikes = [];
  List<BookingModel> _filteredBikes = [];
  bool _isLoading = true;

  final ScrollController _horizontalScrollController = ScrollController();
  final ScrollController _verticalScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    fetchdata();
    _searchController.addListener(() {
      _onSearchChanged(_searchController.text);
    });
  }

  Future<void> fetchdata() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _bookingController.fetchBikes();
      _allBikes = List.from(_bookingController.bookingReqList);
      _filteredBikes = List.from(_allBikes);
    } catch (e) {
      print('Error fetching data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading booking requests: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredBikes = List.from(_allBikes);
      } else {
        _filteredBikes =
            _allBikes.where((bike) {
              final q = query.toLowerCase();
              return (bike.bId?.toString() ?? "").contains(q) ||
                  (bike.bUId?.toString() ?? "").contains(q) ||
                  (bike.uName ?? "").toLowerCase().contains(q);
            }).toList();
      }
    });
  }

  // Parse date from string (date only)
  DateTime? _parseDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return null;
    try {
      // Handle format like "2026-01-07"
      return DateTime.parse(dateString.split(' ')[0]); // Take only date part
    } catch (e) {
      return null;
    }
  }

  // Parse date-time from string
  DateTime? _parseDateTime(String? dateTimeString) {
    if (dateTimeString == null || dateTimeString.isEmpty) return null;
    try {
      // Handle format like "2026-01-07 13:00:00.000"
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

  // Combined date and time format - "7th Jan 2026 1:00 PM"
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

  // Calculate number of days between pickup and drop
  int? _calculateDays(BookingModel booking) {
    try {
      // Parse string dates to DateTime objects
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

  // Get full image URL
  String _getFullImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) return '';

    // If already a full URL, return as is
    if (imagePath.startsWith('http')) {
      return imagePath;
    }

    // Otherwise construct full URL
    String baseUrl = "https://lunarsenterprises.com:7006";

    // Handle the path correctly
    if (imagePath.startsWith('/')) {
      return '$baseUrl$imagePath';
    } else {
      return '$baseUrl/$imagePath';
    }
  }

  Widget _buildDocumentWidget(String? documentUrl, String documentType) {
    final fullUrl = _getFullImageUrl(documentUrl);
    print('Document URL: $fullUrl');

    if (documentUrl == null || documentUrl.isEmpty) {
      return _buildPlaceholderIcon(Icons.document_scanner, 'No $documentType');
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ImageView(image: fullUrl)),
        );
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
              print('Error loading image: $error');
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

  // Show all documents in a popup/dialog
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

                    // Selfie
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

  // Show full text in dialog
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

  // Show full date-time details in dialog
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
                  // Formatted date-time
                  Text(
                    _formatDateTime(date, time),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                  SizedBox(height: 16),

                  // Breakdown
                  Text(
                    'Breakdown:',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: 8),

                  // Date section
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

                  // Time section
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
                          _formatTime(_parseDateTime(time)) ?? '-',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 8),
                      ],
                    ),

                  // Raw data for debugging
                  SizedBox(height: 16),
                  Divider(),
                  Text(
                    'Raw Data:',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Date: $date\nTime: $time',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[500],
                      fontFamily: 'Monospace',
                    ),
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

  Widget _buildDocumentSection(
    String title,
    String? documentUrl,
    IconData icon,
  ) {
    print("doc url :  $documentUrl");
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

  void _handleStatusUpdate(BookingModel booking, String status) {
    if (booking.bUId != null && booking.bId != null) {
      updatebookingstatus(
        context,
        booking.bUId.toString(),
        status,
        booking.bId.toString(),
        1,
      );
      setState(() {
        fetchdata();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: Missing booking information')),
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _horizontalScrollController.dispose();
    _verticalScrollController.dispose();
    super.dispose();
  }

  // Define column list to maintain consistency
  List<DataColumn> _buildDataColumns() {
    return const [
      DataColumn(label: Text('Req ID', textAlign: TextAlign.center)),
      DataColumn(label: Text('Date', textAlign: TextAlign.center)),
      DataColumn(label: Text('Username', textAlign: TextAlign.center)),
      DataColumn(label: Text('Total Paid', textAlign: TextAlign.center)),
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
      DataColumn(label: Text('Rent Amount', textAlign: TextAlign.center)),
      DataColumn(label: Text('Payment Status', textAlign: TextAlign.center)),
      DataColumn(label: Text('Documents', textAlign: TextAlign.center)),
      DataColumn(label: Text('Actions', textAlign: TextAlign.center)),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Booking Requests',
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
                      'Loading Booking Requests...',
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
                        labelText: 'Search Booking Requests',
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
                          '${_filteredBikes.length} booking request(s) found',
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
                                      Icons.search_off,
                                      size: 64,
                                      color: Colors.grey[400],
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      _allBikes.isEmpty
                                          ? 'No booking requests found'
                                          : 'No matching booking requests',
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
                                            final noOfDays = _calculateDays(
                                              booking,
                                            );
                                            final currentStatus =
                                                booking.bStatus
                                                    ?.toLowerCase() ??
                                                'pending';

                                            Color statusColor = Colors.grey;
                                            if (currentStatus == 'approved') {
                                              statusColor = Colors.green;
                                            } else if (currentStatus ==
                                                'rejected') {
                                              statusColor = Colors.red;
                                            } else if (currentStatus ==
                                                'pending') {
                                              statusColor = Colors.orange;
                                            }

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
                                                      '₹${booking.bTotalAmount?.toString() ?? '-'}',
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
                                                                .toString(),
                                                            booking.bDropTime
                                                                .toString(),
                                                          ),
                                                      child: Center(
                                                        child: Text(
                                                          _formatDateTime(
                                                            booking.bDropDate
                                                                .toString(),
                                                            booking.bDropTime
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
                                                  Center(
                                                    child: Text(
                                                      '₹${booking.bRentAmount?.toString() ?? booking.bRentAmount?.toString() ?? '-'}',
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
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
                                                            _getPaymentStatusColor(
                                                              booking
                                                                  .bPaymentStatus,
                                                            ),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              12,
                                                            ),
                                                      ),
                                                      child: Text(
                                                        (booking.bPaymentStatus ??
                                                                'PENDING')
                                                            .toUpperCase(),
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 10,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
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
                                                    child: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        if (currentStatus !=
                                                                'approved' &&
                                                            currentStatus !=
                                                                'rejected')
                                                          Row(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            children: [
                                                              ElevatedButton(
                                                                onPressed:
                                                                    () => _handleStatusUpdate(
                                                                      booking,
                                                                      "approved",
                                                                    ),
                                                                style: ElevatedButton.styleFrom(
                                                                  backgroundColor:
                                                                      Colors
                                                                          .green,
                                                                  foregroundColor:
                                                                      Colors
                                                                          .white,
                                                                  padding:
                                                                      EdgeInsets.symmetric(
                                                                        horizontal:
                                                                            12,
                                                                        vertical:
                                                                            8,
                                                                      ),
                                                                  textStyle:
                                                                      TextStyle(
                                                                        fontSize:
                                                                            12,
                                                                      ),
                                                                ),
                                                                child: Text(
                                                                  'Accept',
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                width: 6,
                                                              ),
                                                              ElevatedButton(
                                                                onPressed:
                                                                    () => _handleStatusUpdate(
                                                                      booking,
                                                                      "rejected",
                                                                    ),
                                                                style: ElevatedButton.styleFrom(
                                                                  backgroundColor:
                                                                      Colors
                                                                          .red,
                                                                  foregroundColor:
                                                                      Colors
                                                                          .white,
                                                                  padding:
                                                                      EdgeInsets.symmetric(
                                                                        horizontal:
                                                                            12,
                                                                        vertical:
                                                                            8,
                                                                      ),
                                                                  textStyle:
                                                                      TextStyle(
                                                                        fontSize:
                                                                            12,
                                                                      ),
                                                                ),
                                                                child: Text(
                                                                  'Reject',
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        if (currentStatus ==
                                                                'approved' ||
                                                            currentStatus ==
                                                                'rejected')
                                                          Container(
                                                            padding:
                                                                EdgeInsets.symmetric(
                                                                  horizontal:
                                                                      12,
                                                                  vertical: 6,
                                                                ),
                                                            decoration: BoxDecoration(
                                                              color: statusColor
                                                                  .withOpacity(
                                                                    0.1,
                                                                  ),
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    12,
                                                                  ),
                                                              border: Border.all(
                                                                color:
                                                                    statusColor,
                                                              ),
                                                            ),
                                                            child: Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              children: [
                                                                Icon(
                                                                  currentStatus ==
                                                                          'approved'
                                                                      ? Icons
                                                                          .check_circle
                                                                      : Icons
                                                                          .cancel,
                                                                  size: 16,
                                                                  color:
                                                                      statusColor,
                                                                ),
                                                                SizedBox(
                                                                  width: 6,
                                                                ),
                                                                Text(
                                                                  currentStatus
                                                                      .toUpperCase(),
                                                                  style: TextStyle(
                                                                    color:
                                                                        statusColor,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontSize:
                                                                        11,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                      ],
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

  Color _getPaymentStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'paid':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'failed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
