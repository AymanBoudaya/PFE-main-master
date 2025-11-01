import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../common/widgets/texts/brand_title_text_with_verified_icon.dart';
import '../../../../../common/widgets/texts/product_title_text.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../../../utils/helpers/helper_functions.dart';
import '../../../controllers/product/panier_controller.dart';
import '../../../controllers/product/variation_controller.dart';
import '../../../models/cart_item_model.dart';
import '../../product_details/product_detail.dart';
import 'cart_item_image.dart';
import 'cart_item_quantity_controls.dart';

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
    // Get controller once outside Obx to avoid repeated lookups
    final controller = Get.find<CartController>();
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
          if (index >= items.length) return const SizedBox.shrink();
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

                          /// Edit and Add Buttons (only for variable products)
                          if (cartItem.product?.productType == 'variable') ...[
                            const SizedBox(height: 8),
                            _CartItemVariantButtons(
                              cartItem: cartItem,
                              controller: controller,
                              onEdit: () => _navigateToEditVariation(context, cartItem),
                              onAdd: () => _navigateToAddVariation(context, cartItem),
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

  /// Navigate to product detail for editing the current variation
  void _navigateToEditVariation(BuildContext context, CartItemModel cartItem) {
    final product = cartItem.product;
    if (product == null) {
      Get.snackbar(
        'Erreur',
        'Produit introuvable',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // Pre-select the current variation before navigating
    final variationController = Get.find<VariationController>();
    if (cartItem.variationId.isNotEmpty) {
      // Find the size and price for this variation
      final sizePrice = product.sizesPrices.firstWhereOrNull(
        (sp) => sp.size == cartItem.variationId,
      );
      
      if (sizePrice != null) {
        variationController.selectVariation(sizePrice.size, sizePrice.price);
      }
    }

    // Navigate to product detail with skipVariationReset=true to preserve selection
    Get.to(() => ProductDetailScreen(
      product: product,
      skipVariationReset: true,
    ));
  }

  /// Navigate to product detail for adding a new variation
  void _navigateToAddVariation(BuildContext context, CartItemModel cartItem) {
    final product = cartItem.product;
    if (product == null) {
      Get.snackbar(
        'Erreur',
        'Produit introuvable',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // Reset variation selection for a fresh start
    final variationController = Get.find<VariationController>();
    variationController.resetSelectedAttributes();

    // Navigate to product detail
    Get.to(() => ProductDetailScreen(product: product));
  }
}

/// Separate widget for variant buttons to optimize Obx usage
class _CartItemVariantButtons extends StatelessWidget {
  const _CartItemVariantButtons({
    required this.cartItem,
    required this.controller,
    required this.onEdit,
    required this.onAdd,
  });

  final CartItemModel cartItem;
  final CartController controller;
  final VoidCallback onEdit;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final product = cartItem.product;
    if (product == null) return const SizedBox.shrink();
    
    // Single Obx to check if all variations are in cart
    return Obx(() {
      // Only access cartItems once to trigger reactivity
      final _ = controller.cartItems.length;
      final allVariationsInCart = controller.areAllVariationsInCart(product);
      
      return Row(
        children: [
          // Edit button - edit current variation
          Expanded(
            child: OutlinedButton.icon(
              onPressed: allVariationsInCart ? null : onEdit,
              icon: Icon(
                Icons.edit_outlined,
                size: 16,
                color: allVariationsInCart
                    ? Colors.grey
                    : Colors.blue.shade400,
              ),
              label: Text(
                'Modifier',
                style: TextStyle(
                  fontSize: 12,
                  color: allVariationsInCart
                      ? Colors.grey
                      : Colors.blue.shade400,
                ),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                side: BorderSide(
                  color: allVariationsInCart
                      ? Colors.grey.shade300
                      : Colors.blue.shade400,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Add button - add new variation
          Expanded(
            child: OutlinedButton.icon(
              onPressed: allVariationsInCart ? null : onAdd,
              icon: Icon(
                Icons.add_circle_outline,
                size: 16,
                color: allVariationsInCart
                    ? Colors.grey
                    : Colors.green.shade400,
              ),
              label: Text(
                'Ajouter',
                style: TextStyle(
                  fontSize: 12,
                  color: allVariationsInCart
                      ? Colors.grey
                      : Colors.green.shade400,
                ),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                side: BorderSide(
                  color: allVariationsInCart
                      ? Colors.grey.shade300
                      : Colors.green.shade400,
                ),
              ),
            ),
          ),
        ],
      );
    });
  }
}
