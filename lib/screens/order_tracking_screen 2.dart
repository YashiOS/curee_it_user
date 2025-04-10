import 'package:cureeit_user_app/screens/base_screen.dart';
import 'package:flutter/material.dart';

class OrderTrackingScreen extends StatefulWidget {
   OrderTrackingScreen({super.key,required this.NavigatingFrom});
   final String NavigatingFrom;
  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  @override
 void initState(){
   super.initState();
  }

  Widget MedicineCard(
      {required String Imgurl,
      required String MedicineName,
      required int quantities,
      required double price}) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;
    return Container(
      margin: EdgeInsets.symmetric(vertical: height * 0.01),
      padding: EdgeInsets.all(width * 0.03),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(width * 0.04),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(width * 0.02),
            child: Image.asset(
              Imgurl, // Change path as needed
              width: width * 0.15,
              height: width * 0.15,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(width: width * 0.04),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  MedicineName,
                  style: TextStyle(
                    fontSize: width * 0.04,
                    fontWeight: FontWeight.w600,
                    fontFamily: "Urbanist",
                  ),
                ),
                SizedBox(height: height * 0.005),
                Text(
                  "$quantities x ₹$price",
                  style: TextStyle(
                    fontSize: width * 0.035,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Text(
            "₹${quantities * price}",
            style: TextStyle(
              fontSize: width * 0.04,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void showOrderSummaryBottomSheet() {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(width * 0.06)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: width * 0.04,
            right: width * 0.04,
            top: height * 0.015,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: width * 0.15,
                height: height * 0.006,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(width * 0.02),
                ),
              ),
              SizedBox(height: height * 0.015),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Order #3956",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: width * 0.045,
                      fontFamily: "Urbanist",
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, size: width * 0.06),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              SizedBox(height: height * 0.005),
              Row(
                children: [
                  Text(
                    "10/4",
                    style: TextStyle(fontSize: width * 0.035),
                  ),
                  Text(" • "),
                  Text(
                    "1:35 PM",
                    style: TextStyle(fontSize: width * 0.035),
                  ),
                  Text(" • "),
                  Text(
                    "1 item",
                    style: TextStyle(fontSize: width * 0.035),
                  ),
                  Text(" • "),
                  Text(
                    "₹28",
                    style: TextStyle(fontSize: width * 0.035),
                  ),
                ],
              ),
              Divider(
                color: Colors.grey.shade300,
                thickness: 1,
                height: height * 0.035,
              ),

              // Item Card
              MedicineCard(
                  Imgurl: "lib/images/capsule_image.png",
                  MedicineName: "Capule 450MG",
                  price: 30.5,
                  quantities: 2),

              SizedBox(height: height * 0.015),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Bill Details",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: width * 0.045,
                    fontFamily: "Urbanist",
                  ),
                ),
              ),
              Divider(
                color: Colors.grey.shade300,
                thickness: 1,
                height: height * 0.035,
              ),
              SizedBox(height: height * 0.01),
              
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Icon(Icons.currency_rupee),
                          Text(
                            " Item total",
                            style: TextStyle(
                              fontSize: width * 0.04,
                              fontWeight: FontWeight.normal,
                              fontFamily: "Urbanist",
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      "₹ 28",
                      style: TextStyle(
                        fontSize: width * 0.04,
                        fontWeight: FontWeight.bold,
                        fontFamily: "Urbanist",
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Icon(Icons.shopping_bag_outlined),
                          Text(
                            " Handling charges ",
                            style: TextStyle(
                              fontSize: width * 0.04,
                              fontWeight: FontWeight.normal,
                              fontFamily: "Urbanist",
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      "₹8",
                      style: TextStyle(
                        fontSize: width * 0.04,
                        fontFamily: "Urbanist",
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Icon(Icons.shopping_cart_outlined),
                          Text(
                            " Delivery charge (Inc taxes)",
                            style: TextStyle(
                              fontSize: width * 0.04,
                              fontWeight: FontWeight.normal,
                              fontFamily: "Urbanist",
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      "₹ 1",
                      style: TextStyle(
                        fontSize: width * 0.04,
                        fontFamily: "Urbanist",
                      ),
                    ),
                  ],
                ),
              ),
              Divider(
                color: Colors.grey.shade300,
                thickness: 1,
                height: height * 0.035,
              ),
              SizedBox(height: height * 0.01),
              Padding(
                padding: const EdgeInsets.fromLTRB(0,2,8,40),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                    "Grand total",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: width * 0.050,
                      fontFamily: "Urbanist",
                    ),
                  ),
                  Row(
                    children: [
                      Icon(Icons.currency_rupee),
                      Text(
                        "37.5",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: width * 0.050,
                          fontFamily: "Urbanist",
                        ),
                      ),
                    ],
                  ),
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Widget OrderDetail({
    required IconData icon,
    required String title,
    required String subtitle,
    required double width,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(width * 0.025),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: width * 0.06,
            color: Colors.grey.shade600,
          ),
        ),
        SizedBox(width: width * 0.04),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: width * 0.045,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  fontFamily: "Urbanist",
                ),
              ),
              Text(
                subtitle,
                maxLines: 1,
                style: TextStyle(
                  fontSize: width * 0.035,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                  fontFamily: "Urbanist",
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget DeliveryStatus({
    required IconData icon,
    required String label,
    required Color color,
    required double size,
    bool isInactive = false,
  }) {
    final iconColor = isInactive
        ? Colors.grey.shade500
        : (color is MaterialColor ? color.shade800 : color);
    final bgColor = isInactive
        ? Colors.grey.shade200
        : (color is MaterialColor ? color.shade100 : color.withOpacity(0.2));

    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(size * 0.03),
          decoration: BoxDecoration(
            color: bgColor,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: size * 0.07,
          ),
        ),
        SizedBox(height: size * 0.015),
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: iconColor,
            fontFamily: "Urbanist",
            fontSize: size * 0.03,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return Scaffold(
      body: Column(
        children: [
          SizedBox(height: height * 0.02),
          Container(
            margin: EdgeInsets.all(width * 0.04),
            padding: EdgeInsets.all(width * 0.03),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context)=>BaseScreen()));
                      print("Close tapped");
                    },
                    child: Icon(
                      Icons.close,
                      color: Colors.black,
                      size: width * 0.06,
                    ),
                  ),
                ),
                SizedBox(height: height * 0.01),
                ClipRRect(
                  child: Image.asset(
                    'lib/images/OrderTracking.png',
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: height * 0.35,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.all(width * 0.04),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(width * 0.06)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: width * 0.02,
                    offset: Offset(0, width * 0.01),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Order is being packed",
                    style: TextStyle(
                      fontSize: width * 0.045,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                      fontFamily: "Urbanist",
                    ),
                  ),
                  SizedBox(height: height * 0.02),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      DeliveryStatus(
                        icon: Icons.check_circle,
                        label: "Order placed",
                        color: Colors.green,
                        size: width,
                        isInactive: false,
                      ),
                      Expanded(
                        child: Divider(
                          thickness: 2,
                          color: Colors.grey.shade300,
                        ),
                      ),
                      DeliveryStatus(
                        icon: Icons.inventory_2,
                        label: "Packing",
                        color: Colors.orange,
                        size: width,
                        isInactive: true,
                      ),
                      Expanded(
                        child: Divider(
                          thickness: 2,
                          color: Colors.grey.shade300,
                        ),
                      ),
                      DeliveryStatus(
                        icon: Icons.local_shipping,
                        label: "On the Way",
                        color: Colors.blue,
                        size: width,
                        isInactive: true,
                      ),
                      Expanded(
                        child: Divider(
                          thickness: 2,
                          color: Colors.grey.shade300,
                        ),
                      ),
                      DeliveryStatus(
                        icon: Icons.check_circle,
                        label: "Delivered",
                        color: Colors.green,
                        size: width,
                        isInactive: true,
                      ),
                    ],
                  ),
                  SizedBox(height: height * 0.015),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(width * 0.04),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          OrderDetail(
                            icon: Icons.home_outlined,
                            title: "Delivery at Other",
                            subtitle:
                                "123 Main Street, Apt 4B New York, NY 10001",
                            width: width,
                          ),
                          OrderDetail(
                            icon: Icons.help_outline,
                            title: "Need help ?",
                            subtitle:
                                "Chat with us about any issue with your order",
                            width: width,
                          ),
                          GestureDetector(
                            onTap: () {
                              showOrderSummaryBottomSheet();
                            },
                            child: OrderDetail(
                              icon: Icons.receipt_outlined,
                              title: "Bill Details",
                              subtitle: "₹37.52",
                              width: width,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
