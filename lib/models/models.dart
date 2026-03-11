class BikeResponse {
  bool result;
  String message;
  List<BikeModel> list;

  BikeResponse({
    required this.result,
    required this.message,
    required this.list,
  });

  factory BikeResponse.fromJson(Map<String, dynamic> json) {
    return BikeResponse(
      result: json["result"] as bool? ?? false,
      message: json["message"] as String? ?? "",
      list:
          (json["list"] as List<dynamic>? ?? [])
              .map((x) => BikeModel.fromJson(x as Map<String, dynamic>))
              .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'result': result,
      'message': message,
      'list': list.map((e) => e.toJson()).toList(),
    };
  }
}

class BikeModel {
  int bId;
  String bName;
  double bRatings;
  String bDescription;
  double bRentAmount;
  String bStatus;
  String bLocation;
  String bLatitude;
  String bLongitude;
  String bExtras;
  String bMilage;
  String bGeartype;
  String bFueltype;
  double bBhp;
  String? bImage;
  String bReviews;
  double distance;
  double maxSpeed;
  String maintainceStatus;
  String center;
  List<BikeReviewModel> bikereviews;
  List<BikeImageModel> bikeimages;
  List<BikeCenterModel> bikeCenters;

  BikeModel({
    required this.bId,
    required this.bName,
    required this.bRatings,
    required this.bDescription,
    required this.bRentAmount,
    required this.bStatus,
    required this.bLocation,
    required this.bLatitude,
    required this.bLongitude,
    required this.bExtras,
    required this.bMilage,
    required this.bGeartype,
    required this.bFueltype,
    required this.bBhp,
    this.bImage,
    required this.bReviews,
    required this.distance,
    required this.maxSpeed,
    required this.maintainceStatus,
    required this.center,
    required this.bikereviews,
    required this.bikeimages,
    required this.bikeCenters,
  });

  factory BikeModel.fromJson(Map<String, dynamic> json) {
    return BikeModel(
      bId: _parseInt(json["b_id"]),
      bName: _parseString(json["b_name"]),
      bRatings: _parseDouble(json["b_ratings"]),
      bDescription: _parseString(json["b_description"]),
      bRentAmount: _parseDouble(json["b_price"]),
      bStatus: _parseString(json["b_status"]),
      bLocation: _parseString(json["b_location"]),
      bLatitude: _parseString(json["b_latitude"]),
      bLongitude: _parseString(json["b_longitude"]),
      bExtras: _parseString(json["b_extras"]),
      bMilage: _parseString(json["b_milage"]),
      bGeartype: _parseString(json["b_geartype"]),
      bFueltype: _parseString(json["b_fueltype"]),
      bBhp: _parseDouble(json["b_bhp"]),
      bImage: json["b_image"] as String?,
      bReviews: _parseString(json["b_reviews"]),
      distance: _parseDouble(json["distance"]),
      maxSpeed: _parseDouble(json["max_speed"]),
      maintainceStatus: _parseString(json["maintaince_status"]),
      center: _parseString(json["center"]),
      bikereviews:
          (json["bikereviews"] as List<dynamic>? ?? [])
              .map((x) => BikeReviewModel.fromJson(x as Map<String, dynamic>))
              .toList(),
      bikeimages:
          (json["bikeimages"] as List<dynamic>? ?? [])
              .map((x) => BikeImageModel.fromJson(x as Map<String, dynamic>))
              .toList(),
      bikeCenters:
          (json["bike_centers"] as List<dynamic>? ?? [])
              .map((x) => BikeCenterModel.fromJson(x as Map<String, dynamic>))
              .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'b_id': bId,
      'b_name': bName,
      'b_ratings': bRatings,
      'b_description': bDescription,
      'b_price': bRentAmount,
      'b_status': bStatus,
      'b_location': bLocation,
      'b_latitude': bLatitude,
      'b_longitude': bLongitude,
      'b_extras': bExtras,
      'b_milage': bMilage,
      'b_geartype': bGeartype,
      'b_fueltype': bFueltype,
      'b_bhp': bBhp,
      'b_image': bImage,
      'b_reviews': bReviews,
      'distance': distance,
      'max_speed': maxSpeed,
      'maintaince_status': maintainceStatus,
      'center': center,
      'bikereviews': bikereviews.map((e) => e.toJson()).toList(),
      'bikeimages': bikeimages.map((e) => e.toJson()).toList(),
      'bike_centers': bikeCenters.map((e) => e.toJson()).toList(),
    };
  }
}

class BikeReviewModel {
  int brId;
  int brUsedId;
  int brBikeId;
  String brReview;
  int brRating;
  String date;
  String? uName;
  String? uProfilePic;

  BikeReviewModel({
    required this.brId,
    required this.brUsedId,
    required this.brBikeId,
    required this.brReview,
    required this.brRating,
    required this.date,
    this.uName,
    this.uProfilePic,
  });

  factory BikeReviewModel.fromJson(Map<String, dynamic> json) {
    return BikeReviewModel(
      brId: _parseInt(json["br_id"]),
      brUsedId: _parseInt(json["br_used_id"]),
      brBikeId: _parseInt(json["br_bike_id"]),
      brReview: _parseString(json["br_review"]),
      brRating: _parseInt(json["br_rating"]),
      date: _parseString(json["date"]),
      uName: json["u_name"] as String?,
      uProfilePic: json["u_profile_pic"] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'br_id': brId,
      'br_used_id': brUsedId,
      'br_bike_id': brBikeId,
      'br_review': brReview,
      'br_rating': brRating,
      'date': date,
      'u_name': uName,
      'u_profile_pic': uProfilePic,
    };
  }
}

class BikeImageModel {
  int imgId;
  int bikeId;
  String imagePath;

  BikeImageModel({
    required this.imgId,
    required this.bikeId,
    required this.imagePath,
  });

  factory BikeImageModel.fromJson(Map<String, dynamic> json) {
    return BikeImageModel(
      imgId: _parseInt(
        json[" img_id"] ?? json["img_id"],
      ), // Handle potential space key typo
      bikeId: _parseInt(json["bike_id"]),
      imagePath: _parseString(json["image_path"]),
    );
  }

  Map<String, dynamic> toJson() {
    return {'img_id': imgId, 'bike_id': bikeId, 'image_path': imagePath};
  }
}

class BikeCenterModel {
  int bcId;
  int bcBikeId;
  int bcCenterId;
  int lId;
  String lLocation;
  String lDistrict;

  BikeCenterModel({
    required this.bcId,
    required this.bcBikeId,
    required this.bcCenterId,
    required this.lId,
    required this.lLocation,
    required this.lDistrict,
  });

  factory BikeCenterModel.fromJson(Map<String, dynamic> json) {
    return BikeCenterModel(
      bcId: _parseInt(json["bc_id"]),
      bcBikeId: _parseInt(json["bc_bike_id"]),
      bcCenterId: _parseInt(json["bc_center_id"]),
      lId: _parseInt(json["l_id"]),
      lLocation: _parseString(json["l_location"]),
      lDistrict: _parseString(json["l_district"]),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bc_id': bcId,
      'bc_bike_id': bcBikeId,
      'bc_center_id': bcCenterId,
      'l_id': lId,
      'l_location': lLocation,
      'l_district': lDistrict,
    };
  }
}

class BookingModel {
  int bId;
  int bUId;
  dynamic bBkId;
  int bPriceId;
  double bRentAmount;
  int bFineAmount;
  double bTotalAmount;
  String bPickupLocation;
  DateTime bPickupDate;
  DateTime bPicupTime;
  String bDropLocation;
  DateTime bDropDate;
  DateTime bDropTime;
  dynamic bRole;
  dynamic bType;
  dynamic bMessage;
  DateTime bookingDate;
  dynamic invoice;
  String bSelfie;
  dynamic bAdharfront;
  dynamic bAdharback;
  dynamic bLicensefront;
  dynamic bLicenseback;
  dynamic viewReason;
  dynamic bBikeName;
  dynamic extendReason;
  String bPaymentStatus;
  String bStatus;
  int uId;
  String uName;
  String uEmail;
  int uMobile;
  String uAddress;
  String uState;
  String uDistrict;
  int uPincode;
  DateTime uJoindate;
  String uProfilePic;
  String uAdharfront;
  String uAddarback;
  String uLicensefront;
  String uLicenseback;
  String uDob;
  String uRole;

  BookingModel({
    required this.bId,
    required this.bUId,
    required this.bBkId,
    required this.bPriceId,
    required this.bRentAmount,
    required this.bFineAmount,
    required this.bTotalAmount,
    required this.bPickupLocation,
    required this.bPickupDate,
    required this.bPicupTime,
    required this.bDropLocation,
    required this.bDropDate,
    required this.bDropTime,
    required this.bRole,
    required this.bType,
    required this.bMessage,
    required this.bookingDate,
    required this.invoice,
    required this.bSelfie,
    required this.bAdharfront,
    required this.bAdharback,
    required this.bLicensefront,
    required this.bLicenseback,
    required this.viewReason,
    required this.bBikeName,
    required this.extendReason,
    required this.bPaymentStatus,
    required this.bStatus,
    required this.uId,
    required this.uName,
    required this.uEmail,
    required this.uMobile,
    required this.uAddress,
    required this.uState,
    required this.uDistrict,
    required this.uPincode,
    required this.uJoindate,
    required this.uProfilePic,
    required this.uAdharfront,
    required this.uAddarback,
    required this.uLicensefront,
    required this.uLicenseback,
    required this.uDob,
    required this.uRole,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      bId: json["b_id"] ?? "",
      bUId: json["b_u_id"] ?? "",
      bBkId: json["b_bk_id"] ?? "",
      bPriceId: json["b_price_id"] ?? "",

      bRentAmount: (json["b_rent_amount"] ?? 0).toDouble(),
      bFineAmount: (json["b_fine_amount"] ?? 0).toDouble(),
      bTotalAmount: (json["b_total_amount"] ?? 0).toDouble(),

      bPickupLocation: json["b_pickup_location"] ?? "",

      bPickupDate:
          json["b_pickup_date"] != null
              ? DateTime.parse(json["b_pickup_date"])
              : DateTime.now(),

      bPicupTime:
          json["b_picup_time"] != null
              ? DateTime.parse(json["b_picup_time"])
              : DateTime.now(),

      bDropLocation: json["b_drop_location"] ?? "",

      bDropDate:
          json["b_drop_date"] != null
              ? DateTime.parse(json["b_drop_date"])
              : DateTime.now(),

      bDropTime:
          json["b_drop_time"] != null
              ? DateTime.parse(json["b_drop_time"])
              : DateTime.now(),

      bRole: json["b_role"] ?? "",
      bType: json["b_type"] ?? "",
      bMessage: json["b_message"] ?? "",

      bookingDate:
          json["booking_date"] != null
              ? DateTime.parse(json["booking_date"])
              : DateTime.now(),

      invoice: json["invoice"] ?? "",

      bSelfie: json["b_selfie"] ?? "",
      bAdharfront: json["b_adharfront"] ?? "",
      bAdharback: json["b_adharback"] ?? "",
      bLicensefront: json["b_licensefront"] ?? "",
      bLicenseback: json["b_licenseback"] ?? "",

      viewReason: json["view_reason"] ?? "",
      bBikeName: json["b_bike_name"] ?? "",
      extendReason: json["extend_reason"] ?? "",

      bPaymentStatus: json["b_payment_status"] ?? "",
      bStatus: json["b_status"] ?? "",

      uId: json["u_id"] ?? "",
      uName: json["u_name"] ?? "",
      uEmail: json["u_email"] ?? "",
      uMobile: json["u_mobile"] ?? "",
      uAddress: json["u_address"] ?? "",
      uState: json["u_state"] ?? "",
      uDistrict: json["u_district"] ?? "",
      uPincode: json["u_pincode"] ?? "",

      uJoindate:
          json["u_joindate"] != null
              ? DateTime.parse(json["u_joindate"])
              : DateTime.now(),

      uProfilePic: json["u_profile_pic"] ?? "",
      uAdharfront: json["u_adharfront"] ?? "",
      uAddarback: json["u_addarback"] ?? "",
      uLicensefront: json["u_licensefront"] ?? "",
      uLicenseback: json["u_licenseback"] ?? "",

      uDob: json["u_dob"] ?? "",
      uRole: json["u_role"] ?? "",
    );
  }
}

class NotificationModel {
  int? nId;
  int? userId;
  int? adminId;
  String? role;
  String? type;
  String? message;
  String? status;

  NotificationModel({
    this.nId,
    this.userId,
    this.adminId,
    this.role,
    this.type,
    this.message,
    this.status,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      nId: (json['n_id'] as int?) ?? 0,
      userId: (json['user_id'] as int?) ?? 0,
      adminId: (json['admin_id'] as int?) ?? 0,
      role: (json['role'] as String?) ?? '',
      type: (json['type'] as String?) ?? '',
      message: (json['message'] as String?) ?? '',
      status: (json['status'] as String?) ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'n_id': nId,
    'user_id': userId,
    'admin_id': adminId,
    'role': role,
    'type': type,
    'message': message,
    'status': status,
  };
}

class UserModel {
  int uId;
  String uName;
  String uEmail;
  String uPassword;
  int uMobile;
  String uAddress;
  String uState;
  String uDistrict;
  int uPincode;
  String uJoindate;
  String uRole;
  int uToken;
  String uTokenExpiry;
  String uOtpStatus;
  String uProfilePic;
  String uAdharfront;
  String uAddarback;
  String uLicensefront;
  String uLicenseback;
  String? uDob;
  String uMobileVerify;

  UserModel({
    required this.uId,
    required this.uName,
    required this.uEmail,
    required this.uPassword,
    required this.uMobile,
    required this.uAddress,
    required this.uState,
    required this.uDistrict,
    required this.uPincode,
    required this.uJoindate,
    required this.uRole,
    required this.uToken,
    required this.uTokenExpiry,
    required this.uOtpStatus,
    required this.uProfilePic,
    required this.uAdharfront,
    required this.uAddarback,
    required this.uLicensefront,
    required this.uLicenseback,
    this.uDob,
    required this.uMobileVerify,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uId: _parseInt(json['u_id']),
      uName: _parseString(json['u_name']),
      uEmail: _parseString(json['u_email']),
      uPassword: _parseString(json['u_password']),
      uMobile: _parseInt(json['u_mobile']),
      uAddress: _parseString(json['u_address']),
      uState: _parseString(json['u_state']),
      uDistrict: _parseString(json['u_district']),
      uPincode: _parseInt(json['u_pincode']),
      uJoindate: _parseString(json['u_joindate']),
      uRole: _parseString(json['u_role']),
      uToken: _parseInt(json['u_token']),
      uTokenExpiry: _parseString(json['u_token_expiry']),
      uOtpStatus: _parseString(json['u_otp_status']),
      uProfilePic: _parseString(json['u_profile_pic']),
      uAdharfront: _parseString(json['u_adharfront']),
      uAddarback: _parseString(json['u_addarback']),
      uLicensefront: _parseString(json['u_licensefront']),
      uLicenseback: _parseString(json['u_licenseback']),
      uDob: json['u_dob'] as String?,
      uMobileVerify: (json['u_mobile_verify']?.toString() ?? 'false'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'u_id': uId,
      'u_name': uName,
      'u_email': uEmail,
      'u_password': uPassword,
      'u_mobile': uMobile,
      'u_address': uAddress,
      'u_state': uState,
      'u_district': uDistrict,
      'u_pincode': uPincode,
      'u_joindate': uJoindate,
      'u_role': uRole,
      'u_token': uToken,
      'u_token_expiry': uTokenExpiry,
      'u_otp_status': uOtpStatus,
      'u_profile_pic': uProfilePic,
      'u_adharfront': uAdharfront,
      'u_addarback': uAddarback,
      'u_licensefront': uLicensefront,
      'u_licenseback': uLicenseback,
      'u_dob': uDob,
      'u_mobile_verify': uMobileVerify,
    };
  }
}

class SupportModel {
  int cId;
  String cName;
  String cEmail;
  int cPhonenumber;
  String cIssuetype;
  String cMessage;
  String cImage;

  SupportModel({
    required this.cId,
    required this.cName,
    required this.cEmail,
    required this.cPhonenumber,
    required this.cIssuetype,
    required this.cMessage,
    required this.cImage,
  });

  factory SupportModel.fromJson(Map<String, dynamic> json) => SupportModel(
    cId: (json["c_id"] as int?) ?? 0,
    cName: (json["c_name"] as String?) ?? "",
    cEmail: (json["c_email"] as String?) ?? "",
    cPhonenumber: (json["c_phonenumber"] as int?) ?? 0,
    cIssuetype: (json["c_issuetype"] as String?) ?? "",
    cMessage: (json["c_message"] as String?) ?? "",
    cImage: (json["c_image"] as String?) ?? "",
  );

  Map<String, dynamic> toJson() => {
    "c_id": cId,
    "c_name": cName,
    "c_email": cEmail,
    "c_phonenumber": cPhonenumber,
    "c_issuetype": cIssuetype,
    "c_message": cMessage,
    "c_image": cImage,
  };
}

class BikeCenters {
  int lId;
  String lLocation;
  String lDistrict;

  BikeCenters({
    required this.lId,
    required this.lLocation,
    required this.lDistrict,
  });

  factory BikeCenters.fromJson(Map<String, dynamic> json) => BikeCenters(
    lId: (json["l_id"] as int?) ?? 0,
    lLocation: (json["l_location"] as String?) ?? "",
    lDistrict: (json["l_district"] as String?) ?? "",
  );

  Map<String, dynamic> toJson() => {
    "l_id": lId,
    "l_location": lLocation,
    "l_district": lDistrict,
  };
}

class LocationListResponse {
  final bool result;
  final String message;
  final List<LocationModel> list;

  LocationListResponse({
    required this.result,
    required this.message,
    required this.list,
  });

  factory LocationListResponse.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return LocationListResponse(result: false, message: "", list: []);
    }

    return LocationListResponse(
      result: (json["result"] as bool?) ?? false,
      message: (json["message"] as String?) ?? "",
      list:
          (json["list"] as List<dynamic>?)
              ?.map((x) => LocationModel.fromJson(x as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
    "result": result,
    "message": message,
    "list": list.map((e) => e.toJson()).toList(),
  };
}

class LocationModel {
  int lId;
  String lLocation;
  String lDistrict;
  String? lLatitude;
  String? lLongitude;

  LocationModel({
    this.lId = 0,
    required this.lLocation,
    required this.lDistrict,
    this.lLatitude,
    this.lLongitude,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      lId: _parseInt(json["l_id"]),
      lLocation: _parseString(json["l_location"]),
      lDistrict: _parseString(json["l_district"]),
      lLatitude: json["l_latitude"] as String?,
      lLongitude: json["l_longitude"] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    "l_id": lId,
    "l_location": lLocation,
    "l_district": lDistrict,
    "l_latitude": lLatitude,
    "l_longitude": lLongitude,
  };
}

// Global safe parsing helpers
int _parseInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) {
    if (value.isEmpty) return 0;
    return int.tryParse(value) ?? 0;
  }
  return 0;
}

double _parseDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) {
    if (value.isEmpty) return 0.0;
    return double.tryParse(value) ?? 0.0;
  }
  return 0.0;
}

String _parseString(dynamic value) {
  if (value == null) return "";
  return value.toString();
}

DateTime _parseDate(dynamic value) {
  if (value == null) return DateTime.now();
  if (value is DateTime) return value;
  if (value is String) {
    if (value.isEmpty) return DateTime.now();
    return DateTime.tryParse(value) ?? DateTime.now();
  }
  return DateTime.now();
}
