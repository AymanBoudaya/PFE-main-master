import 'package:caferesto/features/shop/controllers/product/panier_controller.dart';
import 'package:caferesto/features/shop/controllers/product/variation_controller.dart';
import 'package:caferesto/features/shop/models/produit_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProductPriceDisplay extends StatelessWidget {
  const ProductPriceDisplay({
    super.key,
    required this.product,
    required this.dark,
  });

  final ProduitModel product;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final controller = CartController.instance;
    final variationController = VariationController.instance;

    return Obx(() {
      double unitPrice;

      // For variable products, use selected variation price if available
      if (product.productType == 'variable' &&
          variationController.selectedPrice.value > 0) {
        unitPrice = variationController.selectedPrice.value;
      } else {
        // Get sale price or regular price
        unitPrice = product.salePrice > 0 ? product.salePrice : product.price;
      }

      // Get quantity for the current selection (variation or product)
      int quantity;
      if (product.productType == 'variable' &&
          variationController.selectedSize.value.isNotEmpty) {
        quantity = controller.getVariationQuantityInCart(
          product.id,
          variationController.selectedSize.value,
        );
      } else {
        quantity = controller.getProductQuantityInCart(product.id);
      }

      final totalPrice = unitPrice * quantity;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            quantity > 0 ? 'Total' : 'Prix',
            style: TextStyle(
              color: dark ? Colors.grey.shade400 : Colors.grey.shade600,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 2),
          // Show total price when items in cart, unit price when empty
          Text(
            quantity > 0
                ? '${totalPrice.toStringAsFixed(2)} DT'
                : '${unitPrice.toStringAsFixed(2)} DT',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.green.shade600,
            ),
          ),
        ],
      );
    });
  }
}
