import 'package:cureeit_user_app/cards/search_card.dart';
import 'package:cureeit_user_app/utils/theme.dart';
import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  final String searchText;
  const SearchScreen({super.key, required this.searchText});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late String searchText;

  @override
  void initState() {
    super.initState();
    searchText = widget.searchText;
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
            child: Padding(
              padding: const EdgeInsets.only(left: 4.0),
              child: Row(
                spacing: 4,
                children: [
                  Icon(Icons.arrow_back, color: primaryColor),
                  Text(
                    "Back",
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        fontFamily: "Urbanist",
                        color: primaryColor),
                  )
                ],
              ),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20.0, top: 16),
            child: Container(
              alignment: Alignment.topCenter,
              height: 26, // Increase height
              width: 26, // Increase width
              padding: const EdgeInsets.all(0.0),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              SearchScreen(searchText: "Neurobion")));
                },
                child: Transform.translate(
                  offset: Offset(0, -10), // x and y offset in pixels
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Image.asset(
                      'lib/images/search_button.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SizedBox(
        width: MediaQuery.of(context).size.width, // Set width to screen width
        height: MediaQuery.of(context).size.height,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 18),
          child: (ListView(
            children: [
              Text(
                widget.searchText,
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 24,
                    fontFamily: "JosefinSans",
                    color: primaryColor),
              ),
              SearchCard(productId: "NEULEA33"),
              SearchCard(productId: "NEULEA33"),
              SearchCard(productId: "NEULEA33"),
              SearchCard(productId: "NEULEA33"),
              SearchCard(productId: "NEULEA33"),
              SearchCard(productId: "NEULEA33"),
              SearchCard(productId: "NEULEA33"),
              SearchCard(productId: "NEULEA33"),
              SearchCard(productId: "NEULEA33"),
            ],
          )),
        ),
      ),
    );
  }
}
