import 'package:flutter/material.dart';

import '../../../../common/tools.dart';
import '../../../../models/index.dart';

class DistanceItem extends StatelessWidget {
  final Product item;
  const DistanceItem({required this.item});

  @override
  Widget build(BuildContext context) {
    var distanceFontSize = Tools.isTablet(MediaQuery.of(context)) ? 16.0 : 12.0;

    if (item.distance == null) return const SizedBox();

    return Text(
      item.distance.toString(),
      maxLines: 1,
      style: TextStyle(
        fontSize: distanceFontSize,
      ),
    );
  }
}
