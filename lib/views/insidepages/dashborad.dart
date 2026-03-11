import 'package:flutter/material.dart';
import 'package:getbike_admin/controllers/controllers.dart';
import 'package:getbike_admin/utils/navigations.dart';
import 'package:getbike_admin/utils/utilities.dart';
import 'package:getbike_admin/views/home.dart';

class Dashborad extends StatefulWidget {
  Dashborad({super.key});

  @override
  State<Dashborad> createState() => _DashboradState();
}

class _DashboradState extends State<Dashborad> {
  BikeController _bikeController = BikeController();
  MyBookingController _bookingController = MyBookingController();
  UserController _userController = UserController();

  @override
  void initState() {
    super.initState();
    fetchdata();
    // _searchController.addListener(_onSearchChanged);
  }

  Future<void> fetchdata() async {
    await _bikeController.fetchBikes();
    await _bookingController.fetchBikes();

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 243, 243, 243),
      appBar: AppBar(
        title: Text(
          'DashBoard',
          style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  // GestureDetector(
                  //   onTap: (){
                  //     Navigations.push(HomeScreen(navindex: 10,), context);
                  //   },
                  //   child: _dashboardCard(
                  //     image: "assets/images/allbikes.png",
                  //     title: "Total Bikes",
                  //     value: _bikeController.bikeList.length.toString(),
                  //   ),
                  // ),
                  GestureDetector(
                    onTap: () {
                      Navigations.push(HomeScreen(navindex: 3), context);
                    },
                    child: _dashboardCard(
                      image: "assets/images/onride.png",
                      title: "On Ride",
                      value: _bookingController.onrideList.length.toString(),
                    ),
                  ),

                  // _dashboardCard(
                  //   image: "assets/images/activebikes.png",
                  //   title: "Total Bikes",
                  //   value: _bikeController.bikeList.length.toString(),
                  // ),
                  GestureDetector(
                    onTap: () {
                      Navigations.push(HomeScreen(navindex: 1), context);
                    },
                    child: _dashboardCard(
                      image: "assets/images/motorcyclereq.png",
                      title: "New Request",
                      value:
                          _bookingController.bookingReqList.length.toString(),
                    ),
                  ),

                  // _dashboardCard(
                  //   image: "assets/images/inactive.png", // optional: add an icon
                  //   title: "Bikes Not Active",
                  //   value: "1",
                  //   showImage: false, // Hide image if not available
                  // ),
                  GestureDetector(
                    onTap: () {
                      Navigations.push(HomeScreen(navindex: 7), context);
                    },
                    child: _dashboardCard(
                      image: "assets/images/users.png", // optional icon
                      title: "Total Users",
                      value: _userController.userList.length.toString(),
                    ),
                  ),

                  // GestureDetector(
                  //   onTap: (){
                  //     // Navigations.push(HomeScreen(navindex:,), context);

                  //   },
                  //   child: _dashboardCard(
                  //     image: "assets/images/review.png", // optional icon
                  //     title: "Total Reviews",
                  //     value: _bikeController.allReviews.length.toString(),
                  //     showImage: false,
                  //   ),
                  // ),
                  GestureDetector(
                    onTap: () {
                      Navigations.push(HomeScreen(navindex: 2), context);
                    },
                    child: _dashboardCard(
                      image: "assets/images/upcoming.png",
                      title: "Upcoming Rides",
                      value: _bookingController.upcomingList.length.toString(),
                    ),
                  ),

                  GestureDetector(
                    onTap: () {
                      Navigations.push(HomeScreen(navindex: 4), context);
                    },
                    child: _dashboardCard(
                      image: "assets/images/approved.png",
                      title: "Completed Rides",
                      value: _bookingController.completedList.length.toString(),
                    ),
                  ),

                  GestureDetector(
                    onTap: () {
                      Navigations.push(HomeScreen(navindex: 6), context);
                    },
                    child: _dashboardCard(
                      image: "assets/images/x-button.png",
                      title: "Cancelled bookings",
                      value: _bookingController.cancelledList.length.toString(),
                    ),
                  ),

                  // GestureDetector(
                  //   onTap: () {
                  //     Navigations.push(HomeScreen(navindex: 9), context);
                  //   },
                  //   child: _dashboardCard(
                  //     image: "assets/images/review.png",
                  //     title: "Reviews",
                  //     value: _bikeController.allReviews.length.toString(),
                  //   ),
                  // ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dashboardCard({
    required String image,
    required String title,
    required String value,
    bool showImage = true,
  }) {
    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24),
        child: Wrap(
          alignment: WrapAlignment.start,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 16,
          children: [
            if (showImage)
              Container(
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(10.0),
                child: Image.asset(image, width: 50, height: 50),
              ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: normalgrey),
                const SizedBox(height: 10),
                Text(value, style: normalblack),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
