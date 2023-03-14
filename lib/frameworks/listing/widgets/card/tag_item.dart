import 'package:flutter/material.dart';

import '../../../../common/tools.dart';
import '../../../../models/index.dart';

class TagItem extends StatelessWidget {
  final Product item;
  const TagItem({required this.item});

  @override
  Widget build(BuildContext context) {
    var subTitleFontSize = Tools.isTablet(MediaQuery.of(context)) ? 16.0 : 11.0;

    if (item.tagLine == null) return const SizedBox();

    return Text(
      item.tagLine.toString(),
      maxLines: 1,
      style: TextStyle(
        fontSize: subTitleFontSize,
      ),
    );
  }
}
