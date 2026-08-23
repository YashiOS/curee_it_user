import 'dart:async';
import 'package:cureeit_user_app/LocalStorageCubit/store_user_cubit.dart';
import 'package:cureeit_user_app/screens/base_screen.dart';
import 'package:cureeit_user_app/screens/login/presentation/login_screen.dart';
import 'package:cureeit_user_app/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class Splashscreen extends StatefulWidget {
  const Splashscreen({super.key});

  @override
  State<Splashscreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<Splashscreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Animation setup
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1500),
    );
     
    _scaleAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
      ),
    );

    _controller.forward(); // Start animation
     final isAvailable = context.read<StoreUserCubit>().isUserDataAvailable();
    // Navigation after 2 seconds
    Timer(Duration(seconds: 3), () {
      if(isAvailable){
        Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) =>BaseScreen(Navigatedfrom: "splashScreen",)),
      );
      }
      else{
         Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) =>LoginScreen()),
      );
      }
      
    });
  }

  @override
  void dispose() {
    _controller.dispose(); // Clean up
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
     final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor:  scaffoldWhiteColor,
      body: Center( 
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Column(
            mainAxisSize: MainAxisSize.min, 
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
             
              Text(
                "medicine delivered in minutes!",
                style: GoogleFonts.mulish(
                  color: Colors.white,
                  fontSize: screenHeight * 0.022,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center, 
              ),
            ],
          ),
        ),
      ),
    );
  }
}
