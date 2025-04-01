import 'package:cureeit_user_app/screens/item_detail_screen.dart';
import 'package:cureeit_user_app/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FavoritesCard extends StatefulWidget {
  final String productId;
  const FavoritesCard({super.key, required this.productId});

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

  // Add product to the cart
// Add product to the cart
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
          "userId": "68fa72cbdc5f0a68", // Replace with actual userId if needed
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
      child: Column(
        spacing: 10,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ItemDetailScreen(
                            productId: widget.productId,
                          )));
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(60)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 12,
                    children: [
                      ClipRRect(
                          borderRadius: BorderRadius.circular(72),
                          child: SizedBox(
                            height: 68,
                            width: 68,
                            child: Container(
                                padding: EdgeInsets.all(8),
                                child: productImage != ''
                                    ? Image.network(
                                        productImage,
                                        fit: BoxFit.contain,
                                        loadingBuilder:
                                            (context, child, loadingProgress) {
                                          if (loadingProgress == null) {
                                            return child;
                                          }
                                          return const Center(
                                              child: CircularProgressIndicator(
                                            color: secondaryColor,
                                          ));
                                        },
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return const Center(
                                              child: Icon(
                                            Icons.error,
                                            color: Color.fromRGBO(7, 9, 84, 1),
                                          ));
                                        },
                                      )
                                    : Icon(Icons.image)),
                          )),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0, left: 8),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 8,
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width / 2,
                              child: Text(
                                productName.isNotEmpty ? productName : '...',
                                maxLines: 1,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  fontFamily: "JosefinSans",
                                  color: Color(0xFF1F1970),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: addToCart,
                              child: Text(
                                "ADD TO CART",
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 12,
                                  fontFamily: "Urbanist",
                                  color: secondaryColor,
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
                    child: Stack(alignment: Alignment.center, children: [
                      Container(
                        height: 28,
                        width: 28,
                        decoration: BoxDecoration(
                            color: secondaryColor,
                            borderRadius: BorderRadius.circular(20)),
                      ),
                      Icon(
                        Icons.delete,
                        color: Colors.white,
                        size: 22,
                      ),
                    ]),
                  )
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: Image.asset(
              "lib/images/dotted_divider.png",
              width: MediaQuery.of(context).size.width / 1.3,
            ),
          ),
        ],
      ),
    );
  }
}
