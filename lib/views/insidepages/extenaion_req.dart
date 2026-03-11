import 'package:flutter/material.dart';
import 'package:getbike_admin/controllers/controllers.dart';
import 'package:getbike_admin/controllers_post/updatestatus.dart';
import 'package:getbike_admin/models/models.dart';
import 'package:getbike_admin/utils/utilities.dart';
import 'package:getbike_admin/views/image.dart';
import 'package:url_launcher/url_launcher.dart';

class ExtensionRequests extends StatefulWidget {
  @override
  State<ExtensionRequests> createState() => _ExtensionRequestsState();
}

class _ExtensionRequestsState extends State<ExtensionRequests> {
  MyBookingController _bookingController = MyBookingController();
  TextEditingController _searchController = TextEditingController();
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
    setState(() {
      _isLoading = true;
    });

    try {
      await _bookingController.fetchBikes();
      _allBikes = List.from(_bookingController.Extendbookingreq);
      _filteredBikes = List.from(_allBikes);
    } catch (e) {
      print('Error fetching data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading extension requests: $e')),
      );
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
            _allBikes.where((booking) {
              return (booking.bId?.toString() ?? "").contains(query) ||
                  (booking.bUId?.toString() ?? "").contains(query) ||
                  (booking.uName ?? "").toLowerCase().contains(query) ||
                  (booking.bPickupLocation ?? "").toLowerCase().contains(
                    query,
                  ) ||
                  (booking.bDropLocation ?? "").toLowerCase().contains(query);
            }).toList();
      }
    });
  }

  // Parse string to DateTime
  DateTime? _parseDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return null;
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      return null;
    }
  }

  // Format date from DateTime to readable string
  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return 'N/A';

    try {
      final date = _parseDate(dateString);
      if (date == null) return dateString;

      final day = date.day.toString().padLeft(2, '0');
      final month = date.month.toString().padLeft(2, '0');
      final year = date.year;

      return '$day - $month - $year';
    } catch (e) {
      return dateString;
    }
  }

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

  // Get full image URL - FIXED VERSION
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

  bool _isPdf(String? url) {
    if (url == null) return false;
    return url.toLowerCase().endsWith('.pdf');
  }

  Future<void> _openPdf(String url, String documentType) async {
    try {
      final fullUrl = _getFullImageUrl(url);
      if (await canLaunchUrl(Uri.parse(fullUrl))) {
        await launchUrl(
          Uri.parse(fullUrl),
          mode: LaunchMode.externalApplication,
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Could not open PDF')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error opening PDF: ${e.toString()}')),
      );
    }
  }

  // Count available documents for a booking
  int _countAvailableDocuments(BookingModel booking) {
    int count = 0;
    List<String?> documents = [booking.bSelfie];

    for (var doc in documents) {
      if (doc != null && doc.isNotEmpty) count++;
    }
    return count;
  }

  Widget _buildDocumentWidget(String? documentUrl, String documentType) {
    final fullUrl = _getFullImageUrl(documentUrl);

    if (documentUrl == null || documentUrl.isEmpty) {
      return _buildPlaceholderIcon(Icons.document_scanner, 'No $documentType');
    }

    return GestureDetector(
      onTap: () {
        if (_isPdf(documentUrl)) {
          _openPdf(fullUrl, documentType);
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ImageView(image: fullUrl)),
          );
        }
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
          child:
              _isPdf(documentUrl)
                  ? Container(
                    color: Colors.grey[100],
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.picture_as_pdf, color: Colors.red, size: 24),
                        SizedBox(height: 4),
                        Text(
                          'PDF',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  )
                  : Image.network(
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

  // Get extended drop date - FIXED VERSION
  String? _getExtendedDropDate(BookingModel booking) {
    // Assuming bDropDate.toString() is the extended date for extension requests
    return booking.bDropDate.toString();
  }

  // Calculate additional rent for extension
  double? _calculateAdditionalRent(BookingModel booking) {
    if (booking.bRentAmount != null) {
      return booking.bRentAmount! * 0.5; // 50% of original rent
    }
    return null;
  }

  void _showCustomerDetails(BuildContext context, BookingModel booking) {
    final extendedDropDate = _getExtendedDropDate(booking);
    final additionalRent = _calculateAdditionalRent(booking);

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.schedule, color: primaryColor),
                SizedBox(width: 8),
                Text('Extension Request Details'),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Booking ID: ${booking.bId ?? 'N/A'}',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(height: 16),
                  _buildDetailRow('Customer Name', booking.uName ?? 'N/A'),

                  _buildDetailRow('User ID', booking.bUId?.toString() ?? 'N/A'),
                  SizedBox(height: 16),
                  Text(
                    'Original Booking:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: 8),
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
                    _formatDate(booking.bPickupDate.toString()),
                  ),
                  _buildDetailRow(
                    'Pickup Time',
                    _formatTime(booking.bPicupTime),
                  ),
                  _buildDetailRow(
                    'Original Drop Date',
                    _formatDate(booking.bDropDate.toString()),
                  ),
                  _buildDetailRow(
                    'Original Drop Time',
                    _formatTime(booking.bDropTime),
                  ),
                  _buildDetailRow(
                    'Original Rent',
                    '₹${booking.bRentAmount?.toString() ?? '0'}',
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Extension Request:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange[700],
                    ),
                  ),
                  SizedBox(height: 8),
                  _buildDetailRow(
                    'Extended Drop Date',
                    _formatDate(extendedDropDate),
                  ),
                  _buildDetailRow(
                    'Additional Rent',
                    '₹${additionalRent?.toStringAsFixed(2) ?? '0'}',
                  ),
                  _buildDetailRow(
                    'Total Rent',
                    '₹${(booking.bRentAmount ?? 0) + (additionalRent ?? 0)}',
                  ),
                  SizedBox(height: 16),
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.schedule_send,
                          color: Colors.orange,
                          size: 24,
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Extension Request Pending Approval',
                            style: TextStyle(
                              color: Colors.orange[800],
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Close', style: TextStyle(color: Colors.grey[600])),
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

  void _confirmApproveExtension(BookingModel booking) {
    final additionalRent = _calculateAdditionalRent(booking);
    final extendedDropDate = _getExtendedDropDate(booking);

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Approve Extension'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Are you sure you want to approve this extension request?',
                ),
                SizedBox(height: 16),
                _buildDetailRow('Customer', booking.uName ?? 'N/A'),

                _buildDetailRow(
                  'Extended Drop Date',
                  _formatDate(extendedDropDate),
                ),
                _buildDetailRow(
                  'Additional Rent',
                  '₹${additionalRent?.toStringAsFixed(2) ?? '0'}',
                ),
                _buildDetailRow(
                  'Total Rent',
                  '₹${(booking.bRentAmount ?? 0) + (additionalRent ?? 0)}',
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
                    'The booking will be extended and additional rent will be charged.',
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
                  _approveExtension(booking);
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: Text('Approve Extension', style: smalltextwhite),
              ),
            ],
          ),
    );
  }

  void _confirmRejectExtension(BookingModel booking) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Reject Extension'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Are you sure you want to reject this extension request?'),
                SizedBox(height: 16),
                _buildDetailRow('Customer', booking.uName ?? 'N/A'),

                SizedBox(height: 8),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red[200]!),
                  ),
                  child: Text(
                    'The booking will continue with original drop-off time.',
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
                  _rejectExtension(booking);
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: Text('Reject Extension', style: smalltextwhite),
              ),
            ],
          ),
    );
  }

  void _approveExtension(BookingModel booking) {
    if (booking.bUId != null && booking.bId != null) {
      updatebookingstatus(
        context,
        booking.bUId.toString(),
        "extended",
        booking.bId.toString(),
        4,
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

  void _rejectExtension(BookingModel booking) {
    if (booking.bUId != null && booking.bId != null) {
      updatebookingstatus(
        context,
        booking.bUId.toString(),
        "extension_rejected",
        booking.bId.toString(),
        4,
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
          'Extension Requests',
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
                      'Loading Extension Requests...',
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
                        labelText: 'Search Extension Requests',
                        hintText: 'Search by bike name, ID, user, location...',
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
                          '${_filteredBikes.length} extension request(s)',
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

                  // Data Table - UPDATED FOR FULL WIDTH
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: fetchdata,
                      color: primaryColor,
                      child: Container(
                        width: double.infinity,
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
                                        Icons.schedule_send_outlined,
                                        size: 64,
                                        color: Colors.grey[400],
                                      ),
                                      SizedBox(height: 16),
                                      Text(
                                        _allBikes.isEmpty
                                            ? 'No extension requests'
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
                                            style: TextStyle(
                                              color: primaryColor,
                                            ),
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
                                      headingRowColor:
                                          MaterialStateProperty.all(
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
                                      columns: [
                                        DataColumn(
                                          label: Container(
                                            width: 80,
                                            child: Text('Req ID'),
                                          ),
                                        ),
                                        DataColumn(
                                          label: Container(
                                            width: 120,
                                            child: Text('Bike Name'),
                                          ),
                                        ),
                                        DataColumn(
                                          label: Container(
                                            width: 100,
                                            child: Text('Username'),
                                          ),
                                        ),
                                        DataColumn(
                                          label: Container(
                                            width: 120,
                                            child: Text('Extended Drop-off'),
                                          ),
                                        ),
                                        DataColumn(
                                          label: Container(
                                            width: 100,
                                            child: Text('Payment Status'),
                                          ),
                                        ),
                                        DataColumn(
                                          label: Container(
                                            width: 120,
                                            child: Text('Documents'),
                                          ),
                                        ),
                                        DataColumn(
                                          label: Container(
                                            width: 300,
                                            child: Text('Actions'),
                                          ),
                                        ),
                                      ],
                                      rows:
                                          _filteredBikes.map((booking) {
                                            final documentCount =
                                                _countAvailableDocuments(
                                                  booking,
                                                );
                                            final extendedDropDate =
                                                _getExtendedDropDate(booking);

                                            return DataRow(
                                              cells: [
                                                DataCell(
                                                  Container(
                                                    width: 80,
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
                                                  Container(
                                                    width: 100,
                                                    child: Text(
                                                      booking.uName ?? '-',
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                DataCell(
                                                  Container(
                                                    width: 120,
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          _formatDate(
                                                            extendedDropDate,
                                                          ),
                                                          style: TextStyle(
                                                            fontSize: 11,
                                                          ),
                                                        ),
                                                        Text(
                                                          booking.bDropTime
                                                                  .toString() ??
                                                              '-',
                                                          style: TextStyle(
                                                            fontSize: 10,
                                                            color:
                                                                Colors
                                                                    .grey[600],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                DataCell(
                                                  Container(
                                                    width: 100,
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
                                                        textAlign:
                                                            TextAlign.center,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                DataCell(
                                                  Container(
                                                    width: 120,
                                                    child: ElevatedButton.icon(
                                                      onPressed:
                                                          () =>
                                                              _showAllDocuments(
                                                                booking,
                                                              ),
                                                      icon: Stack(
                                                        children: [
                                                          Icon(
                                                            Icons.folder_open,
                                                            size: 16,
                                                          ),
                                                          if (documentCount > 0)
                                                            Positioned(
                                                              right: 0,
                                                              top: 0,
                                                              child: Container(
                                                                padding:
                                                                    EdgeInsets.all(
                                                                      2,
                                                                    ),
                                                                decoration: BoxDecoration(
                                                                  color:
                                                                      Colors
                                                                          .red,
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                        6,
                                                                      ),
                                                                ),
                                                                constraints:
                                                                    BoxConstraints(
                                                                      minWidth:
                                                                          12,
                                                                      minHeight:
                                                                          12,
                                                                    ),
                                                                child: Text(
                                                                  documentCount
                                                                      .toString(),
                                                                  style: TextStyle(
                                                                    color:
                                                                        Colors
                                                                            .white,
                                                                    fontSize: 8,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                  ),
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                ),
                                                              ),
                                                            ),
                                                        ],
                                                      ),
                                                      label: Text('View All'),
                                                      style: ElevatedButton.styleFrom(
                                                        backgroundColor:
                                                            Colors.blue[50],
                                                        foregroundColor:
                                                            Colors.blue[700],
                                                        padding:
                                                            EdgeInsets.symmetric(
                                                              horizontal: 8,
                                                              vertical: 6,
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
                                                  Container(
                                                    width: 300,
                                                    child: Wrap(
                                                      spacing: 4,
                                                      runSpacing: 4,
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
                                                                  vertical: 6,
                                                                ),
                                                            textStyle:
                                                                TextStyle(
                                                                  fontSize: 11,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                          ),
                                                          child: Text(
                                                            'Details',
                                                            style:
                                                                smalltextwhite,
                                                          ),
                                                        ),
                                                        ElevatedButton(
                                                          onPressed:
                                                              () =>
                                                                  _confirmApproveExtension(
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
                                                                  vertical: 6,
                                                                ),
                                                            textStyle:
                                                                TextStyle(
                                                                  fontSize: 11,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                          ),
                                                          child: Text(
                                                            'Approve',
                                                            style:
                                                                smalltextwhite,
                                                          ),
                                                        ),
                                                        OutlinedButton(
                                                          onPressed:
                                                              () =>
                                                                  _confirmRejectExtension(
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
                                                                  vertical: 6,
                                                                ),
                                                            textStyle:
                                                                TextStyle(
                                                                  fontSize: 11,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                          ),
                                                          child: Text('Reject'),
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
