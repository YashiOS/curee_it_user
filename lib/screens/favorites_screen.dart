import 'package:cureeit_user_app/cards/favorites_card.dart';
import 'package:cureeit_user_app/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  Future<List<String>> fetchFavorites() async {
    const url =
        'http://ec2-13-60-8-94.eu-north-1.compute.amazonaws.com:3000/product/getfavouritesList';

    var request = http.Request('GET', Uri.parse(url))
      ..headers.addAll({
        'Content-Type': 'application/json',
      })
      ..body = jsonEncode({'userId': "68fa72cbdc5f0a68"});

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey.shade100.withOpacity(0.5),
        leadingWidth: 200,
        toolbarHeight: 60,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12.0, top: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 20,
            children: [
              Text(
                "Favorites",
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 24,
                    fontFamily: "JosefinSans",
                    color: primaryColor),
              ),
            ],
          ),
        ),
      ),
      body: Container(
          color: Colors.grey.shade100.withOpacity(0.5),
          child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 0.0, horizontal: 18),
              child: Padding(
                padding: const EdgeInsets.only(top: 6.0),
                child: FutureBuilder<List<String>>(
                  future: fetchFavorites(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                          child: CircularProgressIndicator(
                        color: secondaryColor,
                      ));
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
                            child: FavoritesCard(productId: productId),
                          );
                        },
                      );
                    }
                  },
                ),
              ))),
    );
  }
}
