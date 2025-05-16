
import 'package:cureeit_user_app/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';


class  LoadingScreen extends StatefulWidget {
  LoadingScreen({super.key});
  
  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
 




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldBlackColor,
      body: Center(
        child: Lottie.asset(
              'lib/images/Success_order.json',
              width: 350,
              height: 350,
              repeat: true,
            ),
      ),
    );
  }
}
