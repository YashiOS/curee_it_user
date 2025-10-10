import 'package:cureeit_user_app/screens/home/domain/entities/addressEntity.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AddressSelectorBottomSheet {
  static void show(
    BuildContext context,
    List<AddressEntity> addresses, {
    required Function(int index, AddressEntity address) onAddressSelected,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.black,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return AddressSelectorContent(
          addresses: addresses,
          onAddressSelected: onAddressSelected,
        );
      },
    );
  }
}

class AddressSelectorContent extends StatefulWidget {
  final List<AddressEntity> addresses;
  final Function(int, AddressEntity) onAddressSelected;

  const AddressSelectorContent({
    super.key,
    required this.addresses,
    required this.onAddressSelected,
  });

  @override
  State<AddressSelectorContent> createState() => _AddressSelectorContentState();
}

class _AddressSelectorContentState extends State<AddressSelectorContent> {
  int? selectedIndex;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: 24,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 10),
          Text(
            "Select Delivery Location",
            style: GoogleFonts.mulish(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 300,
            child: ListView.builder(
              itemCount: widget.addresses.length,
              itemBuilder: (context, index) {
                final address = widget.addresses[index];
                final isSelected = selectedIndex == index;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedIndex = index;
                    });

                    widget.onAddressSelected(index, address);
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.only(left: 25, right: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey[900],
                    ),
                    margin: const EdgeInsets.only(bottom: 16),
                    height: 75,
                    child: Row(
                      children: [
                        const Icon(Icons.location_on, color: Colors.greenAccent),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                address.address ?? '',
                                style: GoogleFonts.mulish(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                address.type ?? '',
                                style: GoogleFonts.mulish(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w300,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 16,
                          height: 16,
                          margin: const EdgeInsets.only(left: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.green : Colors.black,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
