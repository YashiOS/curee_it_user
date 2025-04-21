import 'package:cureeit_user_app/screens/item_detail_screen.dart';
import 'package:cureeit_user_app/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FavoritesCard extends StatefulWidget {
  final String productId;
  final Function onUpdate;
  const FavoritesCard({super.key, required this.productId, required this.onUpdate});


  @override
  State<FavoritesCard> createState() => _FavoritesCardState();
}

class _FavoritesCardState extends State<FavoritesCard> {
  bool isLoading = true;
  String productName = '';
  String productImage = '';

  @override
  void initState() {
    super.initState();
    fetchProductDetails();
  }

  Future<void> fetchProductDetails() async {
    try {
      var url = Uri.parse(
          'http://ec2-13-60-8-94.eu-north-1.compute.amazonaws.com:3000/product/productDetail');
      var request = http.Request('GET', url)
        ..headers.addAll({
          'Content-Type': 'application/json',
        })
        ..body = jsonEncode({'productId': widget.productId});

      var response = await http.Client().send(request);

      if (response.statusCode == 200) {
        var responseBody = await response.stream.bytesToString();
        Map<String, dynamic> responseData = jsonDecode(responseBody);
        setState(() {
          productName = responseData['data']['name'];
          isLoading = false;
          if (responseData['data']['imageUrls'].length > 0) {
            productImage = responseData['data']['imageUrls'][0];
          }
        });
      } else {
        throw Exception('Failed to load product details');
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching product details: $error');
    }
  }

  Future<void> removeFromFav() async {
    try {
      var url = Uri.parse(
          'http://ec2-13-60-8-94.eu-north-1.compute.amazonaws.com:3000/product/removeFavourite');
      var request = http.Request('DELETE', url)
        ..headers.addAll({
          'Content-Type': 'application/json',
        })
        ..body = jsonEncode({
          "userId": "68fa72cbdc5f0a68",
          "productId": widget.productId
        });

      var response = await http.Client().send(request);

      if (response.statusCode == 200) {
        var responseBody = await response.stream.bytesToString();
        Map<String, dynamic> responseData = jsonDecode(responseBody);
        print("Response od removeFromFav is ${responseData}");
        if (responseData['message'] == 'Item removed from favourites successfully') {
          widget.onUpdate();
        }
      } else {
        throw Exception('Failed to remove fav');
      }
    } catch (error) {
      print('Error removing : $error');
    }
  }
  Future<void> addToCart() async {
    try {
      var url = Uri.parse(
          'http://ec2-13-60-8-94.eu-north-1.compute.amazonaws.com:3000/cart/addToCart');
      var request = http.Request('POST', url)
        ..headers.addAll({
          'Content-Type': 'application/json',
        })
        ..body = jsonEncode({
          "productId": widget.productId,
          "userId": "68fa72cbdc5f0a68",
          "quantity": 1
        });

      var response = await http.Client().send(request);

      if (response.statusCode == 200) {
        var responseBody = await response.stream.bytesToString();
        Map<String, dynamic> responseData = jsonDecode(responseBody);

        // If the response contains "Added To Cart", show success message
        if (responseData['message'] == 'Added To Cart') {
          Fluttertoast.showToast(msg: "Added");
        }
      } else {
        throw Exception('Failed to add to cart');
      }
    } catch (error) {
      print('Error adding to cart: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
  padding: const EdgeInsets.symmetric(vertical: 0.0),
  child: LayoutBuilder(
    builder: (context, constraints) {
      double imageSize = constraints.maxWidth * 0.18; // dynamic image size
      double iconSize = constraints.maxWidth * 0.05;  // dynamic icon size
      double deleteButtonSize = constraints.maxWidth * 0.08;  //Ddelete button

      return Column(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ItemDetailScreen(
                    productId: widget.productId,
                  ),
                ),
              );
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.02),
              decoration: BoxDecoration(
                color: ligtBlackColor,
                borderRadius: BorderRadius.circular(60),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(imageSize),
                        child: Container(
                          height: imageSize,
                          width: imageSize,
                          padding: EdgeInsets.all(8),
                          child: productImage != ''
                              ? Image.network(
                                  productImage,
                                  fit: BoxFit.contain,
                                  loadingBuilder: (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Center(
                                      child: CircularProgressIndicator(color:whiteColor),
                                    );
                                  },
                                  errorBuilder: (context, error, stackTrace) {
                                    return Center(
                                      child: Icon(Icons.error, color: whiteColor),
                                    );
                                  },
                                )
                              : Icon(Icons.image, size: iconSize,color: whiteColor,),
                        ),
                      ),
                      SizedBox(width: 8),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: constraints.maxWidth * 0.5,
                              child: Text(
                                productName.isNotEmpty ? productName : '...',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: constraints.maxWidth * 0.035,
                                  fontFamily: "JosefinSans",
                                  color: whiteColor,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: addToCart,
                              child: Text(
                                "ADD TO CART",
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: constraints.maxWidth * 0.03,
                                  fontFamily: "Urbanist",
                                  color: greenColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GestureDetector(
                      onTap: () {
                        print("Button Tapped of Delete");
                        removeFromFav();
                      },
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            height: deleteButtonSize,
                            width: deleteButtonSize,
                            decoration: BoxDecoration(
                              color: greenColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          Icon(
                            Icons.delete,
                            color: Colors.white,
                            size: iconSize,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 10,),
          Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: Image.asset(
              "lib/images/dotted_divider.png",
              width: constraints.maxWidth * 0.85,
            ),
          ),
        ],
      );
    },
  ),
);

  }
}
