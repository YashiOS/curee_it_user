import 'dart:convert';
import 'package:cureeit_user_app/BaseUrl.dart';
import 'package:cureeit_user_app/screens/item_detail_screen.dart';
import 'package:cureeit_user_app/user/user.dart';
import 'package:cureeit_user_app/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SearchCard extends StatefulWidget {
  final String productId;
  const SearchCard({super.key, required this.productId});

  @override
  State<SearchCard> createState() => _SearchCardState();
}

class _SearchCardState extends State<SearchCard> {
  bool isFav = false; // Variable to track if the product is in favourites
  Future<void> addToFavourites() async {
    final String apiUrl =
        "$baseUrl/product/favourites";

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "productId": widget.productId,
          "userId": User.userId,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['status'] == 200) {
          checkIfFav(); // Re-check the favourites after adding
        } else {
          print("Failed to add item to favourites: ${response.body}");
        }
      } else {
        print("Failed to add item to favourites: ${response.body}");
      }
    } catch (error) {
      print("Error adding to favourites: $error");
    }
  }

  // Function to check if the product is in the favourites list
  Future<void> checkIfFav() async {
    try {
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
        Map<String, dynamic> responseData = jsonDecode(responseBody);
        if (responseData['status'] == 200) {
          List<dynamic> favouritesList =
              responseData['data']['favouritesItem'] ?? [];

          setState(() {
            // Check if the productId is in the favourites list
            isFav = favouritesList.contains(widget.productId);
          
          });
        } else {
          print(
              "Failed to fetch favourites: ${response.stream.bytesToString()}");
        }
      } else {
        print("Failed to fetch favourites: ${response.stream.bytesToString()}");
      }
    } catch (error) {
      print("Error fetching favourites: $error");
    }
  }

  @override
  void initState() {
    super.initState();
    checkIfFav(); // Check if this product ID is in the favourites
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ItemDetailScreen(productId: "NEULEA33"),
      ),
    );
  },
  child: Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Container(
      padding:  EdgeInsets.symmetric(vertical: 12, horizontal: MediaQuery.of(context).size.width*0.03),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.25,
            child: Image.asset("lib/images/neurobionForte.png"),
          ),
          const SizedBox(width: 8),

          // Right Section
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Title and Fav Icon Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Title
                    Expanded(
                      child: Text(
                        "Neurobion Forte Tablet with Vitamin B12 | Helps Manage Numbness and Tingling Sensation",
                        style: const TextStyle(
                          fontFamily: "JosefinSans",
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1F1970),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    // Favourite Button
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          isFav = !isFav;
                        });
                        addToFavourites();
                      },
                      child: Icon(
                        isFav
                            ? Icons.favorite
                            : Icons.favorite_border_rounded,
                        color: isFav ? secondaryColor : primaryColor,
                        size: 20,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 4),

                /// Pack Label
                Text(
                  "10 Tablets",
                  style: TextStyle(
                    fontFamily: "Urbanist",
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Colors.black.withValues(alpha: 0.8),
                  ),
                ),

                const SizedBox(height: 4),

                /// Price Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Original Price
                    Row(
                      children: [
                        Text(
                          "₹ ",
                          style: TextStyle(
                            fontFamily: "Urbanist",
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: Colors.black.withValues(alpha: 0.6),
                          ),
                        ),
                        Text(
                          "208.50",
                          style: TextStyle(
                            fontFamily: "Urbanist",
                            fontSize: 10,
                            decoration: TextDecoration.lineThrough,
                            fontWeight: FontWeight.w500,
                            color: Colors.black.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),

                    // Discounted Price
                    Text(
                      "₹ 140.30",
                      style: TextStyle(
                        fontFamily: "Urbanist",
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Colors.black.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    ),
  ),
);

  }
}
