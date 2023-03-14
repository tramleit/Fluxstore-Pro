import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../common/theme/colors.dart';
import '../../../generated/l10n.dart';
import '../../../models/index.dart';
import '../../../modules/dynamic_layout/config/product_config.dart';
import '../../../widgets/product/product_card_view.dart';

class Recent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        return ListenableProvider.value(
          value: Provider.of<SearchModel>(context),
          child: Consumer<SearchModel>(builder: (context, model, child) {
            if (model.products == null || model.products!.isEmpty) {
              return const SizedBox();
            }
            return Container(
              width: screenWidth,
              constraints: const BoxConstraints(minHeight: 0),
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: screenWidth,
                  child: Column(
                    children: <Widget>[
                      const SizedBox(
                        height: 20,
                      ),
                      SizedBox(
                        width: screenWidth,
                        child: FittedBox(
                          fit: BoxFit.cover,
                          child: SizedBox(
                            width: screenWidth /
                                (2 /
                                    (MediaQuery.of(context).size.height /
                                        screenWidth)),
                            child: Row(
                              children: <Widget>[
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(S.of(context).recents,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w700)),
                                ),
//                FlatButton(
//                    onPressed: null,
//                    child: Text(
//                      S.of(context).seeAll,
//                      style: TextStyle(color: Colors.greenAccent, fontSize: 13),
//                    ))
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Divider(
                        height: 1,
                        color: kGrey200,
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: screenWidth,
                        height: screenWidth * 0.35 + 120,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              for (var item in model.products!)
                                FittedBox(
                                  child: ProductCard(
                                    item: item,
                                    width: screenWidth * 0.35,
                                    config: ProductConfig.empty(),
                                  ),
                                )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
