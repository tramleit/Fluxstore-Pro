import 'package:flutter/material.dart';

import '../../../../models/entities/index.dart';
import '../../../../widgets/common/start_rating.dart';

class Thumbnail extends StatelessWidget {
  final Product? product;

  const Thumbnail({this.product});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Image.network(
          product!.imageFeature!,
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height / 5,
          fit: BoxFit.cover,
        ),
        Positioned(
          bottom: 0,
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: 70,
            decoration: const BoxDecoration(boxShadow: [
              BoxShadow(color: Colors.black54, spreadRadius: 20, blurRadius: 50)
            ]),
            child: const SizedBox(),
          ),
        ),
        Positioned(
          bottom: 10,
          left: 10,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SizedBox(
                height: 4,
              ),
              Text(
                product!.name!,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(
                height: 2,
              ),
              SmoothStarRating(
                allowHalfRating: true,
                starCount: 5,
                rating: product!.averageRating,
                size: 13.0,
                color: Theme.of(context).primaryColor,
                borderColor: Theme.of(context).primaryColor,
                spacing: 0.0,
                label: const SizedBox(),
              ),
              const SizedBox(
                height: 4,
              ),
              Text(
                product!.tagLine ?? '',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w300,
                  color: Colors.white,
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}
