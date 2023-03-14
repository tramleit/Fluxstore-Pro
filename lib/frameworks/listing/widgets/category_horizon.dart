import 'package:flutter/material.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:provider/provider.dart';

import '../../../common/theme/colors.dart';
import '../../../common/tools.dart';
import '../../../generated/l10n.dart';
import '../../../models/index.dart';
import '../../../modules/dynamic_layout/helper/header_view.dart';
import '../../../widgets/common/flux_image.dart';

/// Category Horizontal List
class CategoryHorizontal extends StatefulWidget {
  final BoxConstraints viewportConstraints;

  const CategoryHorizontal(this.viewportConstraints);

  @override
  State<CategoryHorizontal> createState() => _CategoryHorizontalState();
}

class _CategoryHorizontalState extends State<CategoryHorizontal> {
  void afterFirstLayout(BuildContext context) {
    Provider.of<CategoryModel>(context, listen: false).getCategories();
  }

  @override
  Widget build(BuildContext context) {
    final itemBox = widget.viewportConstraints.maxWidth / 4;
    final category = Provider.of<CategoryModel>(context);
    return ListenableProvider<CategoryModel>.value(
      value: category,
      child: Consumer<CategoryModel>(
        builder: (builder, value, child) {
          if (value.isLoading) {
            return const CircularProgressIndicator(
                strokeWidth: 2.0, backgroundColor: kTeal400);
          }

          if (value.categories == null) {
            return Container(child: null);
          }
          return Container(
            color: Theme.of(context).colorScheme.background,
            child: Column(children: <Widget>[
              HeaderView(
                headerText: S.of(context).categories,
              ),
              const SizedBox(height: 10.0),
              SizedBox(
                height: itemBox,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    const SizedBox(width: 10.0),
                    for (var item in value.categories!)
                      CategoryItem(
                        context: context,
                        item: item,
                        text: item.name,
                        image: item.image,
                        viewportConstraints: widget.viewportConstraints,
                      ),
                  ],
                ),
              ),
            ]),
          );
        },
      ),
    );
  }
}

/// CategoryItem
class CategoryItem extends StatelessWidget {
  final String? text;
  final String? image;
  final item;
  final context;
  final viewportConstraints;

  const CategoryItem(
      {this.context,
      this.item,
      this.text,
      this.image,
      this.viewportConstraints});

  @override
  Widget build(BuildContext context) {
    final double itemHeight = viewportConstraints.maxWidth / 4;
    final double? itemWidth = viewportConstraints.maxWidth / 3;
    final cateImage = image!;

    return InkWell(
      onTap: () => ProductModel.showList(
        cateId: item.id,
        cateName: text,
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 5.0, right: 5.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: Stack(
            children: <Widget>[
              FluxImage(
                imageUrl: cateImage,
                height: itemHeight,
                width: itemWidth,
                fit: BoxFit.cover,
              ),
              Positioned(
                bottom: 0,
                left: 0,
                child: Container(
                  width: itemWidth,
                  height: itemHeight / 3,
                  child: null,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        HexColor('#000').withAlpha(70),
                        HexColor('#000').withAlpha(80),
                        HexColor('#000').withAlpha(90),
                        HexColor('#000'),
                      ], // whitish to gray
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 10,
                left: 0,
                width: itemWidth,
                child: Center(
                  child: Text(
                    HtmlUnescape().convert(text ?? ''),
                    maxLines: 1,
                    overflow: TextOverflow.fade,
                    style: const TextStyle(
                        fontSize: 16.0,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
