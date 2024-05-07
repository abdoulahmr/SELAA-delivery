import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:selaa_delivery/firebase_options.dart';
import 'package:selaa_delivery/screens/settings/account_settings.dart';
import 'package:selaa_delivery/screens/splash.dart';
import 'package:selaa_delivery/screens/user/home.dart';
import 'package:selaa_delivery/screens/user/user_profil.dart';
import 'package:selaa_delivery/screens/user/wallet.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const Main());
}

class Main extends StatefulWidget {
  const Main({super.key});

  @override
  State<Main> createState() => _MainState();
}

class _MainState extends State<Main> {
  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const Splash(),
      routes: {
        '/home': (context) => const HomePage(),
        '/profile': (context) => const UserProfile(),
        '/settings': (context) => const SettingsList(),
        '/wallet': (context) => const WalletScreen(),
      },
    );
  }
}

class Splash extends StatelessWidget {
  const Splash({super.key});

  @override
  Widget build(BuildContext context) {
    return const AfterSplash();
  }
}