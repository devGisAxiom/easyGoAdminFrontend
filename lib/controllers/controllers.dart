import 'dart:convert';
import 'package:getbike_admin/APIs/apis.dart';
import 'package:getbike_admin/models/models.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class BikeController {
  List<BikeModel> bikeList = [];
  List<BikeModel> topRatedBikes = [];
  List<BikeReviewModel> allReviews = [];

  Future<void> fetchBikes() async {
    final url = Uri.parse(AllBikesAPI);

    // Get token from SharedPreferences
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString("token");

    // Print token
    print("Token for fetchBikes: $token");

    if (token == null) {
      print("Token not found in SharedPreferences");
      return;
    }

    try {
      print(url);
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print("sts code : ${response.statusCode}");

      if (response.statusCode == 200) {
        final decodedData = json.decode(response.body);
        print("Response : $response");
        print(decodedData);

        if (decodedData['result'] == true && decodedData['list'] != null) {
          final List<dynamic> dataList = decodedData['list'];

          bikeList = dataList.map((bike) => BikeModel.fromJson(bike)).toList();

          // ✅ Gather all reviews from all bikes
          allReviews = bikeList.expand((bike) => bike.bikereviews).toList();

          // ✅ Sort bikeList by rating (descending) and take top 4
          bikeList.sort((a, b) {
            final bRating = b.bRatings ?? 0.0;
            final aRating = a.bRatings ?? 0.0;
            return bRating.compareTo(aRating);
          });
          topRatedBikes = bikeList.take(4).toList();

          print("Top Rated Bikes:");
          for (var bike in topRatedBikes) {
            print("${bike.bName} - Rating: ${bike.bRatings}");
          }

          print("Total Reviews: ${allReviews.length}");
        } else {
          bikeList = [];
          topRatedBikes = [];
          allReviews = [];
        }
      } else if (response.statusCode == 401) {
        print("Unauthorized - Token might be expired");
        // You might want to handle token refresh or logout here
      } else {
        print("Failed to load bikes: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching bikes: $e");
    }
  }
}

class MyBookingController {
  List<BookingModel> bookingReqList = [];
  List<BookingModel> onrideList = [];
  List<BookingModel> completedList = [];
  List<BookingModel> upcomingList = [];
  List<BookingModel> cancelledList = [];
  List<BookingModel> cancelreq = [];
  List<BookingModel> Extendbookingreq = [];

  Future<void> fetchBikes() async {
    final url = Uri.parse(MybookingAPI);

    // Get token from SharedPreferences
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString("token");

    // Print token
    print("Token for fetchBikes (MyBooking): $token");

    if (token == null) {
      print("Token not found in SharedPreferences");
      return;
    }

    try {
      print(url);
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        // body: jsonEncode({"user_id": user_id}),
      );

      print("sts code : ${response.statusCode}");

      if (response.statusCode == 200) {
        final decodedData = json.decode(response.body);
        print("Response : ${response.body}");

        if (decodedData['result'] == true && decodedData['list'] != null) {
          final List<dynamic> dataList = decodedData['list'];
          List<BookingModel> mybookingList =
              dataList.map((bike) => BookingModel.fromJson(bike)).toList();

          // Separate lists based on status
          bookingReqList =
              mybookingList
                  .where((bike) => bike.bStatus?.toLowerCase() == "pending")
                  .toList();

          onrideList =
              mybookingList
                  .where((bike) => bike.bStatus?.toLowerCase() == "onride")
                  .toList();

          completedList =
              mybookingList
                  .where((bike) => bike.bStatus?.toLowerCase() == "completed")
                  .toList();

          upcomingList =
              mybookingList
                  .where((bike) => bike.bStatus?.toLowerCase() == "approved")
                  .toList();

          cancelledList =
              mybookingList
                  .where((bike) => bike.bStatus?.toLowerCase() == "cancelled")
                  .toList();

          cancelreq =
              mybookingList
                  .where((bike) => bike.bStatus?.toLowerCase() == "cancelreq")
                  .toList();

          Extendbookingreq =
              mybookingList
                  .where((bike) => bike.bStatus?.toLowerCase() == "extendedreq")
                  .toList();
        } else {
          bookingReqList = [];
          onrideList = [];
          completedList = [];
          upcomingList = [];
          cancelledList = [];
          cancelreq = [];
          Extendbookingreq = [];
        }
      } else if (response.statusCode == 401) {
        print("Unauthorized - Token might be expired");
      } else {
        print("Failed to load bikes: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching bikes: $e");
    }
  }
}

class NotificationController {
  List<NotificationModel> notificationList = [];

  Future<void> fetchNotifications() async {
    final url = Uri.parse(NotificationAPI);

    // Get token from SharedPreferences
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString("token");

    // Print token
    print("Token for fetchNotifications: $token");

    if (token == null) {
      print("Token not found in SharedPreferences");
      return;
    }

    try {
      print(url);
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        // body: jsonEncode(data),
      );

      print("Status code : ${response.statusCode}");

      if (response.statusCode == 200) {
        final decodedData = json.decode(response.body);
        print("Response body: ${response.body}");

        if (decodedData['result'] == true && decodedData['list'] != null) {
          final List<dynamic> dataList = decodedData['list'];
          notificationList =
              dataList.map((item) => NotificationModel.fromJson(item)).toList();
        } else {
          notificationList = [];
        }
      } else if (response.statusCode == 401) {
        print("Unauthorized - Token might be expired");
      } else {
        print("Failed to load notifications: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching notifications: $e");
    }
  }
}

class UserController {
  List<UserModel> userList = [];

  Future<void> fetchuser() async {
    final url = Uri.parse(GetUserAPI);

    // Get token from SharedPreferences
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString("token");

    // Print token
    print("Token for fetchuser: $token");

    if (token == null) {
      print("Token not found in SharedPreferences");
      return;
    }

    try {
      print(url);
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        // body: jsonEncode(data),
      );

      print("Status code : ${response.statusCode}");

      if (response.statusCode == 200) {
        final decodedData = json.decode(response.body);
        print("Response body: ${response.body}");

        if (decodedData['result'] == true && decodedData['list'] != null) {
          final List<dynamic> dataList = decodedData['list'];
          userList = dataList.map((item) => UserModel.fromJson(item)).toList();
        } else {
          userList = [];
        }
      } else if (response.statusCode == 401) {
        print("Unauthorized - Token might be expired");
      } else {
        print("Failed to load users: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching users: $e");
    }
  }
}

class SupportController {
  List<SupportModel> supportList = [];

  Future<void> fetchdb() async {
    final url = Uri.parse(GetSupportAPI);

    // Get token from SharedPreferences
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString("token");

    // Print token
    print("Token for fetchdb (Support): $token");

    if (token == null) {
      print("Token not found in SharedPreferences");
      return;
    }

    try {
      print(url);
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        // body: jsonEncode(data),
      );

      print("Status code : ${response.statusCode}");

      if (response.statusCode == 200) {
        final decodedData = json.decode(response.body);
        print("Response body: ${response.body}");

        if (decodedData['result'] == true && decodedData['list'] != null) {
          final List<dynamic> dataList = decodedData['list'];
          supportList =
              dataList.map((item) => SupportModel.fromJson(item)).toList();
        } else {
          supportList = [];
        }
      } else if (response.statusCode == 401) {
        print("Unauthorized - Token might be expired");
      } else {
        print("Failed to load support data: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching support data: $e");
    }
  }
}

class CentersController {
  List<BikeCenters> centersList = [];

  Future<void> fetchdb() async {
    final url = Uri.parse(BikeCentersAPI);

    // Get token from SharedPreferences
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString("token");

    // Print token
    print("Token for fetchdb (Centers): $token");

    if (token == null) {
      print("Token not found in SharedPreferences");
      return;
    }

    try {
      print(url);
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        // body: jsonEncode(data),
      );

      print("Status code : ${response.statusCode}");

      if (response.statusCode == 200) {
        final decodedData = json.decode(response.body);
        print("Response body: ${response.body}");

        if (decodedData['result'] == true && decodedData['list'] != null) {
          final List<dynamic> dataList = decodedData['list'];
          centersList =
              dataList.map((item) => BikeCenters.fromJson(item)).toList();
        } else {
          centersList = [];
        }
      } else if (response.statusCode == 401) {
        print("Unauthorized - Token might be expired");
      } else {
        print("Failed to load centers: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching centers: $e");
    }
  }
}

class AllCentersController {
  List<LocationModel> centerslocationList = [];

  Future<void> fetchdb() async {
    final url = Uri.parse(BikeCentersAPI);

    // Get token from SharedPreferences
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString("token");

    // Print token
    print("Token for fetchdb (AllCenters): $token");

    if (token == null) {
      print("Token not found in SharedPreferences");
      return;
    }

    try {
      print(url);
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print("Status code : ${response.statusCode}");

      if (response.statusCode == 200) {
        final decodedData = json.decode(response.body);
        print("Response body: ${response.body}");

        // Correct way to handle the response
        final locationResponse = LocationListResponse.fromJson(decodedData);

        if (locationResponse.result) {
          centerslocationList = locationResponse.list;
        } else {
          centerslocationList = [];
          print("API returned false result: ${locationResponse.message}");
        }
      } else if (response.statusCode == 401) {
        print("Unauthorized - Token might be expired");
        centerslocationList = [];
      } else {
        print("Failed to load centers: ${response.statusCode}");
        centerslocationList = [];
      }
    } catch (e) {
      print("Error fetching centers: $e");
      centerslocationList = [];
    }
  }
}
