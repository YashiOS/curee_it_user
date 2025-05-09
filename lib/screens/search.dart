import 'dart:async';
import 'package:cureeit_user_app/screens/item_detail_screen.dart';
import 'package:cureeit_user_app/user/user.dart';
import 'package:flutter/material.dart';
import 'package:cureeit_user_app/utils/theme.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  final TextEditingController _controller = TextEditingController();
  Timer? _debounce;
  List<dynamic> _searchResults = [];
  bool _isLoading = false;

  // Function to call search API
  Future<void> _fetchSearchResults(String query) async {
    if (query.length < 3) {
      setState(() {
        _searchResults.clear();
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse(
          "http://ec2-13-60-8-94.eu-north-1.compute.amazonaws.com:3000/search/searchProducts?keyword=$query"));

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse["success"] == true) {
          setState(() {
            _searchResults = jsonResponse["data"];
          });
        } else {
          setState(() {
            _searchResults.clear();
          });
        }
      } else {
        setState(() {
          _searchResults.clear();
        });
      }
    } catch (e) {
      setState(() {
        _searchResults.clear();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Debounce search input
  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      final query = _controller.text.trim();

      print("Query  sent is $query");
      if (query.isEmpty) {
        // Clear results immediately
        setState(() {
          _searchResults.clear();
        });
        return;
      }
      if (query.isNotEmpty) {
        _fetchSearchResults(query);
        print("done sent");
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      _onSearchChanged();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Future<void> didAddToCart({
    required String userId,
    required String productId,
    int quantity = 1,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(
            'http://ec2-13-60-8-94.eu-north-1.compute.amazonaws.com:3000/cart/addToCart'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'userId': userId,
          'productId': productId,
          'quantity': quantity,
        }),
      );

      if (response.statusCode == 200) {
        Fluttertoast.showToast(msg: "Added To Cart");
      } else {
        print('❌ Failed to add item to cart. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Network error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldBlackColor,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Search",
          style: GoogleFonts.mulish(color: whiteColor),
        ),
        backgroundColor: ligtBlackColor,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12.0),
          child: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Icon(Icons.arrow_back, color: whiteColor),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 8),
            Container(
              height: 48,
              decoration: BoxDecoration(
                color: ligtBlackColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: TextField(
                        cursorColor: whiteColor,
                        style: GoogleFonts.mulish(color: whiteColor),
                        controller: _controller,
                        decoration: InputDecoration(
                          hintText: "Search",
                          hintStyle: GoogleFonts.mulish(color: whiteColor),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12),
            Expanded(
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                      color: whiteColor,
                    ))
                  : _searchResults.isEmpty
                      ? Center(
                          child: Text("No results found",
                              style: GoogleFonts.mulish(color: greyColor)))
                      : ListView.builder(
                          itemCount: _searchResults.length,
                          itemBuilder: (context, index) {
                            var item = _searchResults[index];
                            return GestureDetector(
                              onTap: () {
                                  print("clicked");
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ItemDetailScreen(
                                        productId: item["productId"],
                                      ),
                                    ),
                                  );
                                },
                              child: Card(
                                color: ligtBlackColor,
                                margin: EdgeInsets.symmetric(vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Container(
                                  height: 144,
                                  width: 311,
                                  padding: EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              item['name'],
                                              style: GoogleFonts.mulish(
                                                fontSize: 17.02,
                                                fontWeight: FontWeight.w400,
                                                color: whiteColor,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            "₹${item['price']}",
                                            style: GoogleFonts.mulish(
                                              fontSize: 17,
                                              fontWeight: FontWeight.w500,
                                              color: whiteColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        maxLines: 1,
                                        item['primaryUse'] ??
                                            'Medicine information',
                                        style: GoogleFonts.mulish(
                                          color: greyColor,
                                          fontSize: 14,
                                        ),
                                      ),
                                      Spacer(),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          ElevatedButton(
                                            onPressed: () {
                                              didAddToCart(
                                                userId: User.userId!,
                                                productId: item["productId"],
                                              );
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: greenColor,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 16, vertical: 8),
                                            ),
                                            child: Text(
                                              'Add to cart',
                                              style: GoogleFonts.mulish(
                                                color: whiteColor,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
