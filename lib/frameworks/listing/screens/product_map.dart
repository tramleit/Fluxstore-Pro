import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../common/config.dart';
import '../../../common/constants.dart';
import '../../../common/tools.dart';
import '../../../generated/l10n.dart';
import '../../../models/entities/index.dart';
import '../../../screens/base_screen.dart';
import '../../../screens/common/google_map_mixin.dart';
import '../../../widgets/common/expansion_info.dart';
import '../../../widgets/common/flux_image.dart';

class ProductMap extends StatefulWidget {
  final Product? product;
  final bool static;

  const ProductMap({this.product, this.static = true});

  @override
  BaseScreen<ProductMap> createState() => _ProductMapState();
}

class _ProductMapState extends BaseScreen<ProductMap> with GoogleMapMixin {
  GoogleMapController? pageController;
  bool isShowMap = false;
  Uri? renderMapURL;

  @override
  void afterFirstLayout(BuildContext context) {
    if (mounted) {
      setState(() {
        isShowMap = true;
      });
    }
  }

  void _onMapCreated(GoogleMapController controllerParam) async {
    if (mounted) {
      await setMapStyle(controllerParam);
      setState(() {
        pageController = controllerParam;
      });
    }
  }

  Set<Marker> _createMarker() {
    var kMapCenter = LatLng(widget.product!.lat!, widget.product!.long!);

    // https://github.com/flutter/flutter/issues/28312
    // ignore: prefer_collection_literals
    return <Marker>[
      Marker(
        markerId: const MarkerId('marker_1'),
        position: kMapCenter,
        infoWindow: InfoWindow(title: widget.product!.location, snippet: '*'),
      ),
    ].toSet();
  }

  Widget getRegion() {
    var lat = widget.product!.lat;
    var long = widget.product!.long;

    var type = DataMapping().kTaxonomies['region'];
    if (widget.product!.pureTaxonomies == null) return const SizedBox();
    if (widget.product!.pureTaxonomies![type] != null) {
      var taxonomies = widget.product!.pureTaxonomies![type];
      return InkWell(
        onTap: () => Tools.launchMapsURL(lat, long),
        child: Container(
          color: Theme.of(context).primaryColorLight.withOpacity(0.7),
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          child: Row(
            children: <Widget>[
              const SizedBox(width: 5),
              Icon(
                Icons.directions,
                color: Theme.of(context).primaryColor,
                size: 25,
              ),
              const SizedBox(width: 10),
              for (var item in taxonomies)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: Text(
                    item['name'],
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                      fontSize: 13,
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    }
    return const SizedBox();
  }

  void _buildUrl() {
    var defaultLocation = <String, String>{
      'latitude': '${widget.product!.lat}',
      'longitude': '${widget.product!.long}'
    };

    // this should change to your own Google API key
    var googleMapsApiKey;
    if (isIos) {
      googleMapsApiKey = kGoogleApiKey.ios;
    } else if (isAndroid) {
      googleMapsApiKey = kGoogleApiKey.android;
    } else {
      googleMapsApiKey = kGoogleApiKey.web;
    }

    var mapURL = Uri(
        scheme: 'https',
        host: 'maps.googleapis.com',
        port: 443,
        path: '/maps/api/staticmap',
        queryParameters: {
          'size': '800x600',
          'center':
              '${defaultLocation['latitude']},${defaultLocation['longitude']}',
          'zoom': '13',
          'maptype': 'roadmap',
          'markers':
              'color:red|label:C|${widget.product!.lat},${widget.product!.long}',
          'key': '$googleMapsApiKey',
          'style': getMapStyleParams(),
        });

    if (mounted) {
      setState(() {
        renderMapURL = mapURL;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.product!.lat == null || widget.product!.long == null) {
      return const SizedBox();
    }

    var kMapCenter = LatLng(widget.product!.lat!, widget.product!.long!);
    _buildUrl();
    var lat = widget.product!.lat;
    var long = widget.product!.long;
    if (widget.static && renderMapURL != null) {
      return Column(
        children: <Widget>[
          ExpansionInfo(
            title: S.of(context).map,
            expand: true,
            children: [
              const SizedBox(height: 10),
              InkWell(
                onTap: () => Tools.launchMapsURL(lat, long),
                child: Stack(
                  children: <Widget>[
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .primaryColorLight
                              .withOpacity(0.7),
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.width / 2 + 20,
                        child: FluxImage(
                          imageUrl: renderMapURL.toString(),
                          width: MediaQuery.of(context).size.width,
                          fit: BoxFit.cover,
                          errorWidget: Center(
                            child: Text(
                              S.of(context).viewOnGoogleMaps,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: Theme.of(context).primaryColor,
                                  ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: getRegion(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10)
            ],
          ),
        ],
      );
    }

    // this is use for the MapView plugins

    return Column(
      children: <Widget>[
        const SizedBox(height: 15),
        ExpansionInfo(
          title: S.of(context).map,
          expand: true,
          children: [
            const SizedBox(height: 10),
            getRegion(),
            InkWell(
              onTap: () => Tools.launchMapsURL(lat, long),
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.width / 2 + 20,
                child: isShowMap
                    ? GoogleMap(
                        mapType: MapType.normal,
                        initialCameraPosition: CameraPosition(
                          target: kMapCenter,
                          zoom: 11.0,
                        ),
                        markers: _createMarker(),
                        onMapCreated: _onMapCreated,
                      )
                    : const SizedBox(),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
