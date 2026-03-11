import 'package:flutter/material.dart';
import 'package:getbike_admin/controllers/controllers.dart';
import 'package:getbike_admin/models/models.dart';
import 'package:getbike_admin/utils/navigations.dart';
import 'package:getbike_admin/utils/utilities.dart';
import 'package:getbike_admin/views/image.dart';
import 'package:url_launcher/url_launcher.dart';

class UserListPage extends StatefulWidget {
  @override
  State<UserListPage> createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  UserController _userController = UserController();
  TextEditingController _searchController = TextEditingController();
  List<UserModel> _users = [];
  List<UserModel> _filteredUsers = [];
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
      await _userController.fetchuser();
      _users = List.from(_userController.userList);
      _filteredUsers = List.from(_users);
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
        _filteredUsers = List.from(_users);
      } else {
        _filteredUsers =
            _users.where((user) {
              return (user.uName ?? "").toLowerCase().contains(query) ||
                  (user.uId?.toString() ?? "").contains(query) ||
                  (user.uEmail ?? "").toLowerCase().contains(query) ||
                  (user.uMobile?.toString() ?? "").contains(query);
            }).toList();
      }
    });
  }

  // Format date if available
  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return '-';

    try {
      final date = DateTime.parse(dateString);
      final day = date.day.toString().padLeft(2, '0');
      final month = date.month.toString().padLeft(2, '0');
      final year = date.year;

      return '$day - $month - $year';
    } catch (e) {
      return dateString;
    }
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

    // Remove leading slash if present to avoid double slashes
    String cleanPath =
        imagePath.startsWith('/') ? imagePath.substring(1) : imagePath;

    return '$baseUrl/$cleanPath';
  }

  Widget _buildDocumentWidget(
    String? documentUrl,
    String documentType,
    double size,
  ) {
    final fullUrl = _getFullImageUrl(documentUrl);
    if (documentUrl == null || documentUrl.isEmpty) {
      return _buildPlaceholderIcon(
        Icons.document_scanner,
        'No $documentType',
        size,
      );
    }

    return GestureDetector(
      onTap: () {
        Navigations.push(ImageView(image: fullUrl), context);
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!, width: 2),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Image.network(
            fullUrl,
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return _buildPlaceholderIcon(
                Icons.broken_image,
                'Error loading image',
                size,
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
                  strokeWidth: 2,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderIcon(IconData icon, String tooltip, double size) {
    return Tooltip(
      message: tooltip,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!, width: 2),
        ),
        child: Icon(icon, color: Colors.grey, size: size * 0.4),
      ),
    );
  }

  // Show all documents in a popup/dialog
  void _showAllDocuments(UserModel user) {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              constraints: BoxConstraints(maxWidth: 600),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Container(
                      padding: EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.folder_open,
                            color: primaryColor,
                            size: 28,
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'All Documents',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[800],
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: Icon(Icons.close, size: 24),
                          ),
                        ],
                      ),
                    ),

                    // User Info
                    Container(
                      padding: EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: primaryColor.withOpacity(0.1),
                                child: Icon(Icons.person, color: primaryColor),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      user.uName ?? 'N/A',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey[800],
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'User ID: ${user.uId ?? 'N/A'}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 24),

                          // Profile Picture
                          _buildDocumentSection(
                            'Profile Picture',
                            user.uProfilePic,
                            Icons.person,
                            120,
                          ),

                          // License Documents
                          if (user.uLicensefront != null ||
                              user.uLicenseback != null)
                            _buildLicenseSection(user),

                          // Aadhaar Documents
                          if (user.uAdharfront != null ||
                              user.uAddarback != null)
                            _buildAadhaarSection(user),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
    );
  }

  Widget _buildLicenseSection(UserModel user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 16),
        Text(
          'License Documents',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        SizedBox(height: 8),

        // License Front & Back in Row
        Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  Text(
                    'Front',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 8),
                  _buildDocumentWidget(
                    user.uLicensefront,
                    'License Front',
                    140,
                  ),
                  if (user.uLicensefront.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        _getFileName(user.uLicensefront),
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(width: 20),
            Expanded(
              child: Column(
                children: [
                  Text(
                    'Back',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 8),
                  _buildDocumentWidget(user.uLicenseback, 'License Back', 140),
                  if (user.uLicenseback.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        _getFileName(user.uLicenseback),
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 24),
      ],
    );
  }

  Widget _buildAadhaarSection(UserModel user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 16),
        Text(
          'Aadhaar Documents',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        SizedBox(height: 8),

        // Aadhaar Front & Back in Row
        Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  Text(
                    'Front',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 8),
                  _buildDocumentWidget(user.uAdharfront, 'Aadhaar Front', 140),
                  if (user.uAdharfront.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        _getFileName(user.uAdharfront),
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(width: 20),
            Expanded(
              child: Column(
                children: [
                  Text(
                    'Back',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 8),
                  _buildDocumentWidget(user.uAddarback, 'Aadhaar Back', 140),
                  if (user.uAddarback.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        _getFileName(user.uAddarback),
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 24),
      ],
    );
  }

  Widget _buildDocumentSection(
    String title,
    String? documentUrl,
    IconData icon,
    double size,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: primaryColor, size: 20),
            SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        Center(child: _buildDocumentWidget(documentUrl, title, size)),
        if (documentUrl != null && documentUrl.isNotEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                _getFileName(documentUrl),
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ),
          ),
        SizedBox(height: 24),
      ],
    );
  }

  String _getFileName(String url) {
    try {
      return url.split('/').last;
    } catch (e) {
      return 'Document';
    }
  }

  // Check if user has any documents
  bool _hasDocuments(UserModel user) {
    return user.uProfilePic != null && user.uProfilePic!.isNotEmpty ||
        user.uLicensefront != null && user.uLicensefront!.isNotEmpty ||
        user.uLicenseback != null && user.uLicenseback!.isNotEmpty ||
        user.uAdharfront != null && user.uAdharfront!.isNotEmpty ||
        user.uAddarback != null && user.uAddarback!.isNotEmpty;
  }

  // Count total documents for a user
  int _countDocuments(UserModel user) {
    int count = 0;
    if (user.uProfilePic != null && user.uProfilePic!.isNotEmpty) count++;
    if (user.uLicensefront != null && user.uLicensefront!.isNotEmpty) count++;
    if (user.uLicenseback != null && user.uLicenseback!.isNotEmpty) count++;
    if (user.uAdharfront != null && user.uAdharfront!.isNotEmpty) count++;
    if (user.uAddarback != null && user.uAddarback!.isNotEmpty) count++;
    return count;
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not launch phone app'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error making call: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _confirmDeleteUser(BuildContext context, UserModel user) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(Icons.warning, color: Colors.orange, size: 28),
                SizedBox(width: 12),
                Text(
                  'Delete User',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            content: Container(
              constraints: BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Are you sure you want to delete this user?',
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  ),
                  SizedBox(height: 20),
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDetailRow('Name', user.uName ?? 'N/A'),
                        _buildDetailRow('Email', user.uEmail ?? 'N/A'),
                        _buildDetailRow(
                          'User ID',
                          user.uId?.toString() ?? 'N/A',
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    '⚠️ This action cannot be undone.',
                    style: TextStyle(
                      color: Colors.red[700],
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: Text(
                  'Cancel',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _deleteUser(user);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Delete User',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 14, color: Colors.grey[800]),
            ),
          ),
        ],
      ),
    );
  }

  void _deleteUser(UserModel user) {
    // TODO: Implement actual delete functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("User ${user.uName} deleted successfully"),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
    fetchdata();
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
          'User Management',
          style: TextStyle(
            color: primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 3,
        iconTheme: IconThemeData(color: primaryColor, size: 28),
        centerTitle: true,
      ),
      body:
          _isLoading
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                      strokeWidth: 4,
                    ),
                    SizedBox(height: 24),
                    Text(
                      'Loading Users...',
                      style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                    ),
                  ],
                ),
              )
              : Column(
                children: [
                  // Search Section
                  Container(
                    padding: EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 60,
                            child: TextField(
                              controller: _searchController,
                              decoration: InputDecoration(
                                labelText: 'Search Users',
                                labelStyle: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                                hintText: 'Search by name, email, phone, ID...',
                                hintStyle: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[400],
                                ),
                                prefixIcon: Icon(
                                  Icons.search,
                                  color: primaryColor,
                                  size: 28,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(
                                    color: Colors.grey[300]!,
                                    width: 2,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(
                                    color: primaryColor,
                                    width: 3,
                                  ),
                                ),
                                filled: true,
                                fillColor: Colors.grey[50],
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 18,
                                ),
                              ),
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                        SizedBox(width: 16),
                        if (_searchController.text.isNotEmpty)
                          ElevatedButton(
                            onPressed: () {
                              _searchController.clear();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[200],
                              foregroundColor: Colors.grey[700],
                              padding: EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 18,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Text(
                              'Clear',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Results Count and Stats
                  Container(
                    padding: EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Total Users: ${_users.length}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[800],
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Showing: ${_filteredUsers.length} user(s)',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        ElevatedButton.icon(
                          onPressed: fetchdata,
                          icon: Icon(Icons.refresh, size: 20),
                          label: Text(
                            'Refresh Data',
                            style: TextStyle(fontSize: 16),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Data Table
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child:
                          _filteredUsers.isEmpty
                              ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.people_outline,
                                      size: 100,
                                      color: Colors.grey[400],
                                    ),
                                    SizedBox(height: 24),
                                    Text(
                                      _users.isEmpty
                                          ? 'No users found in the system'
                                          : 'No matching users found',
                                      style: TextStyle(
                                        fontSize: 20,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    SizedBox(height: 12),
                                    if (_users.isEmpty)
                                      ElevatedButton(
                                        onPressed: fetchdata,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: primaryColor,
                                          foregroundColor: Colors.white,
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 32,
                                            vertical: 16,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                        ),
                                        child: Text(
                                          'Refresh Data',
                                          style: TextStyle(fontSize: 16),
                                        ),
                                      ),
                                  ],
                                ),
                              )
                              : Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 12,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.vertical,
                                  child: DataTable(
                                    columnSpacing: 32,
                                    horizontalMargin: 32,
                                    headingRowHeight: 70,
                                    dataRowMinHeight: 80,
                                    dataRowMaxHeight: 90,
                                    headingRowColor: MaterialStateProperty.all(
                                      Colors.grey[50],
                                    ),
                                    headingTextStyle: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[700],
                                      fontSize: 16,
                                      letterSpacing: 0.5,
                                    ),
                                    dataTextStyle: TextStyle(
                                      fontSize: 15,
                                      color: Colors.grey[800],
                                    ),
                                    columns: const [
                                      DataColumn(
                                        label: Text('User ID'),
                                        numeric: true,
                                      ),
                                      DataColumn(label: Text('Name')),
                                      DataColumn(label: Text('Email')),
                                      DataColumn(
                                        label: Text('Phone'),
                                        numeric: true,
                                      ),
                                      DataColumn(label: Text('Date of Birth')),
                                      DataColumn(label: Text('Documents')),
                                      DataColumn(label: Text('Actions')),
                                    ],
                                    rows:
                                        _filteredUsers.map((user) {
                                          final documentCount = _countDocuments(
                                            user,
                                          );
                                          return DataRow(
                                            cells: [
                                              DataCell(
                                                Container(
                                                  padding: EdgeInsets.all(12),
                                                  child: Text(
                                                    user.uId?.toString() ?? '-',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 15,
                                                      color: primaryColor,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              DataCell(
                                                Container(
                                                  padding: EdgeInsets.all(12),
                                                  child: Text(
                                                    user.uName ?? '-',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 15,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              DataCell(
                                                Container(
                                                  width: 220,
                                                  padding: EdgeInsets.all(12),
                                                  child: Text(
                                                    user.uEmail ?? '-',
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      fontSize: 15,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              DataCell(
                                                Container(
                                                  padding: EdgeInsets.all(12),
                                                  child: Text(
                                                    user.uMobile?.toString() ??
                                                        '-',
                                                    style: TextStyle(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              DataCell(
                                                Container(
                                                  padding: EdgeInsets.all(12),
                                                  child: Text(
                                                    _formatDate(
                                                      user.uDob.toString(),
                                                    ),
                                                    style: TextStyle(
                                                      fontSize: 15,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              // Documents Cell
                                              DataCell(
                                                Container(
                                                  padding: EdgeInsets.all(12),
                                                  child: ElevatedButton.icon(
                                                    onPressed:
                                                        _hasDocuments(user)
                                                            ? () =>
                                                                _showAllDocuments(
                                                                  user,
                                                                )
                                                            : null,
                                                    icon: Icon(
                                                      Icons.folder_open,
                                                      size: 18,
                                                      color:
                                                          _hasDocuments(user)
                                                              ? Colors.blue[700]
                                                              : Colors
                                                                  .grey[500],
                                                    ),
                                                    label: Text(
                                                      '$documentCount Docs',
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor:
                                                          _hasDocuments(user)
                                                              ? Colors.blue[50]
                                                              : Colors
                                                                  .grey[100],
                                                      foregroundColor:
                                                          _hasDocuments(user)
                                                              ? Colors.blue[700]
                                                              : Colors
                                                                  .grey[500],
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                            horizontal: 16,
                                                            vertical: 12,
                                                          ),
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              12,
                                                            ),
                                                        side: BorderSide(
                                                          color:
                                                              _hasDocuments(
                                                                    user,
                                                                  )
                                                                  ? Colors
                                                                      .blue[100]!
                                                                  : Colors
                                                                      .grey[200]!,
                                                          width: 2,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              DataCell(
                                                Container(
                                                  padding: EdgeInsets.all(12),
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      // Details button
                                                      ElevatedButton(
                                                        onPressed: () {
                                                          // Add details functionality
                                                        },
                                                        style: ElevatedButton.styleFrom(
                                                          backgroundColor:
                                                              Colors.blue,
                                                          foregroundColor:
                                                              Colors.white,
                                                          padding:
                                                              EdgeInsets.symmetric(
                                                                horizontal: 20,
                                                                vertical: 14,
                                                              ),
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  10,
                                                                ),
                                                          ),
                                                        ),
                                                        child: Row(
                                                          children: [
                                                            Icon(
                                                              Icons
                                                                  .info_outline,
                                                              size: 18,
                                                            ),
                                                            SizedBox(width: 6),
                                                            Text(
                                                              'Details',
                                                              style: TextStyle(
                                                                fontSize: 14,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      SizedBox(width: 12),

                                                      // Call button (if mobile exists)
                                                      if (user.uMobile != null)
                                                        ElevatedButton(
                                                          onPressed: () {
                                                            _makePhoneCall(
                                                              user.uMobile
                                                                  .toString(),
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
                                                                      20,
                                                                  vertical: 14,
                                                                ),
                                                            shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    10,
                                                                  ),
                                                            ),
                                                          ),
                                                          child: Row(
                                                            children: [
                                                              Icon(
                                                                Icons.call,
                                                                size: 18,
                                                              ),
                                                              SizedBox(
                                                                width: 6,
                                                              ),
                                                              Text(
                                                                'Call',
                                                                style:
                                                                    TextStyle(
                                                                      fontSize:
                                                                          14,
                                                                    ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      SizedBox(width: 12),

                                                      // Delete button
                                                      OutlinedButton(
                                                        onPressed: () {
                                                          _confirmDeleteUser(
                                                            context,
                                                            user,
                                                          );
                                                        },
                                                        style: OutlinedButton.styleFrom(
                                                          foregroundColor:
                                                              Colors.red,
                                                          side: BorderSide(
                                                            color: Colors.red,
                                                            width: 2,
                                                          ),
                                                          padding:
                                                              EdgeInsets.symmetric(
                                                                horizontal: 20,
                                                                vertical: 14,
                                                              ),
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  10,
                                                                ),
                                                          ),
                                                        ),
                                                        child: Row(
                                                          children: [
                                                            Icon(
                                                              Icons
                                                                  .delete_outline,
                                                              size: 18,
                                                            ),
                                                            SizedBox(width: 6),
                                                            Text(
                                                              'Delete',
                                                              style: TextStyle(
                                                                fontSize: 14,
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
                ],
              ),
    );
  }
}
