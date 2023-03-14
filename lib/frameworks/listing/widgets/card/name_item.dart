import 'package:flutter/material.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:quiver/strings.dart';

import '../../../../common/tools.dart';
import '../../../../models/entities/product.dart';

class NameItem extends StatelessWidget {
  final bool hideTitle;
  final Product item;
  final int? maxLines;
  const NameItem(
      {this.hideTitle = false, required this.item, this.maxLines = 1});

  @override
  Widget build(BuildContext context) {
    var titleFontSize = Tools.isTablet(MediaQuery.of(context)) ? 20.0 : 14.0;
    var hasName = isNotBlank(item.name);
    if (hideTitle || !hasName) return const SizedBox();
    return Row(
      children: [
        Expanded(
          child: Text(
            HtmlUnescape().convert(item.name!),
            style:
                TextStyle(fontSize: titleFontSize, fontWeight: FontWeight.w600),
            maxLines: maxLines ?? 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        item.verified ?? false
            ? Icon(
                Icons.verified_user,
                size: 18,
                color: Theme.of(context).colorScheme.secondary,
              )
            : const SizedBox()
      ],
    );
  }
}
