import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import '../models/user_model.dart';
import '../models/mess_model.dart';
import '../models/menu_item_model.dart';

class SeedData {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static Future<void> seedFirestore() async {
    // ---- Prevent duplicates ----
    final check = await _firestore.collection("seed_status").doc("done").get();
    if (check.exists) {
      print("⚠ Seed already completed — skipping.");
      return;
    }

    print("⏳ Seeding started...");

    // ---- Create Demo Accounts in Firebase Auth ----
    final studentCred = await _auth.createUserWithEmailAndPassword(
      email: "student@test.com",
      password: "123456",
    );

    final ownerCred = await _auth.createUserWithEmailAndPassword(
      email: "owner@test.com",
      password: "123456",
    );

    final deliveryCred = await _auth.createUserWithEmailAndPassword(
      email: "delivery@test.com",
      password: "123456",
    );

    // ---- Create Firestore Users ----
    final student = UserModel(
      uid: studentCred.user!.uid,
      name: "Test Student",
      email: "student@test.com",
      phone: "1234567890",
      role: "student",
      wallet: 500.0,
      coupons: {'mess_1': 5, 'mess_2': 2}, // mess-specific coupons
      location: "Hostel Block A",
    );

    final owner = UserModel(
      uid: ownerCred.user!.uid,
      name: "Test Owner",
      email: "owner@test.com",
      phone: "0987654321",
      role: "owner",
      messId: "mess_1",
      location: "City Center",
    );

    final delivery = UserModel(
      uid: deliveryCred.user!.uid,
      name: "Test Delivery",
      email: "delivery@test.com",
      phone: "1122334455",
      role: "delivery",
      location: "Delivery Hub",
    );

    await _firestore.collection("users").doc(student.uid).set(student.toJson());
    await _firestore.collection("users").doc(owner.uid).set(owner.toJson());
    await _firestore.collection("users").doc(delivery.uid).set(delivery.toJson());

    // ---- Create Messes ----
    final mess1 = MessModel(
      messId: "mess_1",
      ownerUid: owner.uid,
      name: "Annapurna Mess",
      ownerName: "Test Owner",
      contactNumber: "0987654321",
      address: "123, College Road",
      messType: "both",
      couponValue: 50.0,
      subscriptionPrice: 2500.0,
      location: "College Road",
      cutoffTime: "10:30 AM",
      todayLunchMenu: "Dal, Rice, Roti",
      todayDinnerMenu: "Paneer, Naan",
    );

    final mess2 = MessModel(
      messId: "mess_2",
      ownerUid: owner.uid, // owner owns both messes for easier testing
      name: "Spicy Bites",
      ownerName: "Test Owner",
      contactNumber: "0987654321",
      address: "456, Hostel Lane",
      messType: "non-veg",
      couponValue: 60.0,
      subscriptionPrice: 3000.0,
      location: "Hostel Lane",
      cutoffTime: "11:00 AM",
      todayLunchMenu: "Chicken Biryani, Raita",
      todayDinnerMenu: "Fish Curry, Rice",
    );

    await _firestore.collection("messes").doc(mess1.messId).set(mess1.toJson());
    await _firestore.collection("messes").doc(mess2.messId).set(mess2.toJson());

    // ---- Add Menu Items ----
    final menuItems = [
      MenuItemModel(id: const Uuid().v4(), messId: mess1.messId, name: "Veg Thali", price: 80, available: true, type: "veg"),
      MenuItemModel(id: const Uuid().v4(), messId: mess1.messId, name: "Chicken Curry", price: 120, available: true, type: "non-veg"),
      MenuItemModel(id: const Uuid().v4(), messId: mess2.messId, name: "Aloo Paratha", price: 40, available: true, type: "veg"),
      MenuItemModel(id: const Uuid().v4(), messId: mess2.messId, name: "Egg Curry", price: 90, available: true, type: "non-veg"),
    ];

    for (var item in menuItems) {
      await _firestore
          .collection("messes")
          .doc(item.messId)
          .collection("menu")
          .doc(item.id)
          .set(item.toJson());
    }

    // ---- Mark seeding completed ----
    await _firestore.collection("seed_status").doc("done").set({"seeded": true});

    print("🎉 Database Seeding Completed Successfully!");
  }
}
