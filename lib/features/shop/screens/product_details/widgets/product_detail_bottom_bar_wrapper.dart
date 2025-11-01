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
  });

  final ProduitModel product;
  final bool dark;
  final bool isSmallScreen;

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
    }

    final quantity = controller.getProductQuantityInCart(product.id);
    if (quantity == 0) {
      // Add one item if none exists
      final cartItem = controller.productToCartItem(product, 1);
      controller.addOneToCart(cartItem);
    } else {
      // Navigate to cart screen
      Get.to(() => const CartScreen());
    }
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
    final controller = CartController.instance;

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
