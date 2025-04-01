import 'package:cureeit_user_app/screens/cart_screen.dart';
import 'package:cureeit_user_app/screens/favorites_screen.dart';
import 'package:cureeit_user_app/screens/home_screen.dart';
import 'package:cureeit_user_app/screens/orders_screen.dart';
import 'package:cureeit_user_app/utils/theme.dart';
import 'package:flutter/material.dart';

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
          child: Scaffold(
            body: Stack(
              children: [
                TabBarView(children: [
                  Center(child: HomeScreen()),
                  Center(child: FavoritesScreen()),
                  Center(child: OrdersScreen()),
                  Center(child: CartScreen()),
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
                        color: Colors.white,
                        child: TabBar(
                          unselectedLabelColor: Colors.black.withOpacity(0.8),
                          labelColor: secondaryColor,
                          indicatorColor: Colors.transparent,
                          labelStyle:
                              TextStyle(fontFamily: "Urbanist", fontSize: 12),
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
          )),
    );
  }
}
