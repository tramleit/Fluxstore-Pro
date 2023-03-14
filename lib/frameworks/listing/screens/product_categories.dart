import 'package:flutter/material.dart';
import 'package:html_unescape/html_unescape.dart';

import '../../../generated/l10n.dart';
import '../../../models/entities/index.dart';

class ProductCategories extends StatelessWidget {
  final Product? product;
  final String? type;
  final String title;

  const ProductCategories({this.product, this.type, this.title = ''});

  @override
  Widget build(BuildContext context) {
    if (product!.pureTaxonomies == null) return const SizedBox();

    if (product!.pureTaxonomies![type] != null) {
      var categories = product!.pureTaxonomies![type];

      return Wrap(
        children: <Widget>[
          if (product!.featured == 'on')
            Container(
              padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 10),
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColorLight,
                borderRadius: BorderRadius.circular(3),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Icon(
                    Icons.stars,
                    size: 20,
                    color: Colors.pink,
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Text(
                    S.of(context).featured,
                    style: const TextStyle(fontSize: 12),
                  )
                ],
              ),
            ),
          for (var item in categories)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
              margin: const EdgeInsets.only(right: 10, bottom: 10),
              decoration: BoxDecoration(
                  border: Border.all(
                      color: Theme.of(context).primaryColor, width: 1.0),
                  borderRadius: BorderRadius.circular(3)),
              child: Text(
                HtmlUnescape().convert(item['name']),
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
        ],
      );
    }

    return const SizedBox();
  }
}
