import 'package:flutter/material.dart';
import 'package:getbike_admin/controllers/controllers.dart';
import 'package:getbike_admin/models/models.dart';
import 'package:getbike_admin/utils/utilities.dart';

class FeedbackPage extends StatefulWidget {
  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  BikeController _bikeController = BikeController();
  TextEditingController _searchController = TextEditingController();
  List<BikeReviewModel> _allReviews = [];
  List<BikeReviewModel> _filteredReviews = [];
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
      _allReviews = List.from(_bikeController.allReviews);
      _filteredReviews = List.from(_allReviews);
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
        _filteredReviews = List.from(_allReviews);
      } else {
        _filteredReviews =
            _allReviews.where((review) {
              return (review.uName ?? "").toLowerCase().contains(query) ||
                  (review.brBikeId?.toString() ?? "").contains(query) ||
                  (review.brReview?.toLowerCase() ?? "").contains(query) ||
                  _getBikeName(review.brBikeId).toLowerCase().contains(query);
            }).toList();
      }
    });
  }

  String _getBikeName(int? bikeId) {
    if (bikeId == null) return 'Unknown';
    try {
      final bike = _bikeController.bikeList.firstWhere(
        (b) => b.bId == bikeId,
        orElse:
            () => BikeModel(
              bId: 0,
              bName: 'Unknown',
              bRatings: 0,
              bDescription: '',
              bRentAmount: 0,
              bStatus: '',
              bLocation: '',
              bExtras: '',
              bMilage: "",
              bGeartype: '',
              bFueltype: '',
              bBhp: 0,
              bImage: '',
              bReviews: '',
              distance: 0,
              maxSpeed: 0,
              maintainceStatus: "",
              center: "",
              bikereviews: [],
              bikeimages: [],
              bLatitude: "",
              bLongitude: "",
              bikeCenters: [],
            ),
      );
      return bike.bName;
    } catch (e) {
      return 'Unknown';
    }
  }

  Widget _buildRatingStars(double rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          index < rating ? Icons.star : Icons.star_border,
          color: Colors.amber,
          size: 18,
        );
      }),
    );
  }

  Color _getRatingColor(double rating) {
    if (rating >= 4.0) return Colors.green;
    if (rating >= 3.0) return Colors.orange;
    return Colors.red;
  }

  void _showReviewDetails(BuildContext context, BikeReviewModel review) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'Review Details',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow('Customer Name', review.uName ?? 'N/A'),
                  _buildDetailRow('Bike Name', _getBikeName(review.brBikeId)),
                  _buildDetailRow(
                    'Bike ID',
                    review.brBikeId?.toString() ?? 'N/A',
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Rating:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      _buildRatingStars(review.brRating?.toDouble() ?? 0),
                      SizedBox(width: 8),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getRatingColor(
                            review.brRating?.toDouble() ?? 0,
                          ).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _getRatingColor(
                              review.brRating?.toDouble() ?? 0,
                            ),
                          ),
                        ),
                        child: Text(
                          '${review.brRating?.toStringAsFixed(1) ?? '0.0'}',
                          style: TextStyle(
                            color: _getRatingColor(
                              review.brRating?.toDouble() ?? 0,
                            ),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Review:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: 8),
                  Container(
                    width: double.maxFinite,
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Text(
                      review.brReview ?? 'No review text',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[800],
                        height: 1.4,
                      ),
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
              OutlinedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _confirmDeleteReview(context, review);
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: BorderSide(color: Colors.red),
                ),
                child: Text('Delete Review'),
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

  void _confirmDeleteReview(BuildContext context, BikeReviewModel review) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Delete Review'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Are you sure you want to delete this review?'),
                SizedBox(height: 16),
                _buildDetailRow('Customer', review.uName ?? 'N/A'),
                _buildDetailRow('Bike', _getBikeName(review.brBikeId)),
                _buildDetailRow(
                  'Rating',
                  '${review.brRating?.toString() ?? 'N/A'} stars',
                ),
                SizedBox(height: 8),
                Text(
                  'This action cannot be undone.',
                  style: TextStyle(
                    color: Colors.red[700],
                    fontWeight: FontWeight.w500,
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
                  _deleteReview(review);
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: Text('Delete Review', style: smalltextwhite),
              ),
            ],
          ),
    );
  }

  void _deleteReview(BikeReviewModel review) {
    // TODO: Implement actual delete functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Review from ${review.uName} deleted'),
        backgroundColor: Colors.red,
      ),
    );
    // Remove from local list
    setState(() {
      _allReviews.removeWhere((r) => r.brId == review.brId);
      _filteredReviews.removeWhere((r) => r.brId == review.brId);
    });
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
          'Customer Reviews & Feedback',
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
                      'Loading Reviews...',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                  ],
                ),
              )
              : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                        labelText: 'Search Reviews',
                        hintText:
                            'Search by customer name, bike name, review text...',
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

                  // Results Count and Stats
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${_filteredReviews.length} review(s)',
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
                          _filteredReviews.isEmpty
                              ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.reviews_outlined,
                                      size: 64,
                                      color: Colors.grey[400],
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      _allReviews.isEmpty
                                          ? 'No reviews found'
                                          : 'No matching reviews found',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    if (_allReviews.isEmpty)
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
                              : _buildReviewsTable(),
                    ),
                  ),
                ],
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: fetchdata,
        backgroundColor: primaryColor,
        child: Icon(Icons.refresh, color: Colors.white),
        shape: RoundedRectangleBorder(),
      ),
    );
  }

  Widget _buildReviewsTable() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: constraints.maxWidth),
            child: DataTable(
              columnSpacing: 24,
              horizontalMargin: 16,
              headingRowHeight: 56,
              dataRowMinHeight: 64,
              dataRowMaxHeight:
                  100, // Added max height to prevent constraints issues
              headingRowColor: MaterialStateProperty.all(Colors.grey[50]),
              headingTextStyle: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
                fontSize: 13,
              ),
              dataTextStyle: TextStyle(fontSize: 13, color: Colors.grey[800]),
              columns: const [
                DataColumn(label: Text('BIKE ID')),
                DataColumn(label: Text('BIKE NAME')),
                DataColumn(label: Text('CUSTOMER')),
                DataColumn(label: Text('RATING')),
                DataColumn(label: Text('REVIEW')),
                DataColumn(label: Text('ACTIONS')),
              ],
              rows:
                  _filteredReviews.map((review) {
                    return DataRow(
                      cells: [
                        DataCell(
                          Center(
                            child: Text(
                              review.brBikeId?.toString() ?? '-',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                        DataCell(
                          Container(
                            constraints: BoxConstraints(maxWidth: 120),
                            child: Text(
                              _getBikeName(review.brBikeId),
                              style: TextStyle(fontWeight: FontWeight.w500),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        DataCell(
                          Container(
                            constraints: BoxConstraints(maxWidth: 120),
                            child: Text(
                              review.uName ?? '-',
                              style: TextStyle(fontWeight: FontWeight.w500),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        DataCell(
                          Center(
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: _getRatingColor(
                                  review.brRating?.toDouble() ?? 0,
                                ).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: _getRatingColor(
                                    review.brRating?.toDouble() ?? 0,
                                  ),
                                  width: 1.5,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    review.brRating?.toString() ?? '0',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: _getRatingColor(
                                        review.brRating?.toDouble() ?? 0,
                                      ),
                                      fontSize: 12,
                                    ),
                                  ),
                                  SizedBox(width: 4),
                                  Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                    size: 14,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        DataCell(
                          Container(
                            constraints: BoxConstraints(maxWidth: 200),
                            child: Text(
                              review.brReview ?? 'No review text',
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 12, height: 1.3),
                            ),
                          ),
                        ),
                        DataCell(
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  _showReviewDetails(context, review);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  textStyle: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                                child: Text('View'),
                              ),
                              SizedBox(width: 8),
                              OutlinedButton(
                                onPressed: () {
                                  _confirmDeleteReview(context, review);
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.red,
                                  side: BorderSide(color: Colors.red),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  textStyle: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                                child: Text('Delete'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }).toList(),
            ),
          ),
        );
      },
    );
  }
}
