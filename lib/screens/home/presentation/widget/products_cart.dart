import 'package:cureeit_user_app/screens/home/domain/entities/cartItemEntity.dart';
import 'package:cureeit_user_app/screens/home/presentation/providers/cart_provider.dart';
import 'package:cureeit_user_app/screens/otp/presentation/provider/otpProvider.dart';
import 'package:cureeit_user_app/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/entities/productEntities.dart';

class ProductCard extends ConsumerWidget {
  final ProductEntity product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartState = ref.watch(cartNotifierProvider);

    final cartNotifier = ref.read(cartNotifierProvider.notifier);
    final height = MediaQuery.of(context).size.height;
    final userId = ref.read(OtpNotifierProvider).user!.userId;
    final inCart =
        cartState.cartItems.any((item) => item.productId == product.productId);
    final quantity = cartState.cartItems
        .firstWhere(
          (item) => item.productId == product.productId,
          orElse: () => CartItemEntity(
            prescription: '',
            productId: product.productId,
            quantity: 0,
            name: "",
            imageUrls: [],
           productMarketer: "",
            productPrice: 0,
            sellingPrice: 0,
          ),
        )
        .quantity;

    final containerHeight = height * 0.45; 

    return Container(
      width: 147,
      height: 202,
      decoration: BoxDecoration(
        color: ligtBlackColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔵 Product Image (30%)
          SizedBox(
            width: double.infinity,
            height: 109,
            child: GestureDetector(
              onTap: () async {
                //await Navigator.push(
                //context,
                // MaterialPageRoute(
                // builder: (context) =>
                //   ItemDetailScreen(productId: product['productId']),
                // ),
                //);
                //await fetchCartDetails();
              },
              child: Container(
                width: double.infinity,
                height: 109,
                decoration: BoxDecoration(
                  color: whiteColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: product.imageMediaUrls[0] != null &&
                        product.imageMediaUrls[0].toString().isNotEmpty
                    ? Image.network(
                        product.imageMediaUrls[0],
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => Icon(
                          Icons.image_not_supported,
                          size: containerHeight * 0.1,
                          color: Colors.grey.shade400,
                        ),
                      )
                    : Icon(
                        Icons.image_not_supported,
                        size: containerHeight * 0.1,
                        color: Colors.grey.shade400,
                      ),
              ),
            ),
          ),

          // 🔵 Product Name (15%)
          Container(
            width: 147,
            height: 24,
            margin: EdgeInsets.only(top: 16, left: 10),
            child: Text(
              product.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.mulish(
                fontSize: containerHeight * 0.04,
                color: whiteColor,
              ),
            ),
          ),

          // 🔵 Price (7%)
          Container(
            margin: EdgeInsets.only(left: 10, right: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "₹${product.discountedPrice}",
                      style: GoogleFonts.mulish(
                        color: whiteColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      "₹${product.price}",
                      style: GoogleFonts.mulish(
                        color: greyColor,
                        fontSize: 12,
                        decoration: TextDecoration.lineThrough,
                        decorationColor: greyColor,
                      ),
                    ),
                  ],
                ),
                Container(
                  width: 50,
                  height: 29,
                  decoration: BoxDecoration(
                    color: ligtBlackColor,
                    border: Border.all(color: greenColor, width: 1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: inCart && quantity != 0
                      ? Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(7),
                            color: greenColor,
                          ),
                          child: FittedBox(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                IconButton(
                                  padding: EdgeInsets.zero,
                                  constraints: BoxConstraints(),
                                  icon: Icon(
                                    Icons.remove,
                                    size: containerHeight * 0.06,
                                    color: whiteColor,
                                  ),
                                  onPressed: () {
                                    final value=quantity-1;
                                    print(value);
                                    if(value==0){
                                      cartNotifier.removeFromCart(userId, product.productId);
                                      return;
                                    }
                                    cartNotifier.updateCartQuantity(userId,product.productId, value);
                                  },
                                ),
                                Text(
                                  '$quantity',
                                  style: GoogleFonts.mulish(
                                    color: whiteColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: containerHeight * 0.05,
                                  ),
                                ),
                                IconButton(
                                  padding: EdgeInsets.zero,
                                  constraints: BoxConstraints(),
                                  icon: Icon(
                                    Icons.add,
                                    size: containerHeight * 0.06,
                                    color: whiteColor,
                                  ),
                                  onPressed: () {
                                    final value=quantity+1;
                                    cartNotifier.updateCartQuantity(userId,product.productId, value);
                                  },
                                ),
                              ],
                            ),
                          ),
                        )
                      : TextButton(
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                          ),
                          onPressed: () {
                            cartNotifier.addToCart(
                                userId, product.productId, 1);
                          },
                          child: Center(
                            child: Text(
                              "Add",
                              style: GoogleFonts.mulish(
                                fontSize: containerHeight * 0.03,
                                fontWeight: FontWeight.w600,
                                color: greenColor,
                              ),
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ), // 🔵 Add to Cart or Quantity Buttons (30%)
        ],
      ),
    );
  }
}
