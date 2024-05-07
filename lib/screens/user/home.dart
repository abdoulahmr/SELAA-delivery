import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:selaa_delivery/backend_functions/auth.dart';
import 'package:selaa_delivery/backend_functions/data_manip.dart';
import 'package:selaa_delivery/backend_functions/links.dart';
import 'package:selaa_delivery/backend_functions/load_data.dart';
import 'package:selaa_delivery/backend_functions/map_fun.dart';
import 'package:selaa_delivery/screens/user/order_overview.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver{
  bool _isloading = true;
  bool _isOnline = false;
  bool _accepted = false;
  List<Map<String, dynamic>> userInfo = [];
  List<dynamic> request = [];
  List<Map<String, dynamic>> buyerInfo = [];
  late GoogleMapController _mapController;
  late BitmapDescriptor customMarkerIcon = BitmapDescriptor.defaultMarker;
  LatLng? _currentLocation;
  final Set<Marker> _markers = {};
  late QRViewController controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  String scannedCode = "";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    getCurrentLocation().then((Position position) {
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
      });
      if (_currentLocation != null) {
        _mapController.animateCamera(CameraUpdate.newLatLngZoom(
          _currentLocation!,
          15.0,
        ));
        _markers.add(Marker(
          markerId: MarkerId(_currentLocation.toString()),
          position: _currentLocation!,
          icon: customMarkerIcon,
        ));
      }
    });
    loadUserInfo(context).then((List<Map<String, dynamic>> user) {
      setState(() {
        userInfo = user;
      });
      loadCustomMarkerIcon(userInfo.isNotEmpty ? userInfo[0]['vehiculeType'] : null).then((icon) {
        setState(() {
          customMarkerIcon = icon;
          _isloading = false;
        });
      });
    });
  }

  void _addMarkerStream(LatLng position) {
    Marker marker = Marker(
      markerId: MarkerId('marker_id'),
      position: position,
      infoWindow: InfoWindow(title: 'Marker Title', snippet: 'Marker Snippet'),
    );
    _markers.add(marker);
    _mapController.animateCamera((CameraUpdate.newLatLngZoom(
      position,  
      15.0,
    )));
  }

  void _addMarker(LatLng position) {
    setState(() {
      _markers.add(Marker(
        markerId: MarkerId(position.toString()),
        position: position,
      ));
    });
  }

  void _onQRViewCreatedU(QRViewController controller) {
    controller.scannedDataStream.listen((scanData) {
      scannedCode = scanData.code!;
      if (request.isNotEmpty && scannedCode == request[0]['orderID']) {
        controller.pauseCamera();
        showDialog(
          context: context, 
          builder: (context) {
            return AlertDialog(
              title: const Text("Confirmed Successfully"),
              actions: [
                TextButton(
                  onPressed: (){
                    controller.resumeCamera();
                    confirmRequest(
                      request[0]['id'],
                      request[0]['seller'],
                      request[0]['orderID'],
                      GeoPoint(
                        _currentLocation!.latitude,
                        _currentLocation!.longitude
                      )
                    );
                    Navigator.pop(context);
                    Navigator.pop(context);
                  }, 
                  child: const Text("Continue")
                )
              ],
            );
          },
        );
      }else{
        showDialog(
          context: context, 
          builder: (context) {
            return AlertDialog(
              title: const Text("Error"),
              content: const Text("QR code does not match the order ID"),
              actions: [
                TextButton(
                  onPressed: (){
                    controller.resumeCamera();
                    Navigator.pop(context);
                  }, 
                  child: const Text("Try again")
                )
              ],
            );
          },
        );
      }
    });
  }

  void _onQRViewCreatedD(QRViewController controller) {
    controller.scannedDataStream.listen((scanData) {
      scannedCode = scanData.code!;
      if (request.isNotEmpty && scannedCode == request[0]['orderID']) {
        controller.pauseCamera();
        showDialog(
          context: context, 
          builder: (context) {
            return AlertDialog(
              title: const Text("Confirmed Successfully"),
              actions: [
                TextButton(
                  onPressed: (){
                    controller.resumeCamera();
                    confirmDelivery(
                      request[0]['id'],
                      request[0]['seller'],
                      request[0]['orderID'],
                      GeoPoint(
                        _currentLocation!.latitude,
                        _currentLocation!.longitude
                      )
                    );
                    Navigator.pop(context);
                    Navigator.pop(context);
                  }, 
                  child: const Text("Continue")
                )
              ],
            );
          },
        );
      }else{
        showDialog(
          context: context, 
          builder: (context) {
            return AlertDialog(
              title: const Text("Error"),
              content: const Text("QR code does not match the order ID"),
              actions: [
                TextButton(
                  onPressed: (){
                    controller.resumeCamera();
                    Navigator.pop(context);
                  }, 
                  child: const Text("Try again")
                )
              ],
            );
          },
        );
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    controller.pauseCamera();
    controller.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused) {
      //setUserStatusOffline();
    }
    if(state == AppLifecycleState.resumed && _isOnline == true){
      //changeStatus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: AppColors().primaryColor),
        title: Center(
          child: Image(
            image: AssetImage(ImagePaths().blackHorizontalLogo),
            height: 150,
          ),
        ),
        backgroundColor: AppColors().secondaryColor,
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: _isOnline ? AppColors().activate : AppColors().unActivate,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 45,
                    backgroundImage: userInfo.isNotEmpty && userInfo[0]['profilePicture'] != null
                        ? NetworkImage(userInfo[0]['profilePicture'])
                        : NetworkImage(ImagePaths().defaultProfilePicture),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        userInfo.isNotEmpty && userInfo[0]['firstname'] != null && userInfo[0]['lastname'] != null
                        ?userInfo[0]['firstname'] + ' ' + userInfo[0]['lastname']
                        :'Unknown User',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Icon(
                        getVehicleIcon(userInfo.isNotEmpty ? userInfo[0]['vehicleType'] : null),
                        color: Colors.white,
                      )
                    ],
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(
                Icons.person_outline,
                color: AppColors().primaryColor,
              ),
              title: Text(
                'Profile',
                style: TextStyle(
                  color: AppColors().primaryColor,
                  fontSize: 17,
                ),
              ),
              onTap: () {
                Navigator.pushNamed(context, '/profile');
              },
            ),
            ListTile(
              leading: Icon(
                Icons.wallet_membership_outlined,
                color: AppColors().primaryColor,
              ),
              title: Text(
                'Wallet',
                style: TextStyle(
                  color: AppColors().primaryColor,
                  fontSize: 17,
                ),
              ),
              onTap: () {
                Navigator.pushNamed(context, '/wallet');
              },
            ),
            ListTile(
              leading: Icon(
                Icons.settings_outlined,
                color: AppColors().primaryColor,
              ),
              title: Text(
                'Settings',
                style: TextStyle(
                  color: AppColors().primaryColor,
                  fontSize: 17,
                ),
              ),
              onTap: () {
              },
            ),
            Divider(
              color: AppColors().borderColor,
              thickness: 0.5,
              endIndent: 30,
              indent: 30,
            ),
            ListTile(
              leading: Icon(
                Icons.help_outline,
                color: AppColors().primaryColor,
              ),
              title: Text(
                'Help Center',
                style: TextStyle(
                  color: AppColors().primaryColor,
                  fontSize: 17,
                ),
              ),
              onTap: () {
              },
            ),
            ListTile(
              leading: Icon(
                Icons.info_outline,
                color: AppColors().primaryColor,
              ),
              title: Text(
                'About us',
                style: TextStyle(
                  color: AppColors().primaryColor,
                  fontSize: 17,
                ),
              ),
              onTap: () {
              },
            ),
            ListTile(
              leading: Icon(
                Icons.privacy_tip_outlined,
                color: AppColors().primaryColor,
              ),
              title: Text(
                'Terms and Conditions',
                style: TextStyle(
                  color: AppColors().primaryColor,
                  fontSize: 17,
                ),
              ),
              onTap: () {
              },
            ),
            Divider(
              color: AppColors().borderColor,
              thickness: 0.5,
              endIndent: 30,
              indent: 30,
            ),
            ListTile(
              leading: const Icon(
                Icons.logout,
                color: Colors.red,
              ),
              title: const Text(
                'Logout',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 17,
                ),
              ),
              onTap: () {
                signOut(context);
              },
            ),
          ],
        ),
      ),
      body: _isloading
      ?  Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors().primaryColor),
            ),
      )
      :Stack(
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * 0.6,
            child: GoogleMap(
              onMapCreated: (controller) {
                _mapController = controller;
              },
              initialCameraPosition: _currentLocation != null
              ? CameraPosition(
                target: _currentLocation!,
                zoom: 13.0,
              )
              : const CameraPosition(
                target: LatLng(0, 0),
                zoom: 13.0,
              ),
              markers: _currentLocation != null
                ? _markers
                : {},
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,            
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height*0.2,
              decoration: BoxDecoration(
                color: AppColors().secondaryColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20.0),
                  topRight: Radius.circular(20.0)
                ),
                border: Border.all(
                  color: AppColors().primaryColor,
                  width: 2
                )
              ),
              child: _isOnline
              ? _accepted == false
                ? StreamBuilder(
                  stream: getRequest(), 
                  builder: (context, snapshot) {
                    List<dynamic> requests = snapshot.data ?? [];
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return SizedBox(
                        width: MediaQuery.of(context).size.width*0.1,
                        height: MediaQuery.of(context).size.height*0.1,
                        child: CircularProgressIndicator(
                          color: AppColors().primaryColor,
                        ),
                      );
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      return ListView.builder(
                        padding: const EdgeInsets.all(10),
                        itemCount: requests.length,
                        itemBuilder: (BuildContext context, int index) {
                          if(requests[index]['status']=="pending"){
                            return Column(
                              children: [
                                SizedBox(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(requests[index]['status'].toString()),
                                      Row(
                                        children: [
                                          IconButton(
                                            onPressed: (){
                                              Navigator.push(
                                                context, 
                                                MaterialPageRoute(builder: (context) => OrderOverview(
                                                  orderID: requests[index]['orderID'],
                                                  sellerID: requests[index]['seller'],                                                  
                                                ))
                                              );
                                            }, 
                                            icon: Icon(
                                              Icons.remove_red_eye_outlined,
                                              color: AppColors().primaryColor,
                                            )
                                          ),
                                          IconButton(
                                            onPressed: (){
                                              acceptRequest(requests[index]['id']);
                                              _addMarker(
                                                LatLng(
                                                  requests[index]['location'].latitude,
                                                  requests[index]['location'].longitude
                                                )
                                              );
                                              setState(() {
                                                _accepted = true;
                                                request = [requests[index]];
                                              });
                                            }, 
                                            icon: Icon(
                                              Icons.check,
                                              color: AppColors().borderColor,
                                            )
                                          ),
                                          IconButton(
                                            onPressed: (){
                                            }, 
                                            icon: const Icon(
                                              Icons.close,
                                              color: Colors.red,
                                            )
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                                Divider(
                                  color: AppColors().primaryColor,
                                  endIndent: 20,
                                  indent: 20,
                                )
                              ],
                            );
                          } else {
                            return const SizedBox();
                          }
                        }
                      );
                    }
                  },
                )
                : Center(
                  child: StreamBuilder<List<dynamic>>(
                    stream: getRequestStatusStream(request[0]['orderID'].toString()),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator(
                          color: AppColors().primaryColor,
                        );
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else {
                        List<dynamic> statuses = snapshot.data ?? [];
                        if (statuses.isEmpty) {
                          return const Text('No status data');
                        } else {
                          if(statuses[0]['status'] == 'delivred'){
                            finishRequest(request[0]['id']);
                            _accepted = false;
                            request = [];
                            _markers.clear();
                            _addMarkerStream( LatLng(
                                _currentLocation!.latitude,
                                _currentLocation!.longitude
                              )
                            );
                          } if(statuses[0]['status'] == 'confirmed'){
                            return Column(
                              children: [
                                const SizedBox(height: 10),
                                CircularProgressIndicator(
                                  color: AppColors().primaryColor,
                                ),
                                const SizedBox(height: 10),
                                SizedBox(
                                  width: MediaQuery.of(context).size.width*0.8,
                                  child: const Text('When you arrive at the location, press confirm to start the delivery')
                                ),
                                const SizedBox(height: 10),
                                ElevatedButton(
                                  style: ButtonStyle(
                                    fixedSize: MaterialStateProperty.all(
                                      Size(
                                        MediaQuery.of(context).size.width * 0.4,
                                        MediaQuery.of(context).size.height * 0.05,
                                      ),
                                    ),
                                    backgroundColor: MaterialStateProperty.all(AppColors().primaryColor),
                                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15.0),
                                        side: BorderSide(color: AppColors().borderColor),
                                      ),
                                    ),
                                  ),
                                  onPressed: (){
                                    arriveRequest(request[0]['id']);
                                  }, 
                                  child: const Text(
                                    "Confirm",
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                )
                              ],
                            );
                          } if(statuses[0]['status'] == 'arrived'){
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text("Scan the QR code to confirm the loading"),
                                const SizedBox(height: 10),
                                IconButton(
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(AppColors().primaryColor),
                                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15.0),
                                        side: BorderSide(color: AppColors().borderColor),
                                      ),
                                    ),
                                  ),
                                  onPressed: () async {
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return Dialog.fullscreen(
                                          child: SizedBox(
                                            width: double.infinity,
                                            height: double.infinity,
                                            child: Stack(
                                              children: [
                                                QRView(
                                                  key: qrKey,
                                                  onQRViewCreated: _onQRViewCreatedU,
                                                ),
                                                Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Center(
                                                      child: Container(
                                                        width: MediaQuery.of(context).size.width*0.6,
                                                        height:  MediaQuery.of(context).size.height*0.3,
                                                        decoration: BoxDecoration(
                                                          border: Border.all(
                                                            color: AppColors().primaryColor,
                                                            width: 2,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(height: 20,),
                                                    const Text(
                                                      "Scan qr code",
                                                      style: TextStyle(
                                                        fontSize: 15,
                                                        fontWeight: FontWeight.bold,
                                                        color: Colors.white
                                                      ),
                                                    ),
                                                  ],
                                                )
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.qr_code_scanner,
                                    color: Colors.white,
                                    size: 50,
                                  ),
                                ),
                              ],
                            );
                          } if(statuses[0]['status'] == 'delivering'){
                            _markers.clear();
                            if(buyerInfo.isEmpty){
                              loadBuyerInfo(statuses[0]['orderID'], statuses[0]['seller']).then((value) {
                                buyerInfo = value;
                                _addMarkerStream(
                                  LatLng(
                                    buyerInfo[0]['location'].latitude,
                                    buyerInfo[0]['location'].longitude
                                  )
                                );
                              });
                              DatabaseReference databaseReference = FirebaseDatabase.instance.ref();
                              databaseReference.child('deliveries').child(statuses[0]['orderID']).child('location').set({
                                'latitude': _currentLocation!.latitude,
                                'longitude': _currentLocation!.longitude,
                              });
                            }
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text("Scan the qr code to confirm the delivery"),
                                const SizedBox(height: 10),
                                IconButton(
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(AppColors().primaryColor),
                                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15.0),
                                        side: BorderSide(color: AppColors().borderColor),
                                      ),
                                    ),
                                  ),
                                  onPressed: () async {
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return Dialog.fullscreen(
                                          child: SizedBox(
                                            width: double.infinity,
                                            height: double.infinity,
                                            child: Stack(
                                              children: [
                                                QRView(
                                                  key: qrKey,
                                                  onQRViewCreated: _onQRViewCreatedD,
                                                ),
                                                Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Center(
                                                      child: Container(
                                                        width: MediaQuery.of(context).size.width*0.6,
                                                        height:  MediaQuery.of(context).size.height*0.3,
                                                        decoration: BoxDecoration(
                                                          border: Border.all(
                                                            color: AppColors().primaryColor,
                                                            width: 2,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(height: 20,),
                                                    const Text(
                                                      "Scan qr code",
                                                      style: TextStyle(
                                                        fontSize: 15,
                                                        fontWeight: FontWeight.bold,
                                                        color: Colors.white
                                                      ),
                                                    ),
                                                  ],
                                                )
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.qr_code_scanner,
                                    color: Colors.white,
                                    size: 50,
                                  ),
                                ),
                              ],
                            );
                          } else {
                            return const SizedBox();
                          }
                        }
                      }
                    },
                  ),
                )
              : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.warning,
                    color: AppColors().primaryColor,
                  ),
                  const SizedBox(width: 10),
                  const Text("You are offline"),
                ],
              ),
            )
          )
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        color: AppColors().secondaryColor,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/profile');
              },
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors().primaryColor,
                    width: 2,
                  ),
                ),
                child: CircleAvatar(
                  radius: 13,
                  backgroundImage: userInfo.isNotEmpty && userInfo[0]['profilePicture'] != null
                  ? NetworkImage(userInfo[0]['profilePicture'])
                  : NetworkImage(ImagePaths().defaultProfilePicture),
                ),
              ),
            ),
            VerticalDivider(
              color: AppColors().borderColor,
              thickness: 1.5,
            ),
            Switch(
              activeColor: AppColors().activate,
              value: _isOnline,
              onChanged: (value) {
                changeStatus();
                setState(() {
                  _isOnline = value;
                });
              },
            ),
            Text(
              _isOnline ? 'Online' : 'Offline',
              style: TextStyle(
                fontWeight: _isOnline ? FontWeight.bold : FontWeight.normal,
                color: _isOnline ? AppColors().activate : AppColors().unActivate,
                fontSize: 17,
              ),
            ),
            VerticalDivider(
              color: AppColors().borderColor,
              thickness: 1.5,
            ),
            IconButton(
              onPressed: (){
                Navigator.pushNamed(context, '/wallet');
              }, 
              icon: Icon(
                Icons.wallet,
                color: AppColors().primaryColor,
                size: 30
              )
            )
          ],
        ),
      ),
    );
  }
}
