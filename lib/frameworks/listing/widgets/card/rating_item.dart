import 'package:flutter/material.dart';
import '../../../../common/tools.dart';
import '../../../../models/entities/product.dart';
import '../../../../modules/dynamic_layout/config/product_config.dart';
import '../../../../widgets/common/start_rating.dart';

class RatingItem extends StatelessWidget {
  final Product item;
  final ProductConfig config;
  const RatingItem({required this.item, required this.config});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    var starSize = Tools.isTablet(MediaQuery.of(context)) ? 20.0 : 12.0;
    if (!config.enableRating) return const SizedBox();

    return Row(
      children: <Widget>[
        (item.averageRating != null && item.averageRating != 0.0)
            ? SmoothStarRating(
                allowHalfRating: true,
                starCount: 5,
                rating: item.averageRating ?? 0.0,
                size: starSize,
                color: theme.primaryColor,
                borderColor: theme.primaryColor,
                spacing: 0.0,
                label: const SizedBox(),
              )
            : const SizedBox(),
        if (item.totalReview != 0)
          Text(
            ' (${item.totalReview}) ',
            style: Theme.of(context).textTheme.displayLarge!.copyWith(
                fontSize: 12, color: Theme.of(context).colorScheme.secondary),
          ),
      ],
    );
  }
}
