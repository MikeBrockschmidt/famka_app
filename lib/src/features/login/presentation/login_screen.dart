import 'package:famka_app/src/common/headline_k.dart';
import 'package:famka_app/src/data/database_repository.dart';
import 'package:flutter/material.dart';
import 'package:famka_app/src/common/color_row.dart';
import 'package:famka_app/src/features/login/presentation/widgets/login_window.dart';

class LoginScreen extends StatelessWidget {
  // Atribute
  final DatabaseRepository db;

  // Konstrukter
  const LoginScreen(this.db, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 1,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          HeadlineK(screenHead: 'famka'),
          Padding(
            padding: EdgeInsets.only(left: 28, top: 130),
            child: Text(
              'Login',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          Expanded(child: SizedBox()),
        ],
      ),
      bottomNavigationBar: Stack(
        children: [
          ColorRow(),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: CustomBottomNavigationBar(),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: LoginWindow(db),
          ),
        ],
      ),
    );
  }
}

class CustomBottomNavigationBar extends StatelessWidget {
  const CustomBottomNavigationBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [],
    );
  }
}
