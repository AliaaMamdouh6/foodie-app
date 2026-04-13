import 'package:flutter/material.dart';
import 'signup.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class Welcome extends StatefulWidget {
  const Welcome({super.key});

  @override
  State<Welcome> createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> {
  final PageController _controller = PageController();
  bool isLastPage = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          /// PAGE VIEW
          PageView(
            controller: _controller,
            onPageChanged: (index) {
              setState(() {
                isLastPage = index == 2;
              });
            },
            children: [

              /// -------- PAGE 1 ----------
              buildPage(
                image: 'assets/delivery.png',
                title: "Speed Meets Flavor",
                description:
                    "Get your favorite meals delivered quickly and safely, right to your doorstep.",
              ),

              /// -------- PAGE 2 ----------
              buildPage(
                image: 'assets/fresh.png',
                title: "Crafted Fresh, Served with Care",
                description:
                    "Every dish is made with fresh ingredients and prepared with care to ensure the best taste and quality.",
              ),

              /// -------- PAGE 3 ----------
              buildPage(
                image: 'assets/order.png',
                title: "Your Cravings Start Here",
                description:
                    "Hungry? Order now and enjoy your favorite meal in just a few taps.",
              ),
            ],
          ),

          /// SKIP BUTTON
          Positioned(
            top: 60,
            right: 20,
            child: TextButton(
              onPressed: () => _controller.jumpToPage(2),
              child: Text('skip'.tr()),
            ),
          ),

          /// DOT INDICATOR
          Positioned(
            bottom: 120,
            left: 0,
            right: 0,
            child: Center(
              child: SmoothPageIndicator(
                controller: _controller,
                count: 3,
                effect: const WormEffect(
                  dotHeight: 10,
                  dotWidth: 10,
                  activeDotColor: Colors.deepOrangeAccent,
                ),
              ),
            ),
          ),

          /// NEXT / GET STARTED BUTTON
          Positioned(
            bottom: 60,
            right: 20,
            child: isLastPage
                ? ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrangeAccent,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 15),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SignUp(),
                        ),
                      );
                    },
                    child: Text('get_started'.tr()),
                  )
                : ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrangeAccent,
                    ),
                    onPressed: () {
                      _controller.nextPage(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: Text('next'.tr()),
                  ),
          ),
        ],
      ),
    );
  }

  Widget buildPage({
    required String image,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(image, height: 250),
          const SizedBox(height: 30),
          Text(
            title,
            style: const TextStyle(fontSize: 24),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Text(
            description,
            textAlign: TextAlign.center,
           
          ),
        ],
      ),
    );
  }
}