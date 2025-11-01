import 'package:caferesto/features/shop/screens/product_details/widgets/product_quantity_controls.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../common/widgets/texts/brand_title_text_with_verified_icon.dart';
import '../../../../../common/widgets/texts/product_title_text.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../../../utils/helpers/helper_functions.dart';
import '../../../controllers/product/panier_controller.dart';
import '../../../models/cart_item_model.dart';
import 'cart_item_image.dart';
import 'cart_item_quantity_controls.dart';
import 'cart_item_tile.dart';

class TCartItems extends StatelessWidget {
  const TCartItems({
    super.key,
    this.showDeleteButton = true,
    this.showModifyButton = true,
    this.compactQuantity = false,
  });

  final bool showDeleteButton;
  final bool showModifyButton;
  final bool compactQuantity;

  @override
  Widget build(BuildContext context) {
    final controller = CartController.instance;
    final dark = THelperFunctions.isDarkMode(context);

    return Obx(() {
      final items = controller.cartItems;
      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        separatorBuilder: (_, __) =>
            const SizedBox(height: AppSizes.spaceBtwItems),
        itemBuilder: (_, index) {
          final CartItemModel cartItem = items[index];

          return Container(
            padding: const EdgeInsets.all(AppSizes.md),
            margin: const EdgeInsets.only(bottom: AppSizes.spaceBtwItems),
            decoration: BoxDecoration(
              color: dark ? Colors.grey.shade900 : Colors.white,
              borderRadius: BorderRadius.circular(AppSizes.cardRadiusMd),
              border: Border.all(
                color: dark ? Colors.grey.shade800 : Colors.grey.shade200,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Image
                    CartItemImage(imageUrl: cartItem.image),
                    const SizedBox(width: AppSizes.spaceBtwItems),

                    /// Title & Brand
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          BrandTitleWithVerifiedIcon(
                              title: cartItem.brandName ?? ''),

                          const SizedBox(height: 4),
                          TProductTitleText(
                            title: cartItem.title,
                            maxLines: 2,
                          ),

                          /// Current Variation Display
                          if (cartItem.selectedVariation != null &&
                              cartItem.selectedVariation!.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              cartItem.selectedVariation!.entries
                                  .map((e) => '${e.key}: ${e.value}')
                                  .join(', '),
                              style: TextStyle(
                                fontSize: 12,
                                color: dark
                                    ? Colors.grey.shade400
                                    : Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    /// Delete Button
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () => controller.removeFromCartDialog(index),
                      icon: Icon(
                        Icons.delete_outline,
                        size: 20,
                        color: Colors.red.shade400,
                      ),
                    ),
                  ],
                ),

                /// Quantity Controls & Total Price
                const SizedBox(height: AppSizes.sm),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    /// Quantity Controls
                    CartItemQuantityControls(
                      cartItem: cartItem,
                      dark: dark,
                    ),

                    /// Total Price
                    Obx(() {
                      // Get updated cart item from controller
                      final currentItem = controller.cartItems.firstWhereOrNull(
                        (item) =>
                            item.productId == cartItem.productId &&
                            item.variationId == cartItem.variationId,
                      );
                      final item = currentItem ?? cartItem;
                      return Text(
                        '${(item.price * item.quantity).toStringAsFixed(2)} DT',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade600,
                        ),
                      );
                    }),
                  ],
                ),
              ],
            ),
          );
        },
      );
    });
  }
}
