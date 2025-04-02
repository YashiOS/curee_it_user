import 'package:flutter/material.dart';

class AddressCard extends StatelessWidget {
  final bool isSelected;
  final Map<String, dynamic> address;
  final VoidCallback onTap;
  const AddressCard(
      {super.key,
      required this.isSelected,
      required this.address,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 18, horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: isSelected
                ? Border.all(
                    color: Colors.blue, width: 2) // Highlight selection
                : Border.all(color: Colors.transparent),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Image.asset(
                    isSelected
                        ? "lib/images/selected_button.png"
                        : "lib/images/nonselected_button.png",
                    height: 24,
                    width: 24,
                    fit: BoxFit.contain,
                  ),
                  SizedBox(width: 12), // Spacing between image and text
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        address['type'],
                        style: TextStyle(
                          color: Color(0xFF1F1970),
                          fontSize: 20,
                          fontFamily: "JosefinSans",
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.7,
                        child: Text(
                          address['address'],
                          style: TextStyle(
                            color: Color(0xFF689AC0),
                            fontSize: 14,
                            fontFamily: "Urbanist",
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
