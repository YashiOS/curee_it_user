import 'dart:convert';
import 'package:cureeit_user_app/screens/item_detail_screen.dart';
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
        "http://ec2-13-60-8-94.eu-north-1.compute.amazonaws.com:3000/product/favourites";

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "productId": widget.productId,
          "userId": "68fa72cbdc5f0a68",
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
          'http://ec2-13-60-8-94.eu-north-1.compute.amazonaws.com:3000/product/getfavouritesList';

      var request = http.Request('GET', Uri.parse(url))
        ..headers.addAll({
          'Content-Type': 'application/json',
        })
        ..body = jsonEncode({'userId': "68fa72cbdc5f0a68"});

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
            print(isFav);
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
                builder: (context) => ItemDetailScreen(
                      productId: "NEULEA33", // Pass the correct product ID here
                    )));
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Padding(
              padding: const EdgeInsets.only(top: 0.0),
              child: Column(
                children: [
                  Row(
                    spacing: 8,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width / 4,
                        child: Image.asset("lib/images/neurobionForte.png"),
                      ),
                      Column(
                        spacing: 8,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                width: MediaQuery.of(context).size.width / 2,
                                child: Text(
                                  "Neurobion Forte Tablet with Vitamin B12 | Helps Manage Numbness and Tingling Sensation",
                                  style: TextStyle(
                                    fontFamily: "JosefinSans",
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF1F1970),
                                  ),
                                  maxLines: 2,
                                ),
                              ),
                              Container(
                                alignment: Alignment.bottomRight,
                                child: GestureDetector(
                                  onTap: () {
                                    // Handle the logic to toggle the fav status
                                    setState(() {
                                      isFav = !isFav;
                                    });
                                  },
                                  child: GestureDetector(
                                    onTap: () {
                                      addToFavourites();
                                    },
                                    child: Icon(
                                      isFav
                                          ? Icons.favorite
                                          : Icons.favorite_border_rounded,
                                      color:
                                          isFav ? secondaryColor : primaryColor,
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                          Text(
                            "10 Tablets",
                            style: TextStyle(
                                fontFamily: "Urbanist",
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Colors.black.withOpacity(0.8)),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width / 1.8,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      "₹ ",
                                      style: TextStyle(
                                          fontFamily: "Urbanist",
                                          fontSize: 10,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black.withOpacity(0.6)),
                                    ),
                                    Text(
                                      "208.50",
                                      style: TextStyle(
                                          fontFamily: "Urbanist",
                                          fontSize: 10,
                                          decoration:
                                              TextDecoration.lineThrough,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black.withOpacity(0.6)),
                                    ),
                                  ],
                                ),
                                Text(
                                  "₹ 140.30",
                                  style: TextStyle(
                                      fontFamily: "Urbanist",
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.black.withOpacity(0.8)),
                                ),
                              ],
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
