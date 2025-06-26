import 'package:cureeit_user_app/BaseUrl.dart';
import 'package:cureeit_user_app/screens/item_detail_screen.dart';
import 'package:cureeit_user_app/user/user.dart';
import 'package:cureeit_user_app/utils/theme.dart';
import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';



class FavoritesCard extends StatefulWidget {
  final String productId;
  final Function onUpdate;
  const FavoritesCard(
      {super.key, required this.productId, required this.onUpdate});

  @override
  State<FavoritesCard> createState() => _FavoritesCardState();
}

class _FavoritesCardState extends State<FavoritesCard> {
  bool isAddingToCart = false;
  bool isDeleting = false;
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
          '$baseUrl/product/productDetail');
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
    setState(() {
      isDeleting = true;
    });

    try {
      var url = Uri.parse(
          '$baseUrl/product/removeFavourite');
      var request = http.Request('DELETE', url)
        ..headers.addAll({
          'Content-Type': 'application/json',
        })
        ..body = jsonEncode(
            {"userId": User.userId, "productId": widget.productId});

      var response = await http.Client().send(request);

      if (response.statusCode == 200) {
        setState(() {
          isDeleting = false;
        });
        var responseBody = await response.stream.bytesToString();
        Map<String, dynamic> responseData = jsonDecode(responseBody);
       
        if (responseData['message'] ==
            'Item removed from favourites successfully') {
          widget.onUpdate();
        }
      } else {
        setState(() {
          isDeleting = false;
        });
        throw Exception('Failed to remove fav');
      }
    } catch (error) {
      setState(() {
        isDeleting = false;
      });
      setState(() {
        isDeleting = false;
      });
      print('Error removing : $error');
    }
  }

  Future<void> addToCart() async {
    setState(() {
      isAddingToCart = true;
    });

    try {
      var url = Uri.parse(
          '$baseUrl/cart/addToCart');
      var request = http.Request('POST', url)
        ..headers.addAll({
          'Content-Type': 'application/json',
        })
        ..body = jsonEncode({
          "productId": widget.productId,
          "userId": User.userId,
          "quantity": 1
        });

      var response = await http.Client().send(request);

      if (response.statusCode == 200) {
        var responseBody = await response.stream.bytesToString();
        Map<String, dynamic> responseData = jsonDecode(responseBody);
        setState(() {
          isAddingToCart = false;
        });

        // If the response contains "Added To Cart", show success message
        if (responseData['message'] == 'Added To Cart') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Added to cart',
                style: TextStyle(
                  color: Colors.white, // white text
                  fontWeight: FontWeight.bold,
                ),
              ),
              backgroundColor: Color(0xFF2C2C2C), // light black / dark grey
              behavior: SnackBarBehavior.floating,
              margin: EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        setState(() {
          isAddingToCart = false;
        });
        throw Exception('Failed to add to cart');
      }
    } catch (error) {
      setState(() {
        isAddingToCart = false;
      });
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
          double iconSize = constraints.maxWidth * 0.05; // dynamic icon size
          double deleteButtonSize =
              constraints.maxWidth * 0.08; //Ddelete button

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
                  padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width * 0.04,
                      vertical: 10),
                  decoration: BoxDecoration(
                    color: ligtBlackColor,
                    borderRadius: BorderRadius.circular(8),
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
                                      loadingBuilder:
                                          (context, child, loadingProgress) {
                                        if (loadingProgress == null)
                                          return child;
                                        return Center(
                                          child: CircularProgressIndicator(
                                              color: whiteColor),
                                        );
                                      },
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Center(
                                          child: Icon(Icons.error,
                                              color: whiteColor),
                                        );
                                      },
                                    )
                                  : Icon(
                                      Icons.image,
                                      size: iconSize,
                                      color: whiteColor,
                                    ),
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
                                    productName.isNotEmpty
                                        ? productName
                                        : '...',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.mulish(
                                      fontWeight: FontWeight.w600,
                                      fontSize: constraints.maxWidth * 0.045,
                                      color: whiteColor,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                GestureDetector(
                                  onTap: addToCart,
                                  child: Container(
                                    
                                    width: 80,
                                    decoration: BoxDecoration(
                                        color: greenColor,
                                        borderRadius: BorderRadius.circular(8)),
                                    padding: EdgeInsets.all(10),
                                    child: isAddingToCart
                                        ? Container(
                                            width: 15,
                                            height: 15,
                                            child: CircularProgressIndicator(color: whiteColor,strokeWidth: 2,)
                                          )
                                        : Text(
                                            "Add to cart",
                                            style: TextStyle(
                                              fontWeight: FontWeight.w900,
                                              fontSize:
                                                  constraints.maxWidth * 0.03,
                                              color: whiteColor,
                                            ),
                                          ),
                                  ),
                                ),
                                SizedBox(height: 10,),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: GestureDetector(
                          onTap: () {
                           
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
                                  borderRadius: BorderRadius.circular(8),
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
              SizedBox(
                height: 20,
              ),
            ],
          );
        },
      ),
    );
  }
}
