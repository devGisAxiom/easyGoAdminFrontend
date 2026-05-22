import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:getbike_admin/utils/utilities.dart';
// import 'package:getbike_admin/views/insidepages/bikes.dart';
import 'package:getbike_admin/views/insidepages/bikes.dart';
import 'package:getbike_admin/views/insidepages/bikesonride.dart';
import 'package:getbike_admin/views/insidepages/bookng_req.dart';
import 'package:getbike_admin/views/insidepages/cancellation_reqs.dart';
import 'package:getbike_admin/views/insidepages/cancelledrides.dart';
// hide Upcomingrides from completedrides to avoid duplicate import symbol
import 'package:getbike_admin/views/insidepages/completedrides.dart'
    hide Upcomingrides;
import 'package:getbike_admin/views/insidepages/contact_support.dart';
import 'package:getbike_admin/views/insidepages/dashborad.dart';
// import 'package:getbike_admin/views/insidepages/feedback.dart';
import 'package:getbike_admin/views/insidepages/logout.dart';
import 'package:getbike_admin/views/insidepages/payments.dart';
// import 'package:getbike_admin/views/insidepages/settings.dart';
import 'package:getbike_admin/views/insidepages/upcomingrides.dart';
import 'package:getbike_admin/views/insidepages/users.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sidebarx/sidebarx.dart';

class HomeScreen extends StatefulWidget {
  final int? navindex; // ✅ added like in LeftBar

  const HomeScreen({Key? key, this.navindex}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late SidebarXController _controller; // ✅ late initialization
  final _key = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();

    // ✅ initialize controller with passed navindex (like LeftBar)
    _controller = SidebarXController(
      selectedIndex: widget.navindex ?? 0,
      extended: true,
    );

    fetchAdmin();
  }

  String? adminName;
  String? adminEmail;

  Future<void> fetchAdmin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      adminName = prefs.getString('adminName') ?? "Admin";
      adminEmail = prefs.getString('adminEmail') ?? "admin@getbike.com";
    });
  }

  final List<String> labels = [
    "Dashboard",
    "Booking Requests",
    "Bikes Onride",
    "Upcoming Rides",
    "Completed Rides",
    "Cancelled Rides",
    "Cancellation Requests",
    "Users",
    // "Feedback",
    "Payments",
    // "Vehicles",
    "Settings",
    // "Support",
    "Logout",
  ];

  final List<IconData> icons = [
    Icons.dashboard,
    Icons.assignment,
    Icons.access_time_rounded,
    Icons.directions_bike_rounded,
    Icons.check_box,
    Icons.error,
    Icons.close,
    Icons.people,
    Icons.bar_chart,
    // Icons.payment,
    // Icons.directions_bike,
    Icons.settings,
    // Icons.support,
    Icons.logout,
  ];

  final List<Widget> pages = [
    Dashborad(),
    BookingRequests(),
    Upcomingrides(), // from upcomingrides.dart (unambiguous now)
    BikesOnride(),

    CompletedRides(),
    // _MissingPage(title: 'Completed Rides'),
    CancelledRides(),
    CancellationRequests(),
    UserListPage(),
    // FeedbackPage(),
    PaymentList(),
    VehiclesList(),
    // SettingsPage(),
    SupportPage(),
    Logout(),
  ];

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 700;

    // Wrap Scaffold with ScrollConfiguration to allow mouse dragging on scrollables
    return ScrollConfiguration(
      behavior: _DesktopDragScrollBehavior(),
      child: Scaffold(
        key: _key,
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  "assets/images/getbikelogo.png",
                  height: 40,
                  width: 40,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  "Easy Go Admin Panel",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10.0,
                  vertical: 5.0,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.person, color: Colors.black54),
                    const SizedBox(width: 8),
                    Text(
                      adminName ?? "Admin",
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          leading:
              isSmallScreen
                  ? IconButton(
                    icon: const Icon(Icons.menu, color: Colors.black),
                    onPressed: () {
                      _key.currentState?.openDrawer();
                    },
                  )
                  : null,
        ),
        drawer: isSmallScreen ? ExampleSidebarX(controller: _controller) : null,
        body: Row(
          children: [
            if (!isSmallScreen) ExampleSidebarX(controller: _controller),
            Expanded(
              child: Center(
                child: _ScreensExample(controller: _controller, pages: pages),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ExampleSidebarX extends StatelessWidget {
  const ExampleSidebarX({Key? key, required SidebarXController controller})
    : _controller = controller,
      super(key: key);

  final SidebarXController _controller;

  @override
  Widget build(BuildContext context) {
    final List<String> labels = [
      "Dashboard",
      "Booking Requests",
      "Upcoming Rides",
      "Bikes Onride",

      "Completed Rides",
      "Cancelled Rides",
      "Cancellation Requests",
      "Users",
      // "Feedback",
      "Payment Reports",
      // "Vehicles",
      // "Settings",
      "Manage Bikes",
      "Support",
      "Logout",
    ];

    final List<IconData> icons = [
      Icons.dashboard,
      Icons.assignment,
      Icons.access_time_rounded,
      Icons.directions_bike_rounded,
      Icons.check_box,
      Icons.error,
      Icons.close,
      Icons.people,
      Icons.bar_chart,
      // Icons.payment,
      // Icons.directions_bike,
      // Icons.settings,/
      Icons.two_wheeler,
      Icons.support,
      Icons.logout,
    ];

    return SidebarX(
      controller: _controller,
      theme: SidebarXTheme(
        margin: const EdgeInsets.all(24),
        decoration: const BoxDecoration(color: Colors.white),
        hoverColor: Colors.grey.shade200,
        textStyle: const TextStyle(color: Colors.black87),
        selectedTextStyle: const TextStyle(color: Colors.white),
        selectedItemDecoration: BoxDecoration(
          color: primaryColor,
          borderRadius: BorderRadius.circular(10),
        ),
        iconTheme: IconThemeData(color: Colors.black.withOpacity(0.7)),
        selectedIconTheme: const IconThemeData(color: Colors.white),
      ),
      extendedTheme: const SidebarXTheme(
        width: 250,
        itemPadding: EdgeInsets.all(4),
        itemTextPadding: EdgeInsets.all(10),
        selectedItemPadding: EdgeInsets.all(4),
        selectedItemTextPadding: EdgeInsets.all(10),
      ),

      items: List.generate(labels.length, (index) {
        return SidebarXItem(
          icon: icons[index],
          label: labels[index],
          onTap: () {
            if (labels[index] == "Logout") {
              showDialog(
                context: context,
                builder:
                    (context) => AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        // color: Colors.white,
                      ),
                      title: const Text("Logout"),
                      content: const Text("Are you sure you want to logout?"),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _controller.selectIndex(0);
                          },
                          child: const Text("No"),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            Navigator.pop(context);
                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            await prefs.clear();
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (_) => Logout(),
                              ), // redirect to logout page
                              (route) => false,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          child: const Text("Yes"),
                        ),
                      ],
                    ),
              );
            }
          },
        );
      }),
    );
  }
}

class _ScreensExample extends StatelessWidget {
  const _ScreensExample({
    Key? key,
    required this.controller,
    required this.pages,
  }) : super(key: key);

  final SidebarXController controller;
  final List<Widget> pages;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final index = controller.selectedIndex;
        if (index >= 0 && index < pages.length) {
          return pages[index];
        } else {
          return const Center(
            child: Text("Page not found", style: TextStyle(fontSize: 20)),
          );
        }
      },
    );
  }
}

// Add this custom ScrollBehavior so mouse can drag scroll (useful for horizontal tables)
class _DesktopDragScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.stylus,
    PointerDeviceKind.unknown,
  };
}

// Simple fallback widget to show when a specific page widget/class is missing.
class _MissingPage extends StatelessWidget {
  final String title;
  const _MissingPage({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        '$title page not available',
        style: const TextStyle(fontSize: 18, color: Colors.black54),
      ),
    );
  }
}
