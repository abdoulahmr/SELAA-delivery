import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';
import 'package:selaa_delivery/backend_functions/map_fun.dart';

// Function to change user status
Future<void> changeStatus() async {
  User? user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    DocumentSnapshot<Map<String, dynamic>> statusSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    Map<String, dynamic> statusData = statusSnapshot.data()!;
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    if (statusData['status'] == true) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'status': false,
      });
    } else {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'status': true,
        'location': GeoPoint(position.latitude, position.longitude),
      });
    }
  }
}

// set status to offline on quiting the app
Future<void> setUserStatusOffline() async{
  User? user = FirebaseAuth.instance.currentUser;
  if(user!=null){
    FirebaseFirestore.instance.collection('users').doc(user.uid).update({
      'status': false,
    });
  }
}

// cofirm loading
Future<void> confirmRequest(String requestId, String sellerID, String orderID, GeoPoint location) async {
  try {
    // Query for the order document based on the orderID
    QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(sellerID)
        .collection("orders")
        .where("orderID", isEqualTo: orderID)
        .get();

    // Check if the query returned any documents
    if (querySnapshot.docs.isNotEmpty) {
      // Get the document ID of the first matching document
      String documentID = querySnapshot.docs.first.id;

      // Update status to 'delivering' for the request and the seller's order
      await FirebaseFirestore.instance
          .collection('requests')
          .doc(requestId)
          .update({
        'status': 'delivering',
      });
      await FirebaseFirestore.instance
          .collection('users')
          .doc(sellerID)
          .collection("orders")
          .doc(documentID)
          .update({
        'status': 'delivering',
      });

      // Get the buyer ID
      DocumentSnapshot<Map<String, dynamic>> orderDocument = querySnapshot.docs.first;
      DocumentReference<Object?>? buyerRef = orderDocument['buyer'] as DocumentReference<Object?>?;
      if (buyerRef != null) {
        DocumentSnapshot<Object?> buyerSnapshot = await buyerRef.get();
        String buyerID = buyerSnapshot.id;

        // Update the buyer's order
        await FirebaseFirestore.instance
            .collection('users')
            .doc(buyerID)
            .collection("orders")
            .where("orderId", isEqualTo: orderID)
            .get()
            .then((querySnapshot) {
          if (querySnapshot.docs.isNotEmpty) {
            querySnapshot.docs.first.reference.update({
              'status': 'delivering',
            });
          }
        });
      } else {
        print('Buyer reference is null');
      }
    } else {
      print('Order document not found');
    }
  } catch (e) {
    print('Error loading request: $e');
  }
}

// cofirm unloading
Future<void> confirmDelivery(String requestId, String sellerID, String orderID, GeoPoint location) async {
  try {
    // Query for the order document based on the orderID
    QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(sellerID)
        .collection("orders")
        .where("orderID", isEqualTo: orderID)
        .get();

    // Check if the query returned any documents
    if (querySnapshot.docs.isNotEmpty) {
      // Get the document ID of the first matching document
      String documentID = querySnapshot.docs.first.id;

      // Update status to 'delivering' for the request and the seller's order
      await FirebaseFirestore.instance
          .collection('requests')
          .doc(requestId)
          .update({
        'status': 'delivred',
      });
      await FirebaseFirestore.instance
          .collection('users')
          .doc(sellerID)
          .collection("orders")
          .doc(documentID)
          .update({
        'status': 'delivred',
      });

      // Get the buyer ID
      DocumentSnapshot<Map<String, dynamic>> orderDocument = querySnapshot.docs.first;
      DocumentReference<Object?>? buyerRef = orderDocument['buyer'] as DocumentReference<Object?>?;
      if (buyerRef != null) {
        DocumentSnapshot<Object?> buyerSnapshot = await buyerRef.get();
        String buyerID = buyerSnapshot.id;

        // Update the buyer's order
        await FirebaseFirestore.instance
            .collection('users')
            .doc(buyerID)
            .collection("orders")
            .where("orderId", isEqualTo: orderID)
            .get()
            .then((querySnapshot) {
          if (querySnapshot.docs.isNotEmpty) {
            querySnapshot.docs.first.reference.update({
              'status': 'delivred',
            });
          }
        });
      DatabaseReference databaseReference = FirebaseDatabase.instance.ref().child('orders');
      databaseReference.push().set({
        orderID: location,
      });
      } else {
        print('Buyer reference is null');
      }
    } else {
      print('Order document not found');
    }
  } catch (e) {
    print('Error loading request: $e');
  }
}


// accept request
Future<void> acceptRequest(String requestId) async {
  User? user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    await FirebaseFirestore.instance.collection('requests')
      .doc(requestId).update({
      'status': 'confirmed',
    });
  }
}

// confirm arrive
Future<void> arriveRequest(String requestId) async {
  User? user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    await FirebaseFirestore.instance.collection('requests')
      .doc(requestId).update({
      'status': 'arrived',
    });
  }
}

// finish the job
Future<void> finishRequest(String requestId) async {
  User? user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance.collection("requests").doc(requestId).get();
    Map<String, dynamic> requestData = snapshot.data()!;

    // Add the request to the user's history
    await FirebaseFirestore.instance.collection("users").doc(user.uid).collection("history").add(requestData);

    // Delete the request
    await FirebaseFirestore.instance.collection('requests').doc(requestId).delete();

    // Increment deliveryCount
    await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
      'deliveryCount': FieldValue.increment(1),
    });

    // Add to totalDistance
    DocumentSnapshot<Map<String, dynamic>> sellerSnapshot = await FirebaseFirestore.instance.collection('users').doc(requestData['seller']).get();
    Map<String, dynamic> sellerData = sellerSnapshot.data()!;
    double distance = await calculateDistance(
      requestData["location"].latitude, requestData["location"].longitude, 
      sellerData['lastLocation'].latitude, sellerData['lastLocation'].longitude
    );
    await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
      'totalDistance': FieldValue.increment(distance),
    });

    // Add to balance
    double price = distance * 500;
    await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
      'balance': FieldValue.increment(price),
    });
  }
}
