import 'dart:io';

import 'package:cureeit_user_app/LocalStorageCubit/store_user_cubit.dart';
import 'package:cureeit_user_app/screens/cart/presentation/cart_screen.dart';
import 'package:cureeit_user_app/screens/home/presentation/home_screen.dart';
import 'package:cureeit_user_app/screens/home/presentation/providers/order_provider.dart';
import 'package:cureeit_user_app/screens/order%20again/orders_screen.dart';
import 'package:cureeit_user_app/user/user.dart';
import 'package:cureeit_user_app/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class BaseScreen extends ConsumerStatefulWidget {
  const BaseScreen({super.key, required this.Navigatedfrom});
  final String Navigatedfrom;


  @override
  ConsumerState<BaseScreen> createState() => _BaseScreenState();
}

class _BaseScreenState extends ConsumerState<BaseScreen> {
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
    final cubit = context.read<StoreUserCubit>();

    if (cubit.isUserDataAvailable()) {
      userData = cubit.getUserData();
      print("User data fetched: $userData");
      storeDataGlobaly();
    } else {
      print("No user data found in Hive.");
    }
  }

  @override
  Widget build(BuildContext context) {
    final serviceState = ref.watch(orderNotifierProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DefaultTabController(
        length: 3,
        child: Builder(builder: (context) {
          final tabController = DefaultTabController.of(context);

          // ✅ If location not available → show HomeScreen only
          if (serviceState.currentLocationAvailable == false) {
            return Scaffold(
              backgroundColor: lightBlackColor,
              body: HomeScreen(
                latitude: "100.0",
                longitude: "100.0",
              ),
            );
          }

          // ✅ Else show full app with bottom navigation
          return Scaffold(
            backgroundColor: Colors.black,
            body: Stack(
              children: [
                TabBarView(
                  children: [
                    HomeScreen(latitude: "100.0", longitude: "100.0"),
                    OrdersScreen(),
                    CartScreen(isNavigated: false),
                  ],
                ),
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
                          bottom: Platform.isIOS ? 10.0 : 0.0,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          border: Border.all(color: Colors.black),
                        ),
                        child: TabBar(
                          indicatorColor: greenColor,

                          controller: tabController,
                          labelColor: greenColor, // selected text & icon
                          unselectedLabelColor:
                              greyColor, // unselected text & icon
                          labelStyle: GoogleFonts.mulish(
                            fontWeight: FontWeight.bold, // selected bold
                            fontSize: 14,
                          ),
                          unselectedLabelStyle: GoogleFonts.mulish(
                            fontWeight: FontWeight.bold, // slightly bold
                            fontSize: 14,
                          ),
                          tabs: [
                            Tab(
                              icon: AnimatedBuilder(
                                animation: tabController,
                                builder: (context, _) => Image.asset(
                                  "lib/images/Home.png",
                                  height: 24,
                                  width: 24,
                                  color: tabController.index == 0
                                      ? greenColor
                                      : greyColor,
                                ),
                              ),
                              text: "Home",
                            ),
                            Tab(
                              icon: AnimatedBuilder(
                                animation: tabController,
                                builder: (context, _) => Image.asset(
                                  "lib/images/Order Again.png",
                                  height: 24,
                                  width: 24,
                                  color: tabController.index == 1
                                      ? greenColor
                                      : greyColor,
                                ),
                              ),
                              text: "Order Again",
                            ),
                            Tab(
                              icon: Icon(Icons.shopping_cart_outlined),
                              text: "Cart",
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
