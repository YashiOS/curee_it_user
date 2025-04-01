import 'dart:async';
import 'package:cureeit_user_app/screens/item_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:cureeit_user_app/utils/theme.dart';
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
      final response = await http.get(Uri.parse("http://ec2-13-60-8-94.eu-north-1.compute.amazonaws.com:3000/search/searchProducts?keyword=$query"));

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
    print("Query  sent is ${query}");
    if (query.isNotEmpty) {
      _fetchSearchResults(query);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey.shade100.withOpacity(0.5),
        leadingWidth: 100,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12.0),
          child: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Row(
              children: [
                Icon(Icons.arrow_back, color: primaryColor),
                SizedBox(width: 4),
                Text(
                  "Back",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    fontFamily: "Urbanist",
                    color: primaryColor,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Search",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 24,
                fontFamily: "JosefinSans",
                color: primaryColor,
              ),
            ),
            SizedBox(height: 8),
            Container(
              height: 58,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(width: 1, color: Color.fromARGB(255, 202, 188, 188)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: TextField(
                        style: TextStyle(fontFamily: "Urbanist"),
                        controller: _controller,
                        decoration: InputDecoration(
                          hintText: "Search",
                          hintStyle: TextStyle(fontFamily: "Urbanist"),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: GestureDetector(
                      onTap: () {
                        String searchQuery = _controller.text;
                        _fetchSearchResults(searchQuery);
                      },
                      child: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: secondaryColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(Icons.search, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12),
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : _searchResults.isEmpty
                      ? Center(child: Text("No results found", style: TextStyle(color: Colors.grey)))
                      : ListView.builder(
                          itemCount: _searchResults.length,
                          itemBuilder: (context, index) {
                            var item = _searchResults[index];
                            return Card(
                              margin: EdgeInsets.symmetric(vertical: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 2,
                              child: ListTile(
                                leading: SizedBox(
                                              width: 50,
                                              height: 50,
                                              child: (item["imageUrls"] != null && item["imageUrls"].isNotEmpty)
                                      ? Image.network(
                                              item["imageUrls"][0], 
                                              fit: BoxFit.cover,
                                            )
                                      : Image.asset(
                                              "lib/images/capsule_image.png", 
                                              fit: BoxFit.cover,
                                            ),
                                            
                              ),
                                title: Text(
                                  item['name'],
                                  style: TextStyle(fontFamily: "Urbanist", fontWeight: FontWeight.bold),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("₹ ${item['price']}", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                                    Text(item['primaryUse'], style: TextStyle(color: Colors.grey)),
                                  ],
                                ),
                                trailing: item['prescriptionRequired']
                                    ? Icon(Icons.medical_services, color: Colors.red)
                                    : Icon(Icons.check_circle, color: Colors.green),
                                onTap: () {
                                  Navigator.push(
                                 context,
                                  MaterialPageRoute(
                                  builder: (context) => ItemDetailScreen(productId: item["productId"]),
                                ),
                              );
                                },
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
