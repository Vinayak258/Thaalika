import 'package:cloud_firestore/cloud_firestore.dart';

class SeedData {
  static Future<void> seedFirestore() async {
    final db = FirebaseFirestore.instance;

    // Check if already seeded (to avoid duplicates)
    final usersSnapshot = await db.collection('users').limit(1).get();
    if (usersSnapshot.docs.isNotEmpty) {
      print('⚠️ Seed skipped: users collection already has data.');
      return;
    }

    print('🌱 Starting Firestore seed...');

    // Batch write for efficiency
    final batch = db.batch();

    // ---------- USERS ----------
    final studentRef = db.collection('users').doc('student1');
    batch.set(studentRef, {
      'uid': 'student1',
      'name': 'Test Student',
      'email': 'student@test.com',
      'phone': '9999999999',
      'role': 'student',
      'wallet': 300,
      'coupons': 5,
      'messId': '',
    });

    final ownerRef = db.collection('users').doc('owner1');
    batch.set(ownerRef, {
      'uid': 'owner1',
      'name': 'Test Mess Owner',
      'email': 'owner@test.com',
      'phone': '8888888888',
      'role': 'owner',
      'wallet': 0,
      'coupons': 0,
      'messId': 'mess1',
    });

    final deliveryRef = db.collection('users').doc('delivery1');
    batch.set(deliveryRef, {
      'uid': 'delivery1',
      'name': 'Test Delivery Boy',
      'email': 'delivery@test.com',
      'phone': '7777777777',
      'role': 'delivery',
      'wallet': 0,
      'coupons': 0,
      'messId': '',
    });

    // ---------- MESSES ----------
    final mess1Ref = db.collection('messes').doc('mess1');
    batch.set(mess1Ref, {
      'messId': 'mess1',
      'ownerUid': 'owner1',
      'name': 'Royal Mess',
      'address': 'Near College Road',
      'couponValue': 30,
    });

    final mess2Ref = db.collection('messes').doc('mess2');
    batch.set(mess2Ref, {
      'messId': 'mess2',
      'ownerUid': 'owner1',
      'name': 'Mumbai Tiffin Center',
      'address': 'Hostel Area',
      'couponValue': 25,
    });

    // ---------- MENUS ----------
    final menusRef = db.collection('menus');

    batch.set(menusRef.doc('menu1'), {
      'id': 'menu1',
      'messId': 'mess1',
      'name': 'Veg Thali',
      'price': 80,
      'available': true,
      'type': 'lunch',
    });

    batch.set(menusRef.doc('menu2'), {
      'id': 'menu2',
      'messId': 'mess1',
      'name': 'Paneer Thali',
      'price': 100,
      'available': true,
      'type': 'dinner',
    });

    batch.set(menusRef.doc('menu3'), {
      'id': 'menu3',
      'messId': 'mess2',
      'name': 'South Indian Breakfast',
      'price': 60,
      'available': true,
      'type': 'breakfast',
    });

    // Commit everything
    await batch.commit();

    print('✅ Firestore seed completed successfully.');
  }
}
