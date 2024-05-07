import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:selaa_delivery/backend_functions/links.dart';

Future<Position> getCurrentLocation() async {
  LocationPermission permission = await Geolocator.requestPermission();
  if (permission == LocationPermission.denied) {
    throw Exception('Location permission denied');
  } else if (permission == LocationPermission.deniedForever) {
    throw Exception('Location permission permanently denied');
  } else {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentReference documentReference = FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid);
        await documentReference.update({
          'lastLocation': GeoPoint(position.latitude, position.longitude),
        });
      }
      return position;
    } catch (e) {
      throw Exception('Failed to get location: $e');
    }
  }
}

Future<BitmapDescriptor> loadCustomMarkerIcon(String vehiculeType) async {
  BitmapDescriptor customMarkerIcon;
  switch (vehiculeType) {
    case 'Car':
      customMarkerIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(48, 48)),
        ImagePaths().carIcon
      );
    break;
    case 'Truck':
      customMarkerIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(48, 48)),
        ImagePaths().truckIcon
      );
    break;
    case 'Motorcycle':
      customMarkerIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(48, 48)),
        ImagePaths().motorcycleIcon
      );
    break;
    default:
      customMarkerIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(48, 48)),
        ImagePaths().carIcon
      );
    break;
  }
  return customMarkerIcon;
}

Future<double> calculateDistance(double startLatitude, double startLongitude, double endLatitude, double endLongitude) async {
  double distanceInMeters = await Geolocator.distanceBetween(startLatitude, startLongitude, endLatitude, endLongitude);
  // Convert distance from meters to kilometers
  double distanceInKm = distanceInMeters / 1000;
  return distanceInKm;
}