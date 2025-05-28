import 'package:cureeit_user_app/BaseUrl.dart';
import 'package:cureeit_user_app/cards/favorites_card.dart';
import 'package:cureeit_user_app/user/user.dart';
import 'package:cureeit_user_app/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  late Future<List<String>> favoritesFuture;

  @override
  void initState() {
    super.initState();
    favoritesFuture = fetchFavorites();
  }

  Future<List<String>> fetchFavorites() async {
    const url =
        '$baseUrl/product/getfavouritesList';

    var request = http.Request('GET', Uri.parse(url))
      ..headers.addAll({
        'Content-Type': 'application/json',
      })
      ..body = jsonEncode({'userId': User.userId});

    var response = await http.Client().send(request);

    if (response.statusCode == 200) {
      var responseBody = await response.stream.bytesToString();
      Map<String, dynamic> data = jsonDecode(responseBody);
      List<String> favouriteItems =
          List<String>.from(data['data']['favouritesItem']);
      return favouriteItems;
    } else {
      throw Exception('Failed to load favorites');
    }
  }

  void refreshFavorites() {
    setState(() {
      favoritesFuture = fetchFavorites();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ligtBlackColor,
        leadingWidth: 200,
        toolbarHeight: 60,
        leading: Padding(
          padding:  EdgeInsets.only(left: 12.0, top: 16, ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Favorites",
                style: GoogleFonts.mulish(
                    fontWeight: FontWeight.w600,
                    fontSize: MediaQuery.of(context).size.width * 0.06,
                    
                    color: whiteColor),
              ),
            ],
          ),
        ),
      ),
      body: Container(
        padding:EdgeInsets.only(top: 24,bottom: 40,left: 20,right: 20),
        margin: EdgeInsets.only(bottom: 20),
        color: scaffoldBlackColor,
        child: FutureBuilder<List<String>>(
          future: favoritesFuture, // use stored future
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Container(
                color: scaffoldBlackColor,
                child: Center(
                    child: CircularProgressIndicator(
                  color: whiteColor,
                )),
              );
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('No favorites found.'));
            } else {
              final favoritesList = snapshot.data!;
              return ListView.builder(
                itemCount: favoritesList.length,
                itemBuilder: (context, index) {
                  final productId = favoritesList[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: FavoritesCard(
                      productId: productId,
                      onUpdate: refreshFavorites, // trigger setState
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}
