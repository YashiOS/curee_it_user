import 'dart:convert';
import 'dart:io';

import 'package:cureeit_user_app/LocalStorageCubit/store_user_cubit.dart';
import 'package:cureeit_user_app/cubit/service_avilable_cubit.dart';
import 'package:cureeit_user_app/screens/cart_screen.dart';
import 'package:cureeit_user_app/screens/favorites_screen.dart';
import 'package:cureeit_user_app/screens/home_screen.dart';
import 'package:cureeit_user_app/screens/orders_screen.dart';
import 'package:cureeit_user_app/selected_Address/currentAddress.dart';
import 'package:cureeit_user_app/user/user.dart';
import 'package:cureeit_user_app/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

class BaseScreen extends StatefulWidget {
  BaseScreen({super.key, required this.Navigatedfrom});
  final String Navigatedfrom;
  @override
  State<BaseScreen> createState() => _BaseScreenState();
}

class _BaseScreenState extends State<BaseScreen> {
  Map<String, dynamic>? userData;

  void storeDataGlobaly() {
    User.id = userData!["id"];
    User.name = userData!["name"];
    User.phoneNumber = userData!["phoneNumber"];
    User.userId = userData!["userId"];
  }

  @override
  void initState() {
    super.initState();
    if (widget.Navigatedfrom == "from_main") {
      final cubit = context.read<StoreUserCubit>();

      if (cubit.isUserDataAvailable()) {
        userData = cubit.getUserData();
        print("User data fetched: $userData");
        storeDataGlobaly();
      } else {
        print("No user data found in Hive.");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DefaultTabController(
          length: 3,
          child: BlocBuilder<ServiceAvilableCubit, ServiceAvilableState>(
            builder: (context, state) {
              if (state is ServiceIsAvilable) {
                return Builder(builder: (context) {
                  final TabController tabController =
                      DefaultTabController.of(context);
                  return Scaffold(
                    backgroundColor: ligtBlackColor,
                    body: Stack(
                      children: [
                        TabBarView(children: [
                          Center(child: HomeScreen()),
                          Center(child: OrdersScreen()),
                          Center(
                              child: CartScreen(
                            isNavigated: false,
                          )),
                        ]),
                        SizedBox(
                          height: MediaQuery.of(context).size.height,
                          width: MediaQuery.of(context).size.width,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width,
                                padding: EdgeInsets.only(
                                  bottom: Platform.isIOS
                                      ? 20.0
                                      : 0.0, // Add padding only for iOS
                                ),
                                decoration: BoxDecoration(
                                    color: scaffoldBlackColor,
                                    border:
                                        Border.all(color: scaffoldBlackColor)),
                                child: AnimatedBuilder(
                                    animation: tabController,
                                    builder: (context, _) {
                                      return TabBar(
                                        controller: tabController,
                                        unselectedLabelColor: greyColor,
                                        labelColor: whiteColor,
                                        indicatorColor: whiteColor,
                                        labelStyle:
                                            GoogleFonts.mulish(fontSize: 12),
                                        tabs: [
                                          Tab(
                                            icon: Container(
                                              height: 24,
                                              width: 24,
                                              child: Image.asset(
                                                "lib/images/Home.png",
                                                color: tabController.index == 0
                                                    ? whiteColor
                                                    : greyColor,
                                              ),
                                            ),
                                            text: "Home",
                                          ),
                                          Tab(
                                              icon: Container(
                                                  height: 24,
                                                  width: 24,
                                                  child: Image.asset(
                                                    "lib/images/Order Again.png",
                                                    color:
                                                        tabController.index == 1
                                                            ? whiteColor
                                                            : greyColor,
                                                  )),
                                              text: "Order Again"),
                                          Tab(
                                              icon: Icon(
                                                  Icons.shopping_cart_outlined),
                                              text: "Cart"),
                                        ],
                                      );
                                    }),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                });
              }
              if (state is ServiceIsNotAvilable) {
                return Scaffold(
                  body: HomeScreen(),
                );
              } else {
                return Scaffold(body: HomeScreen());
              }
            },
          )),
    );
  }
}
