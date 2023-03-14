import 'package:flutter/material.dart';

import '../../../common/tools.dart';
import '../../../models/index.dart';
import '../../../modules/dynamic_layout/config/product_config.dart';
import '../../../widgets/product/action_button_mixin.dart';
import '../../../widgets/product/widgets/heart_button.dart';
import 'card/name_item.dart';
import 'card/price_item.dart';

class ListingGlass extends StatelessWidget with ActionButtonMixin {
  final Product item;
  final double width;
  final ProductConfig config;
  const ListingGlass({
    required this.item,
    required this.width,
    required this.config,
  });

  @override
  Widget build(BuildContext context) {
    var maxHeight = width * config.imageRatio;

    Widget productImage = Stack(
      children: <Widget>[
        ClipRRect(
          borderRadius:
              BorderRadius.circular(((config.borderRadius ?? 3) * 0.7)),
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(3.0),
                child: ImageResize(
                  url: item.imageFeature ?? '',
                  width: width,
                  height: maxHeight,
                  size: kSize.medium,
                  fit: BoxFit.cover,
                ),
              ),
              if (config.showHeart)
                Positioned(
                  top: -7,
                  right: -7,
                  child: HeartButton(
                    product: item,
                    size: 18,
                    color: Colors.white,
                  ),
                ),
            ],
          ),
        ),
      ],
    );

    Widget productInfo = Column(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        NameItem(
          item: item,
          hideTitle: config.hideTitle,
          maxLines: config.titleLine,
        ),
        const SizedBox(height: 5),
        PriceItem(item: item, config: config),
      ],
    );

    return GestureDetector(
      onTap: () => onTapProduct(context, product: item, config: config),
      behavior: HitTestBehavior.opaque,
      child: Stack(
        children: <Widget>[
          Container(
            constraints: BoxConstraints(maxWidth: width),
            margin: EdgeInsets.symmetric(
              horizontal: config.hMargin,
              vertical: config.vMargin,
            ),
            width: width,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(config.borderRadius ?? 3),
              child: Container(
                decoration: BoxDecoration(
                  gradient: SweepGradient(
                    colors: [
                      Theme.of(context).colorScheme.secondary.withOpacity(0.5),
                      Theme.of(context).cardColor,
                      Theme.of(context).primaryColor.withOpacity(0.5),
                      Theme.of(context).colorScheme.background,
                      Theme.of(context).colorScheme.secondary.withOpacity(0.5),
                    ],
                  ),
                ),
                child: Container(
                  color: Theme.of(context).cardColor.withOpacity(0.5),
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    // mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      productImage,
                      const Spacer(),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: (config.borderRadius ?? 6) * 0.25,
                        ),
                        child: productInfo,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (config.showHeart && !item.isEmptyProduct())
            Positioned(
              top: 5,
              right: 5,
              child: HeartButton(product: item, size: 18),
            )
        ],
      ),
    );
  }
}
