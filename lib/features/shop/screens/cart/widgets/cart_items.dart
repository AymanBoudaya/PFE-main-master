import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../utils/constants/sizes.dart';
import '../../../controllers/product/panier_controller.dart';
import '../../../models/cart_item_model.dart';
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

    return Obx(() {
      final items = controller.cartItems;
      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        separatorBuilder: (_, __) =>
            const SizedBox(height: AppSizes.spaceBtwItems),
        itemBuilder: (_, index) {
          final CartItemModel item = items[index];

          return Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
              border: Border.all(color: Colors.grey.shade100),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.defaultSpace),
              child: CartItemTile(
                item: item,
                index: index,
                showDelete: showDeleteButton,
                showModify: showModifyButton,
              ),
            ),
          );
        },
      );
    });
  }
}
