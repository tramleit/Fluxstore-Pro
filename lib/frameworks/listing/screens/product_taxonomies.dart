import 'package:flutter/material.dart';
import 'package:html_unescape/html_unescape.dart';

import '../../../models/entities/index.dart';
import '../../../widgets/common/expansion_info.dart';

class ProductTaxonomies extends StatelessWidget {
  final Product? product;
  final String? type;
  final String title;

  const ProductTaxonomies({this.product, this.type, this.title = ''});

  @override
  Widget build(BuildContext context) {
    if (product!.pureTaxonomies == null) return const SizedBox();

    final theme = Theme.of(context);
    var list = <Widget>[];
    if (product!.pureTaxonomies![type] != null) {
      var categories = product!.pureTaxonomies![type];
      list.add(Column(
        children: <Widget>[
          for (var item in categories)
            Padding(
              padding: const EdgeInsets.only(bottom: 4.0),
              child: Row(
                children: <Widget>[
                  const SizedBox(width: 20),
                  Icon(
                    Icons.check_box,
                    color: theme.primaryColor,
                    size: 20,
                  ),
                  const SizedBox(
                    width: 10.0,
                  ),
                  Text(HtmlUnescape().convert(item['name']))
                ],
              ),
            ),
        ],
      ));
    }
    if (list.isEmpty) return const SizedBox();
    return Column(
      children: <Widget>[
        ExpansionInfo(
          expand: true,
          title: title,
          children: list,
        ),
      ],
    );
  }
}
