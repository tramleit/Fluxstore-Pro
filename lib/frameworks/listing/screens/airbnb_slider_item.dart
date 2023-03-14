import 'package:flutter/material.dart';

import '../../../common/tools.dart';

class AirbnbSliderItem extends StatefulWidget {
  final int? pos;
  final int? length;
  final String? image;
  final PageController? controller;
  final bool? autoPlay;
  final double? height;

  const AirbnbSliderItem(
      {this.pos,
      this.length,
      this.image,
      this.autoPlay,
      this.height,
      this.controller});

  @override
  State<AirbnbSliderItem> createState() => _StateAirbnbSliderItem();
}

class _StateAirbnbSliderItem extends State<AirbnbSliderItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 6));
    _animation = Tween(begin: 1.0, end: 1.2).animate(_controller);
    if (widget.autoPlay!) {
      _controller.forward().then((_) {
        nextPage();
      });
    }
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void nextPage() {
    if (widget.pos! >= widget.length! - 1) {
      widget.controller!.jumpToPage(0);
    } else {
      if (widget.pos != null) {
        widget.controller!.animateToPage(widget.pos! + 1,
            duration: const Duration(seconds: 1), curve: Curves.easeInOut);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(
          scale: _animation.value,
          child: Stack(
            children: <Widget>[
              ImageResize(
                url: widget.image,
                fit: BoxFit.cover,
                height: widget.height! + 50,
                width: MediaQuery.of(context).size.width,
                size: kSize.large,
                isResize: true,
              ),
              Positioned(
                bottom: 0,
                child: Container(
                  height: 100,
                  width: MediaQuery.of(context).size.width,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [Colors.black, Colors.transparent],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 0,
                child: Container(
                  height: 120,
                  width: MediaQuery.of(context).size.width,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [Colors.transparent, Colors.black38],
                    ),
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
