import 'package:flutter/material.dart';
import 'package:getbike_admin/controllers/controllers.dart';
import 'package:getbike_admin/controllers_post/updatestatus.dart';
import 'package:getbike_admin/models/models.dart';
import 'package:getbike_admin/utils/utilities.dart';
import 'package:getbike_admin/views/image.dart';
import 'package:url_launcher/url_launcher.dart';

class CancellationRequests extends StatefulWidget {
  @override
  State<CancellationRequests> createState() => _CancellationRequestsState();
}

class _CancellationRequestsState extends State<CancellationRequests> {
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
    _searchController.addListener(_onSearchChanged);
  }

  Future<void> fetchdata() async {
    setState(() => _isLoading = true);
    try {
      await _bookingController.fetchBikes();
      _allBikes = List.from(_bookingController.cancelreq);
      _filteredBikes = List.from(_allBikes);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading cancellation requests: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _onSearchChanged() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredBikes = List.from(_allBikes);
      } else {
        _filteredBikes =
            _allBikes.where((booking) {
              return (booking.bId?.toString() ?? '').contains(query) ||
                  (booking.bBkId?.toString() ?? '').contains(query) ||
                  (booking.bUId?.toString() ?? '').contains(query) ||
                  (booking.uName ?? '').toLowerCase().contains(query) ||
                  (booking.bPickupLocation ?? '').toLowerCase().contains(
                    query,
                  ) ||
                  (booking.bDropLocation ?? '').toLowerCase().contains(query) ||
                  (booking.bPickupDate?.toString() ?? '')
                      .toLowerCase()
                      .contains(query) ||
                  (booking.viewReason ?? '').toLowerCase().contains(
                    query,
                  ); // Added reason search
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

  // Calculate number of days
  int? _calculateDays(BookingModel booking) {
    try {
      final pickupDate = _parseDate(booking.bPickupDate?.toString());
      final dropDate = _parseDate(booking.bDropDate?.toString());

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

  void _showCustomerDetails(BuildContext context, BookingModel booking) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.person, color: primaryColor),
                SizedBox(width: 8),
                Text('Cancellation Request Details'),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow('Customer Name', booking.uName ?? 'N/A'),
                  _buildDetailRow(
                    'Booking ID',
                    booking.bId?.toString() ?? 'N/A',
                  ),
                  _buildDetailRow('User ID', booking.bUId?.toString() ?? 'N/A'),
                  SizedBox(height: 16),
                  Text(
                    'Booking Details:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                  _buildDetailRow(
                    'Pickup Location',
                    booking.bPickupLocation ?? 'N/A',
                  ),
                  _buildDetailRow(
                    'Drop Location',
                    booking.bDropLocation ?? 'N/A',
                  ),
                  _buildDetailRow(
                    'Pickup Date',
                    _formatDate(_parseDate(booking.bPickupDate?.toString())),
                  ),
                  _buildDetailRow(
                    'Pickup Time',
                    booking.bPicupTime?.toString() ?? 'N/A',
                  ),
                  _buildDetailRow(
                    'Drop Date',
                    _formatDate(_parseDate(booking.bDropDate?.toString())),
                  ),
                  _buildDetailRow(
                    'Drop Time',
                    booking.bDropTime?.toString() ?? 'N/A',
                  ),
                  _buildDetailRow(
                    'Total Amount',
                    '₹${booking.bRentAmount?.toString() ?? 'N/A'}',
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Cancellation Reason:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(12),
                    margin: EdgeInsets.only(top: 8),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange[200]!),
                    ),
                    child: Text(
                      booking.viewReason ?? 'No reason provided',
                      style: TextStyle(color: Colors.orange[800], fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Close'),
              ),
              if (booking.uMobile != null &&
                  booking.uMobile.toString().isNotEmpty)
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _makePhoneCall(booking.uMobile.toString());
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  child: Text('Call Customer', style: smalltextwhite),
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

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Could not launch phone app')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error making call: ${e.toString()}')),
      );
    }
  }

  void _confirmAcceptCancellation(BookingModel booking) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green),
                SizedBox(width: 8),
                Text('Accept Cancellation'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Are you sure you want to accept this cancellation request?',
                ),
                SizedBox(height: 16),
                _buildDetailRow('Customer', booking.uName ?? 'N/A'),
                _buildDetailRow('Booking ID', booking.bId?.toString() ?? 'N/A'),
                _buildDetailRow(
                  'Amount',
                  '₹${booking.bRentAmount?.toString() ?? 'N/A'}',
                ),
                if (booking.viewReason != null &&
                    booking.viewReason!.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 8),
                      Text(
                        'Cancellation Reason:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        booking.viewReason!,
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                    ],
                  ),
                SizedBox(height: 8),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green[200]!),
                  ),
                  child: Text(
                    'This will cancel the booking and refund the amount.',
                    style: TextStyle(
                      color: Colors.green[800],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _acceptCancellation(booking);
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: Text('Accept Cancellation', style: smalltextwhite),
              ),
            ],
          ),
    );
  }

  void _confirmRejectCancellation(BookingModel booking) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.cancel, color: Colors.red),
                SizedBox(width: 8),
                Text('Reject Cancellation'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Are you sure you want to reject this cancellation request?',
                ),
                SizedBox(height: 16),
                _buildDetailRow('Customer', booking.uName ?? 'N/A'),
                _buildDetailRow('Booking ID', booking.bId?.toString() ?? 'N/A'),
                if (booking.viewReason != null &&
                    booking.viewReason!.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 8),
                      Text(
                        'Cancellation Reason:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        booking.viewReason!,
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                    ],
                  ),
                SizedBox(height: 8),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red[200]!),
                  ),
                  child: Text(
                    'The booking will continue as scheduled.',
                    style: TextStyle(
                      color: Colors.red[800],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _rejectCancellation(booking);
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: Text('Reject Cancellation', style: smalltextwhite),
              ),
            ],
          ),
    );
  }

  void _acceptCancellation(BookingModel booking) {
    if (booking.bUId != null && booking.bId != null) {
      updatebookingstatus(
        context,
        booking.bUId.toString(),
        "cancelled",
        booking.bId.toString(),
        3,
      );
      fetchdata();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: Missing booking information')),
      );
    }
  }

  void _rejectCancellation(BookingModel booking) {
    if (booking.bUId != null && booking.bId != null) {
      updatebookingstatus(
        context,
        booking.bUId.toString(),
        "Cancellation Rejected",
        booking.bId.toString(),
        3,
      );
      fetchdata();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: Missing booking information')),
      );
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

  // Show reason dialog
  void _showReasonDialog(String title, String content) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.orange),
                SizedBox(width: 8),
                Text(title),
              ],
            ),
            content: SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange[200]!),
                ),
                child: Text(
                  content.isNotEmpty ? content : 'No reason specified',
                  style: TextStyle(fontSize: 14, color: Colors.orange[800]),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Close', style: TextStyle(color: Colors.grey[600])),
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
      DataColumn(label: Text('Username', textAlign: TextAlign.center)),
      DataColumn(label: Text('Cancel Reason', textAlign: TextAlign.center)),
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
      DataColumn(label: Text('Documents', textAlign: TextAlign.center)),
      DataColumn(label: Text('Actions', textAlign: TextAlign.center)),
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
          'Cancellation Requests',
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
                      'Loading Cancellation Requests...',
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
                        labelText: 'Search Cancellation Requests',
                        hintText: 'Search by ID, user, reason, location...',
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
                          '${_filteredBikes.length} cancellation request(s)',
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
                                      Icons.cancel_schedule_send_outlined,
                                      size: 64,
                                      color: Colors.grey[400],
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      _allBikes.isEmpty
                                          ? 'No cancellation requests'
                                          : 'No matching requests found',
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
                                                      _formatDate(
                                                        _parseDate(
                                                          booking.bookingDate
                                                              ?.toString(),
                                                        ),
                                                      ),
                                                      overflow:
                                                          TextOverflow.ellipsis,
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
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                DataCell(
                                                  Center(
                                                    child: InkWell(
                                                      onTap:
                                                          () => _showReasonDialog(
                                                            'Cancellation Reason',
                                                            booking.viewReason ??
                                                                'Not specified',
                                                          ),
                                                      child: Container(
                                                        padding:
                                                            EdgeInsets.symmetric(
                                                              horizontal: 8,
                                                              vertical: 4,
                                                            ),
                                                        decoration: BoxDecoration(
                                                          color: Colors.orange
                                                              .withOpacity(0.1),
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                8,
                                                              ),
                                                          border: Border.all(
                                                            color:
                                                                Colors.orange,
                                                          ),
                                                        ),
                                                        child: Text(
                                                          booking
                                                                      .viewReason
                                                                      ?.isNotEmpty ==
                                                                  true
                                                              ? 'View Reason'
                                                              : 'No Reason',
                                                          style: TextStyle(
                                                            fontSize: 10,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            color:
                                                                Colors.orange,
                                                          ),
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
                                                                ?.toString(),
                                                            booking.bPicupTime
                                                                ?.toString(),
                                                          ),
                                                      child: Center(
                                                        child: Text(
                                                          _formatDateTime(
                                                            booking.bPickupDate
                                                                ?.toString(),
                                                            booking.bPicupTime
                                                                ?.toString(),
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
                                                                ?.toString(),
                                                            booking.bDropTime
                                                                ?.toString(),
                                                          ),
                                                      child: Center(
                                                        child: Text(
                                                          _formatDateTime(
                                                            booking.bDropDate
                                                                ?.toString(),
                                                            booking.bDropTime
                                                                ?.toString(),
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
                                                        ElevatedButton(
                                                          onPressed:
                                                              () =>
                                                                  _showCustomerDetails(
                                                                    context,
                                                                    booking,
                                                                  ),
                                                          style: ElevatedButton.styleFrom(
                                                            backgroundColor:
                                                                Colors.blue,
                                                            foregroundColor:
                                                                Colors.white,
                                                            padding:
                                                                EdgeInsets.symmetric(
                                                                  horizontal:
                                                                      12,
                                                                  vertical: 8,
                                                                ),
                                                            textStyle:
                                                                TextStyle(
                                                                  fontSize: 11,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                          ),
                                                          child: Row(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            children: [
                                                              Icon(
                                                                Icons
                                                                    .info_outline,
                                                                size: 14,
                                                              ),
                                                              SizedBox(
                                                                width: 4,
                                                              ),
                                                              Text('Details'),
                                                            ],
                                                          ),
                                                        ),
                                                        SizedBox(width: 8),
                                                        ElevatedButton(
                                                          onPressed:
                                                              () =>
                                                                  _confirmAcceptCancellation(
                                                                    booking,
                                                                  ),
                                                          style: ElevatedButton.styleFrom(
                                                            backgroundColor:
                                                                Colors.green,
                                                            foregroundColor:
                                                                Colors.white,
                                                            padding:
                                                                EdgeInsets.symmetric(
                                                                  horizontal:
                                                                      12,
                                                                  vertical: 8,
                                                                ),
                                                            textStyle:
                                                                TextStyle(
                                                                  fontSize: 11,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                          ),
                                                          child: Row(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            children: [
                                                              Icon(
                                                                Icons
                                                                    .check_circle,
                                                                size: 14,
                                                              ),
                                                              SizedBox(
                                                                width: 4,
                                                              ),
                                                              Text('Accept'),
                                                            ],
                                                          ),
                                                        ),
                                                        SizedBox(width: 8),
                                                        OutlinedButton(
                                                          onPressed:
                                                              () =>
                                                                  _confirmRejectCancellation(
                                                                    booking,
                                                                  ),
                                                          style: OutlinedButton.styleFrom(
                                                            foregroundColor:
                                                                Colors.red,
                                                            side: BorderSide(
                                                              color: Colors.red,
                                                            ),
                                                            padding:
                                                                EdgeInsets.symmetric(
                                                                  horizontal:
                                                                      12,
                                                                  vertical: 8,
                                                                ),
                                                            textStyle:
                                                                TextStyle(
                                                                  fontSize: 11,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                          ),
                                                          child: Row(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            children: [
                                                              Icon(
                                                                Icons.cancel,
                                                                size: 14,
                                                              ),
                                                              SizedBox(
                                                                width: 4,
                                                              ),
                                                              Text('Reject'),
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
}
