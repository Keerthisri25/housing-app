import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:housing/pages/profile_page.dart';
import 'Screens/signin_screen.dart';
import 'Screens/signup_screen.dart';
import 'Screens/home_screen.dart';
import 'pages/sell_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyBVX59iX7oJLscwnFV5fHzZTZNDtCZx2Ac",
        authDomain: "housing-app-f987d.firebaseapp.com",
        projectId: "housing-app-f987d",
        storageBucket: "housing-app-f987d.appspot.com",
        messagingSenderId: "372238050338",
        appId: "1:372238050338:web:b66448a750ead09cd4967b",
      ),
    );
  } else {
    await Firebase.initializeApp();
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Housing App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/signin',
      routes: {
        '/signin': (context) => const SignInPage(),
        '/signup': (context) => const SignUpPage(),
        '/home': (context) => const HomeScreen(),
        '/sell': (context) => const SellPage(),
        '/profile': (context) => const ProfilePage(),
        
      },
    );
  }
}
