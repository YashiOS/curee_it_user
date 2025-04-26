import 'dart:convert';

import 'package:cureeit_user_app/cubit/service_avilable_cubit.dart';
import 'package:cureeit_user_app/screens/cart_screen.dart';
import 'package:cureeit_user_app/screens/favorites_screen.dart';
import 'package:cureeit_user_app/screens/home_screen.dart';
import 'package:cureeit_user_app/screens/orders_screen.dart';
import 'package:cureeit_user_app/selected_Address/currentAddress.dart';
import 'package:cureeit_user_app/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

class BaseScreen extends StatefulWidget {
  const BaseScreen({super.key});

  @override
  State<BaseScreen> createState() => _BaseScreenState();
}

class _BaseScreenState extends State<BaseScreen> {
  

   

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DefaultTabController(
          length: 4,
          child: BlocBuilder<ServiceAvilableCubit,ServiceAvilableState>(
            builder: (context, state){
              if(state is ServiceIsAvilable){
                return Scaffold(
                  backgroundColor: ligtBlackColor,
              body: Stack(
                children: [
                  TabBarView(children: [
                    Center(child: HomeScreen()),
                    Center(child: FavoritesScreen()),
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
                          decoration: BoxDecoration(
                              color: scaffoldBlackColor,
                              border: Border.all(
                                  color: scaffoldBlackColor)),
                          child: TabBar(
                            unselectedLabelColor: greyColor,
                            labelColor: whiteColor,
                            indicatorColor: greenColor,
                            labelStyle:
                                GoogleFonts.mulish(fontSize: 12),
                            tabs: [
                              Tab(icon: Icon(Icons.house_outlined), text: "Home"),
                              Tab(
                                  icon: Icon(Icons.favorite_border_outlined),
                                  text: "Favorites"),
                              Tab(icon: Icon(Icons.lock_clock), text: "Orders"),
                              Tab(icon: Icon(Icons.trolley), text: "Cart"),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
              }
              if(state is ServiceIsNotAvilable){
                return Scaffold(body: HomeScreen(),);
              }
              else{
                return Scaffold(body:HomeScreen());
              }
            },
             
          )),
    );
  }
}
