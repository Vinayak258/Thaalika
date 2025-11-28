import 'extra_item_model.dart';

class MessModel {
  final String messId;
  final String ownerUid;
  final String name;
  final String ownerName;
  final String contactNumber;
  final String address;
  final String messType; // 'veg', 'non-veg', 'both'
  final String? logoUrl;
  final double couponValue;
  final double subscriptionPrice;
  final double latitude;
  final double longitude;
  final List<Map<String, dynamic>> plans;
  final String location;
  final String cutoffTime;
  final String todayLunchMenu;
  final String todayDinnerMenu;
  final List<ExtraItemModel> extrasItems;

  MessModel({
    required this.messId,
    required this.ownerUid,
    required this.name,
    required this.ownerName,
    required this.contactNumber,
    required this.address,
    this.messType = 'both',
    this.logoUrl,
    required this.couponValue,
    this.subscriptionPrice = 2000.0,
    this.location = 'Unknown',
    this.latitude = 0.0,
    this.longitude = 0.0,
    this.cutoffTime = '10:00 AM',
    this.todayLunchMenu = '',
    this.todayDinnerMenu = '',
    this.extrasItems = const [],
    this.plans = const [],
  });

  factory MessModel.fromJson(Map<String, dynamic> json) {
    return MessModel(
      messId: json['messId'] ?? '',
      ownerUid: json['ownerUid'] ?? '',
      name: json['name'] ?? '',
      ownerName: json['ownerName'] ?? '',
      contactNumber: json['contactNumber'] ?? '',
      address: json['address'] ?? '',
      messType: json['messType'] ?? 'both',
      logoUrl: json['logoUrl'],
      couponValue: (json['couponValue'] ?? 0.0).toDouble(),
      subscriptionPrice: (json['subscriptionPrice'] ?? 2000.0).toDouble(),
      location: json['location'] ?? 'Unknown',
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      cutoffTime: json['cutoffTime'] ?? '10:00 AM',
      todayLunchMenu: json['todayLunchMenu'] ?? '',
      todayDinnerMenu: json['todayDinnerMenu'] ?? '',
      extrasItems: (json['extrasItems'] as List<dynamic>?)
              ?.map((e) => ExtraItemModel.fromJson(e))
              .toList() ??
          [],
      plans: List<Map<String, dynamic>>.from(json['plans'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'messId': messId,
      'ownerUid': ownerUid,
      'name': name,
      'ownerName': ownerName,
      'contactNumber': contactNumber,
      'address': address,
      'messType': messType,
      'logoUrl': logoUrl,
      'couponValue': couponValue,
      'subscriptionPrice': subscriptionPrice,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'cutoffTime': cutoffTime,
      'todayLunchMenu': todayLunchMenu,
      'todayDinnerMenu': todayDinnerMenu,
      'extrasItems': extrasItems.map((e) => e.toJson()).toList(),
      'plans': plans,
    };
  }

  MessModel copyWith({
    String? messId,
    String? ownerUid,
    String? name,
    String? ownerName,
    String? contactNumber,
    String? address,
    String? messType,
    String? logoUrl,
    double? couponValue,
    double? subscriptionPrice,
    String? location,
    double? latitude,
    double? longitude,
    String? cutoffTime,
    String? todayLunchMenu,
    String? todayDinnerMenu,
    List<ExtraItemModel>? extrasItems,
    List<Map<String, dynamic>>? plans,
  }) {
    return MessModel(
      messId: messId ?? this.messId,
      ownerUid: ownerUid ?? this.ownerUid,
      name: name ?? this.name,
      ownerName: ownerName ?? this.ownerName,
      contactNumber: contactNumber ?? this.contactNumber,
      address: address ?? this.address,
      messType: messType ?? this.messType,
      logoUrl: logoUrl ?? this.logoUrl,
      couponValue: couponValue ?? this.couponValue,
      subscriptionPrice: subscriptionPrice ?? this.subscriptionPrice,
      location: location ?? this.location,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      cutoffTime: cutoffTime ?? this.cutoffTime,
      todayLunchMenu: todayLunchMenu ?? this.todayLunchMenu,
      todayDinnerMenu: todayDinnerMenu ?? this.todayDinnerMenu,
      extrasItems: extrasItems ?? this.extrasItems,
      plans: plans ?? this.plans,
    );
  }
}
