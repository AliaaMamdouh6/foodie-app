import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'welcome.dart';
import 'home.dart';
import 'signin.dart';
import 'signup.dart';
import 'cart.dart';
import 'splash.dart';
import 'product.dart';
import 'profile.dart';
import 'forget.dart';
import 'auth_service.dart';
import 'offers.dart';
import 'category.dart';
import 'orders.dart';

/// ===========================
/// MAIN FUNCTION
/// ===========================
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await EasyLocalization.ensureInitialized();
  await Firebase.initializeApp();

  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('ar', 'EG'),
      ],
      path: 'assets/lang',
      fallbackLocale: const Locale('en', 'US'),
      child: const Foodie(),
    ),
  );
}

/// ===========================
/// ROOT APP
/// ===========================
class Foodie extends StatelessWidget {
  const Foodie({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Foodie',

      /// Localization setup
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,

      /// ⭐ AUTH SESSION GATE
      home: AuthService.authGate(
        loggedInPage: const MainWrapper(),
        loginPage: const SignIn(),
      ),

      /// Named Routes
      routes: {
        '/welcome': (context) => const Welcome(),
        '/home': (context) => const MainWrapper(),
        '/signin': (context) => const SignIn(),
        '/signup': (context) => const SignUp(),
        '/cart': (context) => const Cart(),
        '/product': (context) => const Product(),
        '/profile': (context) => const Profile(),
        '/splash': (context) => const Splash(),
        '/forget': (context) => const Forget(),
        '/offers': (context) => const Offers(),
        '/category': (context) => Category(onCategorySelected: (_) {}),
        '/orders': (context) => const Orders(),
      },
    );
  }
}

/// ===========================
/// MAIN WRAPPER (Nav Bar)
/// ===========================
class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    Home(),
    Cart(),
    Profile(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: Colors.deepOrange,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}