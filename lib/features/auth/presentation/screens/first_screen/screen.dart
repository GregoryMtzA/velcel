import 'package:flutter/material.dart';
import 'pages/first_page.dart';
import 'pages/second_page_select.dart';

class FirstScreen extends StatelessWidget {

  FirstScreen({super.key});

  final PageController _pageController = PageController(initialPage: 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: PageView(
          controller: _pageController,
          children: [
        
            FirstPage(
              onTap: () => _pageController.animateToPage(
                1,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeIn,
              ),
            ),
        
            const SecondPageSelect()
        
          ],
        ),
      ),
    );
  }
}
