import 'package:caferesto/common/widgets/texts/product_price_text.dart';
import 'package:caferesto/common/widgets/texts/section_heading.dart';
import 'package:caferesto/utils/constants/colors.dart';
import 'package:caferesto/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../common/widgets/products/product_cards/widgets/rounded_container.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../controllers/product/panier_controller.dart';
import '../../../controllers/product/variation_controller.dart';
import '../../../models/produit_model.dart';

class TProductAttributes extends StatelessWidget {
  final ProduitModel product;
  final String? tag;

  const TProductAttributes({super.key, required this.product, this.tag});

  @override
  Widget build(BuildContext context) {
    // Use Get.find safely - VariationController should be registered
    final variationController = tag != null
        ? Get.find<VariationController>(tag: tag)
        : Get.find<VariationController>();
    final cartController = Get.find<CartController>();
    final dark = THelperFunctions.isDarkMode(context);

    return Obx(() {
      final selectedSize = variationController.selectedSize.value;
      
      // Cache variations in cart for this product to avoid repeated lookups
      final variationsInCartSet = cartController.getVariationsInCartSet(product.id);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const TSectionHeading(
              title: 'Tailles disponibles', showActionButton: false),
          const SizedBox(height: AppSizes.spaceBtwItems),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: product.sizesPrices.map((sp) {
              final bool isSelected = selectedSize == sp.size;
              final bool isInCart = variationsInCartSet.contains(sp.size);
              
              return ChoiceChip(
                label: Text(
                  '${sp.size} (${sp.price.toStringAsFixed(2)} DT)${isInCart ? ' ✓' : ''}',
                  style: TextStyle(
                    color: isInCart && !isSelected
                        ? Colors.grey.shade500
                        : (isSelected
                            ? Colors.white
                            : (dark ? Colors.white70 : Colors.black87)),
                  ),
                ),
                selected: isSelected,
                selectedColor: AppColors.primary,
                backgroundColor: isInCart && !isSelected
                    ? (dark ? Colors.grey.shade800.withOpacity(0.5) : Colors.grey.shade300)
                    : (dark ? AppColors.darkerGrey : AppColors.lightGrey),
                disabledColor: dark ? Colors.grey.shade800.withOpacity(0.5) : Colors.grey.shade300,
                labelStyle: TextStyle(
                  decoration: isInCart && !isSelected ? TextDecoration.lineThrough : null,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                avatar: isInCart && !isSelected
                    ? Icon(Icons.check_circle, size: 16, color: Colors.grey.shade500)
                    : null,
                onSelected: isInCart && !isSelected
                    ? null
                    : (bool selected) {
                        if (selected) {
                          variationController.selectVariation(sp.size, sp.price);
                          cartController.updateVariation(
                            product.id,
                            variationController.selectedSize.value,
                            variationController.selectedPrice.value,
                          );
                        } else {
                          variationController.clearVariation();
                        }
                      },
              );
            }).toList(),
          ),
          const SizedBox(height: AppSizes.spaceBtwItems * 1.5),
          if (selectedSize.isNotEmpty)
            TRoundedContainer(
              padding: const EdgeInsets.all(AppSizes.md),
              backgroundColor: dark ? AppColors.darkerGrey : AppColors.grey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Taille sélectionnée : $selectedSize',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: AppSizes.sm),
                  Row(
                    children: [
                      const Text('Prix : ',
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 15)),
                      ProductPriceText(
                        price: variationController.selectedPrice.value
                            .toStringAsFixed(2),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      );
    });
  }
}
