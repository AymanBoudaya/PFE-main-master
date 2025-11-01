import 'package:caferesto/features/shop/controllers/product/panier_controller.dart';
import 'package:caferesto/features/shop/models/produit_model.dart';
import 'package:caferesto/features/shop/screens/cart/cart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'product_bottom_bar.dart';

class ProductDetailBottomBarWrapper extends StatelessWidget {
  const ProductDetailBottomBarWrapper({
    super.key,
    required this.product,
    required this.dark,
    required this.isSmallScreen,
    this.onVariationSelected,
  });

  final ProduitModel product;
  final bool dark;
  final bool isSmallScreen;
  final VoidCallback? onVariationSelected;

  void _handleMainAction(CartController controller) {
    if (!controller.canAddProduct(product)) return;

    if (product.productType == 'variable') {
      final hasSelectedVariant = controller.hasSelectedVariant();
      if (!hasSelectedVariant) {
        Get.snackbar(
          'Sélection requise',
          'Veuillez choisir une variante avant de continuer',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      // If this is a modification (edit mode), call the callback
      if (onVariationSelected != null) {
        onVariationSelected!();
        return;
      }

      // Check if the SPECIFIC variation is in cart (for add mode)
      final selectedSize = controller.variationController.selectedSize.value;
      if (selectedSize.isNotEmpty) {
        final variationQuantity =
            controller.getVariationQuantityInCart(product.id, selectedSize);
        if (variationQuantity > 0) {
          // This specific variation is already in cart, navigate to cart
          Get.to(() => const CartScreen());
          return;
        }
      }
    } else {
      // For single products, check if product is in cart
      final quantity = controller.getProductQuantityInCart(product.id);
      if (quantity > 0) {
        Get.to(() => const CartScreen());
        return;
      }
    }

    // Add new item (either new variation or new product)
    final cartItem = controller.productToCartItem(product, 1);
    controller.addOneToCart(cartItem);
  }

  void _handleIncrement(CartController controller) {
    if (!controller.canAddProduct(product)) return;
    if (product.productType == 'single' || controller.hasSelectedVariant()) {
      final cartItem = controller.productToCartItem(product, 1);
      controller.addOneToCart(cartItem);
    }
  }

  void _handleDecrement(CartController controller) {
    if (product.productType == 'single' || controller.hasSelectedVariant()) {
      final cartItem = controller.productToCartItem(product, 1);
      controller.removeOneFromCart(cartItem);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use Get.find instead of instance getter to avoid issues
    final controller = Get.find<CartController>();

    return ProductBottomBar(
      product: product,
      dark: dark,
      isSmallScreen: isSmallScreen,
      onIncrement: () => _handleIncrement(controller),
      onDecrement: () => _handleDecrement(controller),
      onMainAction: () => _handleMainAction(controller),
    );
  }
}
