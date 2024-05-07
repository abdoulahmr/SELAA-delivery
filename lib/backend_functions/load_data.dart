import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

User? user = FirebaseAuth.instance.currentUser;
DatabaseReference userStatusRef = FirebaseDatabase.instance.ref().child("users").child(user!.uid).child('status');

// Function to get the current user type
Future<String> getUserType() async {
  String userType = "";
  if (user != null) {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection("users")
        .doc(user?.uid)
        .get();
    if (snapshot.exists) {
      userType = snapshot.get("accountType");
    }
  }
  return userType;
}

// Function to get user data
Future<List<Map<String, dynamic>>> loadUserInfo(context) async {
  if (user != null) {
    try {
      DocumentSnapshot<Map<String, dynamic>> documentSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user?.uid)
          .get();

      if (documentSnapshot.exists) {
        // Return a list containing user data
        return [documentSnapshot.data()!];
      } else {
        // Handle case when document does not exist
        Fluttertoast.showToast(
          msg: "Error logging in please send us a feedback code 4-1-1",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        return [];
      }
    } catch (error) {
      Fluttertoast.showToast(
        msg: "Error logging in please send us a feedback code 4-2-1",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return [];
    }
  } else {
    // Handle case when user is null
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Error please send us a feedback  code 30'),
      ),
    );
    return [];
  }
}

// load vehicule icon based on database data
IconData getVehicleIcon(String? vehicleType) {
  switch (vehicleType) {
    case 'Car':
      return Icons.directions_car;
    case 'Truck':
      return Icons.local_shipping;
    case 'Motorcycle':
      return Icons.motorcycle;
    default:
      return Icons.directions_car;
  }
}

// load user id
Future<String> userId() async {
  return user!.uid.toString();
}

// load user transaction history
Future<List<Map<String, dynamic>>> loadAllDocumentsInCollection() async {
  User? user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('transaction')
        .get();

    List<Map<String, dynamic>> documents = querySnapshot.docs.map((doc) => doc.data()).toList();

    return documents;
  }
  return []; // Return an empty list if user is null
}

Stream<List<Map<String, dynamic>>> getRequest() {
  User? user = FirebaseAuth.instance.currentUser;
  return FirebaseFirestore.instance
    .collection('requests')
    .where("agentID", isEqualTo: user!.uid)
    .snapshots()
    .map((snapshot) =>
        snapshot.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList());
}

Future<List<Map<String, dynamic>>> getOrderItems(String orderID)async{
  QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore.instance
    .collection('orders')
    .where('orderID', isEqualTo: orderID)
    .get();
  List<Map<String, dynamic>> documentsData = [];
    for (var doc in querySnapshot.docs) {
      Map<String, dynamic> data = doc.data();
      // Get the product reference
      DocumentReference<Map<String, dynamic>> productRef = data['product'];
      // Load the product document
      DocumentSnapshot<Map<String, dynamic>> productSnapshot = await productRef.get();
      // Get the product data
      Map<String, dynamic>? productData = productSnapshot.data();
      // Add the product data to the order item data
      data['product'] = productData;
      documentsData.add(data);
  }
  return documentsData;
}

Future<List<Map<String, dynamic>>> loadSellerInfo(String sellerID) async {
  DocumentSnapshot<Map<String, dynamic>> documentSnapshot = await FirebaseFirestore.instance
    .collection('users')
    .doc(sellerID)
    .get();
  return [documentSnapshot.data()!];
}

Stream<List<dynamic>> getRequestStatusStream(String orderID) {
  try{
    return FirebaseFirestore.instance
    .collection('requests')
    .where("orderID", isEqualTo: orderID)
    .snapshots()
    .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  } catch (error) {
    return Stream.value([]);
  }
}

Future<List<Map<String, dynamic>>> loadBuyerInfo(String orderID, String sellerID) async {
  try {
    QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(sellerID)
        .collection("orders")
        .where("orderID", isEqualTo: orderID)
        .get();

    if (querySnapshot.docs.isEmpty) {
      throw Exception("No order found with ID: $orderID for seller: $sellerID");
    }

    DocumentSnapshot<Map<String, dynamic>> orderDocument = querySnapshot.docs.first;
    DocumentReference<Object?>? buyerRef = orderDocument['buyer'] as DocumentReference<Object?>?;

    if (buyerRef == null) {
      throw Exception("Buyer reference is null for order ID: $orderID");
    }

    DocumentSnapshot<Object?> buyerSnapshot = await buyerRef.get();

    if (!buyerSnapshot.exists) {
      throw Exception("Buyer document does not exist for order ID: $orderID");
    }

    return [buyerSnapshot.data()! as Map<String, dynamic>];
  } catch (e) {
    print("Error loading buyer info: $e");
    return [];
  }
}
