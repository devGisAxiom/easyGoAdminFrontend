import 'package:flutter/material.dart';
import 'package:getbike_admin/controllers/controllers.dart';
import 'package:getbike_admin/models/models.dart';
import 'package:getbike_admin/utils/navigations.dart';
import 'package:getbike_admin/utils/utilities.dart';
import 'package:getbike_admin/views/image.dart';
import 'package:url_launcher/url_launcher.dart';

class SupportPage extends StatefulWidget {
  @override
  State<SupportPage> createState() => _SupportPageState();
}

class _SupportPageState extends State<SupportPage> {
  final SupportController _supportController = SupportController();
  TextEditingController _searchController = TextEditingController();
  List<SupportModel> _supportlist = [];
  List<SupportModel> _filteredSupportList = [];
  bool _isLoading = true;
  int _expandedRowId = -1;

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
      await _supportController.fetchdb();
      _supportlist = List.from(_supportController.supportList);
      _filteredSupportList = List.from(_supportlist);
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
        _filteredSupportList = List.from(_supportlist);
      } else {
        _filteredSupportList =
            _supportlist.where((request) {
              return (request.cName ?? "").toLowerCase().contains(query) ||
                  (request.cId?.toString() ?? "").contains(query) ||
                  (request.cIssuetype ?? "").toLowerCase().contains(query) ||
                  (request.cMessage ?? "").toLowerCase().contains(query);
            }).toList();
      }
    });
  }

  bool _isPdf(String? url) {
    if (url == null) return false;
    return url.toLowerCase().endsWith('.pdf');
  }

  Future<void> _openPdf(String url, String documentType) async {
    try {
      final fullUrl =
          url.startsWith('http')
              ? url
              : "https://lunarsenterprises.com:7006/$url";
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

  Widget _buildDocumentWidget(String? documentUrl, String documentType) {
    final fullUrl =
        documentUrl?.startsWith('http') == true
            ? documentUrl
            : (documentUrl?.startsWith('/') == true
                ? "https://lunarsenterprises.com:7006$documentUrl"
                : "https://lunarsenterprises.com:7006/${documentUrl ?? ''}");

    if (documentUrl == null || documentUrl.isEmpty) {
      return _buildPlaceholderIcon(Icons.document_scanner, 'No $documentType');
    }

    if (_isPdf(documentUrl)) {
      return GestureDetector(
        onTap: () {
          _openPdf(documentUrl, documentType);
        },
        child: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
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
        ),
      );
    } else {
      return GestureDetector(
        onTap: () {
          Navigations.push(ImageView(image: fullUrl ?? ''), context);
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
              fullUrl ?? '',
              width: 50,
              height: 50,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return _buildPlaceholderIcon(Icons.broken_image, 'Error');
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

  String? _getPhoneNumber(SupportModel request) {
    if (request.cPhonenumber != null) {
      if (request.cPhonenumber is String) {
        return request.cPhonenumber as String;
      } else if (request.cPhonenumber is int) {
        return request.cPhonenumber.toString();
      }
    }
    if (request.cPhonenumber != null) {
      if (request.cPhonenumber is String) {
        return request.cPhonenumber as String;
      } else if (request.cPhonenumber is int) {
        return request.cPhonenumber.toString();
      }
    }
    return null;
  }

  void _showSupportDetails(BuildContext context, SupportModel request) {
    final phoneNumber = _getPhoneNumber(request);

    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            insetPadding: EdgeInsets.all(20),
            child: Container(
              constraints: BoxConstraints(
                maxWidth: 600,
                maxHeight: MediaQuery.of(context).size.height * 0.8,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.support_agent,
                          color: Colors.white,
                          size: 24,
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Support Request Details',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Basic Information
                          _buildDetailSection(
                            title: 'Basic Information',
                            children: [
                              _buildDetailRow(
                                'Complaint ID',
                                request.cId?.toString() ?? 'N/A',
                              ),
                              _buildDetailRow(
                                'Username',
                                request.cName ?? 'N/A',
                              ),
                              _buildDetailRow(
                                'Issue Type',
                                request.cIssuetype ?? 'N/A',
                              ),
                              if (phoneNumber != null)
                                _buildDetailRow('Phone Number', phoneNumber),
                            ],
                          ),

                          SizedBox(height: 20),

                          // Description Section
                          _buildDetailSection(
                            title: 'Description',
                            children: [
                              Container(
                                width: double.infinity,
                                padding: EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.grey[50],
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.grey[300]!),
                                ),
                                child: SelectableText(
                                  request.cMessage ?? 'No description provided',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[800],
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 20),

                          // Attachment Section
                          _buildDetailSection(
                            title: 'Attachment',
                            children: [
                              if (request.cImage.isNotEmpty)
                                _buildDocumentWidget(
                                  request.cImage,
                                  'Attachment',
                                )
                              else
                                Text(
                                  'No attachment provided',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Actions
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('Close'),
                        ),
                        SizedBox(width: 12),
                        if (phoneNumber != null && phoneNumber.isNotEmpty)
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              _makePhoneCall(phoneNumber);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.phone, size: 16),
                                SizedBox(width: 6),
                                Text('Call Customer'),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildDetailSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.grey[800],
          ),
        ),
        SizedBox(height: 8),
        ...children,
      ],
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
            child: SelectableText(
              value,
              style: TextStyle(color: Colors.grey[800]),
            ),
          ),
        ],
      ),
    );
  }

  void _toggleRowExpansion(int complaintId) {
    setState(() {
      if (_expandedRowId == complaintId) {
        _expandedRowId = -1;
      } else {
        _expandedRowId = complaintId;
      }
    });
  }

  Widget _buildExpandableDescription(String description, int complaintId) {
    final isExpanded = _expandedRowId == complaintId;
    final displayText = description.isEmpty ? 'No description' : description;

    return Container(
      constraints: BoxConstraints(maxWidth: 200),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Tooltip(
            message: displayText,
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(6),
            ),
            textStyle: TextStyle(color: Colors.white, fontSize: 12),
            child: Text(
              isExpanded
                  ? displayText
                  : (displayText.length > 100
                      ? '${displayText.substring(0, 100)}...'
                      : displayText),
              maxLines: isExpanded ? null : 2,
              overflow:
                  isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
              style: TextStyle(fontSize: 11),
            ),
          ),
          if (displayText.length > 100)
            TextButton(
              onPressed: () => _toggleRowExpansion(complaintId),
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                isExpanded ? 'Show Less' : 'Show More',
                style: TextStyle(
                  fontSize: 10,
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showFullDescription(BuildContext context, String description) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Full Description'),
            content: Container(
              width: double.maxFinite,
              child: SelectableText(
                description.isEmpty ? 'No description provided' : description,
                style: TextStyle(fontSize: 14, height: 1.4),
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

  void _confirmMarkAsSolved(BuildContext context, SupportModel request) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Mark as Solved'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Are you sure you want to mark this support request as solved?',
                ),
                SizedBox(height: 16),
                _buildDetailRow(
                  'Complaint ID',
                  request.cId?.toString() ?? 'N/A',
                ),
                _buildDetailRow('Username', request.cName ?? 'N/A'),
                _buildDetailRow('Issue', request.cIssuetype ?? 'N/A'),
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
                  _markAsSolved(request);
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: Text('Mark as Solved'),
              ),
            ],
          ),
    );
  }

  void _markAsSolved(SupportModel request) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Support request marked as solved'),
        backgroundColor: Colors.green,
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
          'Support Requests',
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
                      'Loading Support Requests...',
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
                        labelText: 'Search Support Requests',
                        hintText: 'Search by username, issue, description...',
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
                          '${_filteredSupportList.length} support request(s)',
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
                          _filteredSupportList.isEmpty
                              ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.support_agent_outlined,
                                      size: 64,
                                      color: Colors.grey[400],
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      _supportlist.isEmpty
                                          ? 'No support requests'
                                          : 'No matching requests found',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    if (_supportlist.isEmpty)
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
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(
                                      minWidth:
                                          MediaQuery.of(context).size.width,
                                      minHeight: 0,
                                    ),
                                    child: DataTable(
                                      columnSpacing: 20,
                                      horizontalMargin: 16,
                                      headingRowHeight: 50,
                                      dataRowMinHeight: 70,
                                      dataRowMaxHeight: 100,
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
                                      columns: const [
                                        DataColumn(label: Text('Complaint ID')),
                                        DataColumn(label: Text('Username')),
                                        DataColumn(label: Text('Issue Type')),
                                        DataColumn(label: Text('Description')),
                                        DataColumn(label: Text('Attachment')),
                                        DataColumn(label: Text('Actions')),
                                      ],
                                      rows:
                                          _filteredSupportList.map((request) {
                                            final phoneNumber = _getPhoneNumber(
                                              request,
                                            );

                                            return DataRow(
                                              cells: [
                                                DataCell(
                                                  Text(
                                                    request.cId?.toString() ??
                                                        '-',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                                DataCell(
                                                  Text(
                                                    request.cName ?? '-',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                                DataCell(
                                                  Text(
                                                    request.cIssuetype ?? '-',
                                                  ),
                                                ),
                                                DataCell(
                                                  _buildExpandableDescription(
                                                    request.cMessage ?? '',
                                                    request.cId ?? -1,
                                                  ),
                                                ),
                                                DataCell(
                                                  Container(
                                                    height: 50,
                                                    child: _buildDocumentWidget(
                                                      request.cImage,
                                                      'Attachment',
                                                    ),
                                                  ),
                                                ),
                                                DataCell(
                                                  Container(
                                                    constraints: BoxConstraints(
                                                      minHeight: 50,
                                                    ),
                                                    child: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        // Quick Description View Button
                                                        IconButton(
                                                          onPressed: () {
                                                            _showFullDescription(
                                                              context,
                                                              request.cMessage ??
                                                                  '',
                                                            );
                                                          },
                                                          icon: Icon(
                                                            Icons.description,
                                                            size: 18,
                                                          ),
                                                          color: Colors.blue,
                                                          tooltip:
                                                              'View full description',
                                                        ),
                                                        SizedBox(width: 4),
                                                        // Details Button
                                                        ElevatedButton(
                                                          onPressed: () {
                                                            _showSupportDetails(
                                                              context,
                                                              request,
                                                            );
                                                          },
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
                                                          child: Text(
                                                            'Details',
                                                          ),
                                                        ),
                                                        SizedBox(width: 8),
                                                        if (phoneNumber !=
                                                                null &&
                                                            phoneNumber
                                                                .isNotEmpty)
                                                          ElevatedButton(
                                                            onPressed: () {
                                                              _makePhoneCall(
                                                                phoneNumber,
                                                              );
                                                            },
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
                                                              textStyle: TextStyle(
                                                                fontSize: 11,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                            child: Text(
                                                              'Call',
                                                              style:
                                                                  smalltextwhite,
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
