// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:selaa_delivery/backend_functions/links.dart';
import 'package:selaa_delivery/backend_functions/load_data.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  _WalletScreenState createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  List<Map<String, dynamic>> userInfo = [];
  String userID = '';

  @override
  void initState() { 
    super.initState();
    loadUserInfo(context).then((List<Map<String, dynamic>> user) {
      setState(() {
        userInfo = user;
      });
    });  
    userId().then((String id) {
      setState(() {
        userID = id;
      });
    });
  }
    
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wallet'),
        actions: [
          IconButton(
            onPressed: (){
              showModalBottomSheet<void>(
                context: context,
                builder: (BuildContext context) {
                  return SizedBox(
                    height: MediaQuery.of(context).size.height*0.4,
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            const Text("Your ID Code: ",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500
                              ),
                            ),
                            ElevatedButton(
                              onPressed: (){
                                Navigator.pop(context);
                              }, 
                              style: ButtonStyle(
                                fixedSize: MaterialStateProperty.all(
                                  Size(
                                    MediaQuery.of(context).size.width*0.3, 
                                    MediaQuery.of(context).size.height*0.05
                                  ),
                                ),
                                backgroundColor: MaterialStateProperty.all(AppColors().primaryColor),
                                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20.0),
                                    side: BorderSide(color: AppColors().primaryColor),
                                  ),
                                ),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  Text(
                                    "close",
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.white
                                    )
                                  ),
                                  Icon(
                                    Icons.close,
                                    color: Colors.white,
                                  )
                                ],
                              )
                            )
                          ],
                        ),
                        QrImageView(
                          data: userID,
                          version: QrVersions.auto,
                          size: 200,
                        ),     
                      ],
                    ),
                  );
                },
              );
            }, 
            icon: const Icon(
              Icons.qr_code,
              size: 30,
            )
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height*0.2,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors().secondaryColor,
                borderRadius: const BorderRadius.all(Radius.circular(20.0)),
                border: Border.all(
                  color: AppColors().primaryColor,
                  width: 2
                )
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.monetization_on_outlined,
                        size: 30,
                        color: AppColors().primaryColor,
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        "Current balance:",
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w500
                        ),
                      ),
                    ],
                  ),
                  Text(
                    userInfo.isNotEmpty && userInfo[0]['balance'] != null
                    ?"${userInfo[0]['balance'].toStringAsFixed(3)} DZD"
                    :'0 DZD',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                      color: AppColors().primaryColor
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Total delivery:",
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColors().borderColor
                  ),
                ),
                Text(
                  userInfo.isNotEmpty && userInfo[0]['deliveryCount'] != null
                  ?" ${userInfo[0]['deliveryCount']}"
                  :' 0 ',
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColors().primaryColor
                  ),
                )
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Total delivery distance:",
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColors().borderColor
                  ),
                ),
                Text(
                  userInfo.isNotEmpty && userInfo[0]['totalDistance'] != null
                  ?" ${userInfo[0]['totalDistance'].toStringAsFixed(3)} km"
                  :' 0 km',
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColors().primaryColor
                  ),
                )
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: (){}, 
              style: ButtonStyle(
                fixedSize: MaterialStateProperty.all(
                  Size(
                    MediaQuery.of(context).size.width*0.8, 
                    MediaQuery.of(context).size.height*0.05
                  ),
                ),
                backgroundColor: MaterialStateProperty.all(AppColors().primaryColor),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    side: BorderSide(color: AppColors().primaryColor),
                  ),
                ),
              ),
              child: const Text(
                'Request Payment',
                style: TextStyle(
                  color: Colors.white
                ),
              )
            ),
            const SizedBox(height: 20),
            const Divider(
              indent: 20,
              endIndent: 20,
            ),
            const Row(
              children: [
                Icon(
                  Icons.history
                ),
                SizedBox(width: 10,),
                Text(
                  "Transaction History",
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w500
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
