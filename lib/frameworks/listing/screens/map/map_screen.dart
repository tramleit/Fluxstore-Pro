import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:inspireui/inspireui.dart' show PlatformError, Skeleton;
import 'package:provider/provider.dart';

import '../../../../common/constants.dart';
import '../../../../generated/l10n.dart';
import '../../../../models/index.dart';
import '../../../../modules/dynamic_layout/index.dart';
import '../../../../screens/common/app_bar_mixin.dart';
import '../../../../screens/common/google_map_mixin.dart';
import '../../widgets/listing_card_view.dart';
import 'map_model.dart';
import 'radius_slider.dart';

/// Map Screen
class MapScreen extends StatefulWidget {
  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen>
    with AppBarMixin, GoogleMapMixin {
  void _onMapCreated(GoogleMapController controller, MapModel mapModel) async {
    mapModel.mapController = controller;
    await setMapStyle(controller);
  }

  Widget _buildCarousel(width, products, MapModel mapModel) {
    if (products.isEmpty) {
      return Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
          margin: const EdgeInsets.symmetric(vertical: 20.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15.0),
            color: Colors.grey.withOpacity(0.6),
          ),
          child: Text(
            S.of(context).noListingNearby,
            style: const TextStyle(fontSize: 16.0, color: Colors.white),
          ),
        ),
      );
    }
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 20.0),
        child: CarouselSlider(
          items: List.generate(products.length, (index) {
            return ListingCardView(
              item: products[index],
              width: width * 0.8,
              height: 200.0,
              config: ProductConfig.empty(),
            );
          }),
          options: CarouselOptions(
            onPageChanged: mapModel.onPageChange,
            enlargeCenterPage: true,
            height: width * 0.6,
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingCarousel(width) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 20.0),
        child: CarouselSlider(
          items: List.generate(5, (index) {
            return Skeleton(
              width: width * 0.8,
            );
          }),
          options: CarouselOptions(
            enlargeCenterPage: true,
            height: width * 0.6,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ModalRoute<dynamic>? parentRoute = ModalRoute.of(context);
    final canPop = parentRoute?.canPop ?? false;
    if (!isMobile) return const PlatformError();

    return LayoutBuilder(
      builder: (context, constraints) {
        var width = constraints.maxWidth;
        return Selector<AppModel, bool>(
          selector: (context, model) => model.darkTheme,
          builder: (context, isDarkMode, child) {
            updateMapStyle(isDarkMode);
            return child ?? const SizedBox();
          },
          child: ChangeNotifierProvider<MapModel>(
            create: (_) => MapModel(),
            child: renderScaffold(
              disableSafeArea: true,
              routeName: RouteList.map,
              resizeToAvoidBottomInset: false,
              child: Consumer<MapModel>(
                builder: (context, mapModel, _) {
                  return Stack(
                    children: <Widget>[
                      SizedBox(
                        width: width,
                        height: MediaQuery.of(context).size.height,
                        child: GoogleMap(
                          mapType: MapType.normal,
                          initialCameraPosition: mapModel.currentUserLocation,
                          myLocationEnabled: true,
                          myLocationButtonEnabled: false,
                          onMapCreated: (controller) =>
                              _onMapCreated(controller, mapModel),
                          markers: mapModel.markers,
                          circles: mapModel.circles,
                          compassEnabled: false,
                          zoomControlsEnabled: false,
                          onCameraMove: mapModel.onGeoChanged,
                        ),
                      ),
                      if (mapModel.state == MapModelState.loaded)
                        _buildCarousel(constraints.maxWidth,
                            mapModel.nearestProducts, mapModel),
                      if (mapModel.state == MapModelState.loading)
                        _buildLoadingCarousel(constraints.maxWidth),
                      SafeArea(
                        child: Row(
                          children: [
                            if (canPop) const SizedBox(width: 8),
                            if (canPop)
                              InkWell(
                                onTap: Navigator.of(context).pop,
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(24.0),
                                      color: Theme.of(context).colorScheme.background),
                                  child: const Center(
                                    child: Icon(
                                      Icons.arrow_back,
                                    ),
                                  ),
                                ),
                              ),
                            Expanded(
                              child: RadiusSlider(
                                maxRadius: mapModel.maxRadius,
                                minRadius: mapModel.minRadius,
                                onCallBack: (val) =>
                                    mapModel.getNearestProducts(radius: val),
                                currentVal: mapModel.radius,
                                moveToCurrentPos: mapModel.moveToCurrentPos,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
