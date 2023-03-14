import 'package:flutter/material.dart';
import 'package:quiver/strings.dart';

import '../../../common/tools.dart';
import '../../../generated/l10n.dart';
import '../../../models/entities/index.dart';
import '../../../widgets/common/expansion_info.dart';

class ProductMenu extends StatelessWidget {
  final Product? product;

  const ProductMenu({this.product});

  @override
  Widget build(BuildContext context) {
    final prices = product!.listingMenu!;
    return ExpansionInfo(
      expand: true,
      title: S.of(context).prices,
      children: <Widget>[
        Column(
          children: List.generate(prices.length, (i) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    prices[i].title != null
                        ? prices[i].title.isNotEmpty
                            ? prices[i].title
                            : ''
                        : '',
                    style: TextStyle(
                      fontSize: 22,
                      color: Theme.of(context)
                          .colorScheme
                          .secondary
                          .withOpacity(0.5),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Column(
                    children: List.generate(
                      prices[i].menu.length,
                      (index) {
                        return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(
                                height: 4,
                              ),
                              Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Text(
                                      prices[i].menu[index].name,
                                      style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Text(
                                    PriceTools.getCurrencyFormatted(
                                        prices[i].menu[index].price, null)!,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      color: Colors.lightGreen,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              if (isNotBlank(prices[i].menu[index].description))
                                const SizedBox(
                                  height: 2,
                                ),
                              if (isNotBlank(prices[i].menu[index].description))
                                Text(
                                  prices[i].menu[index].description,
                                  style: const TextStyle(
                                    fontSize: 12,
                                  ),
                                ),
                              const SizedBox(
                                height: 2,
                              ),
                              const Divider(),
                            ]);
                      },
                    ),
                  )
                ],
              ),
            );
          }),
        ),
      ],
    );
  }
}
