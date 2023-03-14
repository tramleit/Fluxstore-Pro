import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

import '../../../../common/config.dart';
import '../../../../common/constants.dart';
import '../../../../models/entities/index.dart';
import '../../../../services/index.dart';

enum MapModelState { loading, loaded }

class MapModel extends ChangeNotifier {
  List<Product> nearestProducts = [];
  final _services = Services();
  LocationData? currentLocation;
  MapModelState state = MapModelState.loading;
  Set<Marker> markers = <Marker>{};
  late GoogleMapController mapController;
  Set<Circle> circles = <Circle>{};
  var radius = kAdvanceConfig.queryRadiusDistance * 1.0;
  var minRadius = kAdvanceConfig.minQueryRadiusDistance * 1.0;
  var maxRadius = kAdvanceConfig.maxQueryRadiusDistance * 1.0;
  var zoom = 15.0;
  late CameraPosition currentUserLocation;

  void _updateState(state) {
    this.state = state;
    notifyListeners();
  }

  MapModel() {
    currentUserLocation = CameraPosition(
      target: const LatLng(
        0.0,
        0.0,
      ),
      zoom: zoom,
    );
    getNearestProducts();
  }

  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void onGeoChanged(CameraPosition position) {
    zoom = position.zoom;
  }

  Future<void> getUserCurrentLocation() async {
    var location = Location();
    currentLocation = await location.getLocation();
    currentUserLocation = CameraPosition(
      target: LatLng(
        currentLocation!.latitude!,
        currentLocation!.longitude!,
      ),
      zoom: zoom,
    );
    circles = {
      Circle(
          circleId: const CircleId('currentLocation'),
          center: LatLng(
            currentLocation!.latitude!,
            currentLocation!.longitude!,
          ),
          radius: radius * 1000,
          fillColor: Colors.blue.withOpacity(0.3),
          strokeColor: Colors.blue,
          strokeWidth: 1)
    };
  }

  void _updateRadius(double radius) {
    this.radius = radius;
    circles = {
      Circle(
          circleId: const CircleId('currentLocation'),
          center: LatLng(
            currentLocation!.latitude!,
            currentLocation!.longitude!,
          ),
          radius: this.radius * 1000,
          fillColor: Colors.blue.withOpacity(0.3),
          strokeColor: Colors.blue,
          strokeWidth: 1)
    };
    notifyListeners();
  }

  void getNearestProducts({double? radius}) {
    if (radius != null) {
      _updateRadius(radius);
    }
    EasyDebounce.debounce(
        'getNearestProducts', const Duration(milliseconds: 500), () async {
      if (state != MapModelState.loading) {
        _updateState(MapModelState.loading);
      }
      markers.clear();
      nearestProducts.clear();
      if (currentLocation == null) {
        await getUserCurrentLocation();
        await mapController.animateCamera(
          CameraUpdate.newCameraPosition(CameraPosition(
            target: LatLng(
              currentLocation!.latitude!,
              currentLocation!.longitude!,
            ),
            zoom: zoom,
          )),
        );
      }
      printLog('getNearestProducts start');
      var data = {
        'lat': currentLocation!.latitude,
        'long': currentLocation!.longitude,
        'page': 1,
        'perPage': 10,
        'radius': this.radius,
      };
      var list = await _services.api.getProductNearest(data)!;
      nearestProducts.addAll(list);
      for (var element in nearestProducts) {
        markers.add(
          Marker(
            markerId: MarkerId('map-${element.id}'),
            infoWindow: InfoWindow(
              title: '',
              onTap: () {},
            ),
            position: LatLng(element.lat!, element.long!),
          ),
        );
      }
      _updateState(MapModelState.loaded);
      printLog('getNearestProducts done');
    });
  }

  void onPageChange(index, reason) {
    mapController.animateCamera(
      CameraUpdate.newCameraPosition(CameraPosition(
        target:
            LatLng(nearestProducts[index].lat!, nearestProducts[index].long!),
        zoom: zoom,
      )),
    );
    notifyListeners();
  }

  void moveToCurrentPos() {
    if (currentLocation != null) {
      mapController.animateCamera(
        CameraUpdate.newCameraPosition(CameraPosition(
          target:
              LatLng(currentLocation!.latitude!, currentLocation!.longitude!),
          zoom: zoom,
        )),
      );
    }
  }
}
