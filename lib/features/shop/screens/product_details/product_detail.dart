import 'package:flutter/material.dart';

import '../../../../utils/constants/colors.dart';
import '../../../../utils/device/device_utility.dart';
import '../../../../utils/helpers/helper_functions.dart';
import '../../controllers/product/variation_controller.dart';
import '../../models/produit_model.dart';
import 'widgets/product_detail_bottom_bar_wrapper.dart';
import 'widgets/product_detail_desktop_layout.dart';
import 'widgets/product_detail_mobile_layout.dart';

class ProductDetailScreen extends StatelessWidget {
  ProductDetailScreen({super.key, required this.product}) {
    // Reset variations when screen is opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      VariationController.instance.resetSelectedAttributes();
    });
  }

  final ProduitModel product;

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    final isDesktop = TDeviceUtils.isDesktop(context);
    final isSmallScreen = MediaQuery.of(context).size.width < 380;

    return Scaffold(
      backgroundColor: dark ? AppColors.dark : AppColors.light,
      bottomNavigationBar: ProductDetailBottomBarWrapper(
        product: product,
        dark: dark,
        isSmallScreen: isSmallScreen,
      ),
      body: SafeArea(
        child: isDesktop
            ? ProductDetailDesktopLayout(product: product, dark: dark)
            : ProductDetailMobileLayout(product: product, dark: dark),
      ),
    );
  }
}
