import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../common/config.dart';
import 'airbnb_slider_item.dart';

class AirbnbSlider extends StatefulWidget {
  final List<String?>? images;
  final double? height;

  const AirbnbSlider({this.images, this.height});

  @override
  State<AirbnbSlider> createState() => _StateAirbnbSlider();
}

class _StateAirbnbSlider extends State<AirbnbSlider> {
  final _controller = PageController();
  int position = 0;

  @override
  Widget build(BuildContext context) {
    return widget.images!.isNotEmpty
        ? Stack(
            children: [
              PageView(
                controller: _controller,
                onPageChanged: (index) {
                  if (mounted) {
                    setState(() {
                      position = index;
                    });
                  }
                },
                children: <Widget>[
                  for (int i = 0; i < widget.images!.length; i++)
                    AirbnbSliderItem(
                      image: widget.images![i],
                      controller: _controller,
                      pos: i,
                      length: widget.images!.length,
                      height: widget.height,
                      autoPlay: kProductDetail.autoPlayGallery,
                    ),
                ],
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: SmoothPageIndicator(
                  controller: _controller, // PageController
                  count: widget.images!.length,
                  effect: const SlideEffect(
                    spacing: 8.0,
                    radius: 5.0,
                    dotWidth: 24.0,
                    dotHeight: 2.0,
                    paintStyle: PaintingStyle.fill,
                    strokeWidth: 1.5,
                    dotColor: Colors.black12,
                    activeDotColor: Colors.black87,
                  ),
                ),
              ),
            ],
          )
        : const SizedBox();
  }
}
