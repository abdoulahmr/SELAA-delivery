import 'package:flutter/material.dart';
import 'package:selaa_delivery/backend_functions/links.dart';
import 'package:selaa_delivery/backend_functions/load_data.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({super.key});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  List<Map<String, dynamic>> userInfo = [];
  
  @override
  void initState() { 
    super.initState();
    loadUserInfo(context).then((List<Map<String, dynamic>> user) {
      setState(() {
        userInfo = user;
      });
    });  
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profile',
        ),
        actions: [
          IconButton(
            onPressed: (){
              Navigator.pushNamed(context, '/settings');
            }, 
            icon: const Icon(
              Icons.settings,
              size: 30,
            )
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundImage: userInfo.isNotEmpty && userInfo[0]['profilePicture'] != null
                  ? NetworkImage(userInfo[0]['profilePicture'])
                  : NetworkImage(ImagePaths().defaultProfilePicture),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  userInfo.isNotEmpty && userInfo[0]['firstname'] != null && userInfo[0]['lastname'] != null
                  ?userInfo[0]['firstname'] + ' ' + userInfo[0]['lastname'] :'Unknown User',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 10),
                Icon(
                  Icons.verified,
                  color: userInfo.isNotEmpty && userInfo[0]['verified']!=null && userInfo[0]['verified']
                    ? AppColors().primaryColor
                    : Colors.grey
                ),
              ],
            ),
            const Divider(endIndent: 20,indent: 20),
            const SizedBox(height: 10),
            const Text(
              'Contact Information',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              userInfo.isNotEmpty && userInfo[0]['phoneNumber'] != null
              ? "Phone number: ${userInfo[0]['phoneNumber']}" :'Unknown User',
            ),
            const SizedBox(height: 5),
            Text(
              userInfo.isNotEmpty && userInfo[0]['email'] != null
              ? "Email: ${userInfo[0]['email']}" :'Unknown User',
            ),
            const SizedBox(height: 10),
            const Text(
              'Vehicule Information',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Text(
                  userInfo.isNotEmpty && userInfo[0]['vehiculeType'] != null
                  ? "Vehicule type: ${userInfo[0]['vehiculeType']}" :'Unknown User',
                ),
                const SizedBox(width: 10),
                Icon(
                  getVehicleIcon(userInfo.isNotEmpty ? userInfo[0]['vehicleType'] : null),
                  color: AppColors().primaryColor,
                ),
              ],
            ),
            const SizedBox(height: 5),
            Text(
              userInfo.isNotEmpty && userInfo[0]['brand'] != null
              ? "Vehicule brand: ${userInfo[0]['brand']}" :'Unknown User',
            ),
            const SizedBox(height: 5),
            Text(
              userInfo.isNotEmpty && userInfo[0]['model'] != null
              ? "Vehicule model: ${userInfo[0]['model']}" :'Unknown User',
            ),
            const SizedBox(height: 5),
            Text(
              userInfo.isNotEmpty && userInfo[0]['licencePlate'] != null
              ? "Vehicule licence plate: ${userInfo[0]['licencePlate']}" :'Unknown User',
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}