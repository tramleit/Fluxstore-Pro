import 'dart:async';

import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../common/constants.dart';
import '../../../../generated/l10n.dart';
import '../../../../models/entities/product.dart';
import '../../../../models/entities/user.dart';
import '../../../../services/index.dart';

enum ListingBookingModelState { loading, loaded }

enum Availability { empty, notEmpty, error }

extension DiacriticsAwareString on String {
  static const diacritics =
      'ÀÁÂÃÄÅàáâãäåÒÓÔÕÕÖØòóôõöøÈÉÊËĚèéêëěðČÇçčÐĎďÌÍÎÏìíîïĽľÙÚÛÜŮùúûüůŇÑñňŘřŠšŤťŸÝÿýŽž';
  static const nonDiacritics =
      'AAAAAAaaaaaaOOOOOOOooooooEEEEEeeeeeeCCccDDdIIIIiiiiLlUUUUUuuuuuNNnnRrSsTtYYyyZz';

  String get withoutDiacriticalMarks => splitMapJoin('',
      onNonMatch: (char) => char.isNotEmpty && diacritics.contains(char)
          ? nonDiacritics[diacritics.indexOf(char)]
          : char);
}

class ListingBookingModel extends ChangeNotifier {
  final _services = Services();
  ListingBookingModelState state = ListingBookingModelState.loaded;
  var availability = Availability.empty;
  int? price = 0;
  int adults = 1;
  String? type;
  String? subType;
  Product? product;

  /// Service booking
  DateTime date = DateTime.now();
  TimeOfDay time = TimeOfDay.now();
  bool isHourScreen = false;
  List<String?> listServices = [];
  List<String?> listTimeSlot = [];

  /// Rental booking
  DateTime dateStart = DateTime.now();
  DateTime dateEnd = DateTime.now();

  /// Event booking
  DateTime eventDate = DateTime.now();

  ListingBookingModel(this.product) {
    if (product!.slots == null) {
      isHourScreen = true;
      checkAvailability();
    }
    if (product!.type == 'event') {
      var eventDate = product!.eventDate!;
      if (eventDate.contains('-')) {
        eventDate = eventDate.substring(0, eventDate.indexOf('-'));
      } else if (eventDate.contains(' ')) {
        eventDate = eventDate.substring(0, eventDate.indexOf(' '));
      }
      var year = int.parse(eventDate.substring(
          eventDate.lastIndexOf('/') + 1, eventDate.length));
      var month = int.parse(eventDate.substring(
          eventDate.indexOf('/') + 1, eventDate.lastIndexOf('/')));
      var day = int.parse(eventDate.substring(0, eventDate.indexOf('/')));

      this.eventDate = DateTime(year, month, day);
    }
  }

  void _updateState(state) {
    this.state = state;
    notifyListeners();
  }

  List<Map<String?, dynamic>> _getListType() {
    var listType = <Map<String?, dynamic>>[];
    switch (product!.type) {
      case 'rental':
      case 'event':
      case 'service':
        {
          type = 'services';
          subType = 'service';
          for (var item in listServices) {
            var value =
                item!.replaceAllMapped(RegExp(r'/[^A-Za-z0-9\-]/'), (match) {
              return '"${match.group(0)}"';
            });

            /// fix for some cases with special charactors, e.g: "Niños. (1)  " -> "ninos-1" not "niños.-(1)--"
            value = value
                .trim()
                .replaceAll(' ', '-')
                .replaceAllMapped(RegExp(r'[./(/)]'), (match) {
                  return '';
                })
                .withoutDiacriticalMarks
                .toLowerCase();
            listType.add({subType: value, 'value': 1});
          }
          break;
        }
    }
    return listType;
  }

  Map<String?, dynamic>? _getDataForBooking() {
    var formattedDate = DateFormat('yyyy-MM-dd', 'en').format(date);
    var formattedDateStart = DateFormat('yyyy-MM-dd', 'en').format(dateStart);
    var formattedDateEnd = DateFormat('yyyy-MM-dd', 'en').format(dateEnd);
    var formattedDateEvent = DateFormat('yyyy-MM-dd', 'en').format(eventDate);
    var listType = _getListType();
    Map<String?, dynamic>? data;

    if (product!.type == 'service') {
      if (listTimeSlot.isNotEmpty) {
        data = {
          'listing_type': product!.type,
          'listing_id': product!.id,
          'date_start': formattedDate,
          'date_end': formattedDate,
          'adults': adults.toString(),
          type: listType,
          'slot': listTimeSlot,
        };
      } else {
        data = {
          'listing_type': product!.type,
          'listing_id': product!.id,
          'date_start': formattedDate,
          'date_end': formattedDate,
          'adults': adults.toString(),
          type: listType,
          '_hour': "${time.hour}:${time.minute < 10 ? 0 : ''}${time.minute}",
        };
      }
    }
    if (product!.type == 'rental') {
      data = {
        'listing_id': product!.id,
        'adults': adults.toString(),
        'date_start': formattedDateStart,
        'date_end': formattedDateEnd,
        type: listType
      };
    }
    if (product!.type == 'event') {
      data = {
        'listing_id': product!.id,
        'tickets': adults.toString(),
        'date_start': formattedDateEvent,
        type: listType
      };
    }
    return data;
  }

  Map<String?, dynamic>? _getDataForCheckingAvailability() {
    var formattedDate = DateFormat('yyyy-MM-dd', 'en').format(date);
    var formattedDateStart = DateFormat('yyyy-MM-dd', 'en').format(dateStart);
    var formattedDateEnd = DateFormat('yyyy-MM-dd', 'en').format(dateEnd);
    var formattedDateEvent = DateFormat('yyyy-MM-dd', 'en').format(eventDate);
    var listType = _getListType();
    Map<String?, dynamic>? data;

    if (product!.type == 'service') {
      if (isHourScreen) {
        data = {
          'listing_id': product!.id,
          'adults': adults.toString(),
          'date_start': formattedDate,
          'date_end': formattedDate,
          'hour': "${time.hour}:${time.minute < 10 ? 0 : ''}${time.minute}",
          type: listType
        };
      } else {
        data = {
          'listing_id': product!.id,
          'adults': adults.toString(),
          'date_start': formattedDate,
          'date_end': formattedDate,
          'slot': listTimeSlot,
          type: listType
        };
      }
    }
    if (product!.type == 'rental') {
      data = {
        'listing_id': product!.id,
        'adults': adults.toString(),
        'date_start': formattedDateStart,
        'date_end': formattedDateEnd,
        type: listType
      };
    }
    if (product!.type == 'event') {
      data = {
        'listing_id': product!.id,
        'adults': adults.toString(),
        'date_start': formattedDateEvent,
        type: listType
      };
    }
    return data;
  }

  Future<void> checkAvailability() async {
    _updateState(ListingBookingModelState.loading);

    availability = Availability.notEmpty;

    final data = _getDataForCheckingAvailability();

    var result = await _services.api.checkBookingAvailability(data: data);
    if (result!.isNotEmpty) {
      price = result['price'];
      if (result['free_places'] == 0) {
        availability = Availability.notEmpty;
      } else {
        availability = Availability.empty;
      }
    } else {
      availability = Availability.error;
    }
    _updateState(ListingBookingModelState.loaded);
  }

  Future<void> setGuest(bool isIncreased) async {
    if (adults > 1) {
      isIncreased ? adults++ : adults--;
    } else if (adults == 1 && isIncreased) {
      adults++;
    }
    _updateState(ListingBookingModelState.loading);
    EasyDebounce.debounce('set-guest', const Duration(milliseconds: 500),
        () async {
      await checkAvailability();
      _updateState(ListingBookingModelState.loaded);
    });
  }

  Future<void> setDate(date) async {
    this.date = date;
    if (listTimeSlot.isNotEmpty) {
      clearTimeSlot();
    }
    if (isHourScreen) {
      await checkAvailability();
    }
    _updateState(ListingBookingModelState.loaded);
  }

  Future<void> setDateStart(dateStart) async {
    this.dateStart = dateStart;
    if (dateStart.compareTo(dateEnd) == 1) {
      dateEnd = dateStart;
    }
    await checkAvailability();
    _updateState(ListingBookingModelState.loaded);
  }

  Future<void> setDateEnd(dateEnd) async {
    this.dateEnd = dateEnd;
    await checkAvailability();
    _updateState(ListingBookingModelState.loaded);
  }

  Future<void> setTime(time) async {
    this.time = time;
    await checkAvailability();
    _updateState(ListingBookingModelState.loaded);
  }

  void updateListServices(String? service) async {
    if (listServices.contains(service)) {
      listServices.remove(service);
    } else {
      listServices.add(service);
    }
    EasyDebounce.debounce(
        'update-list-services',
        const Duration(milliseconds: 500),
        () async => await checkAvailability());
    _updateState(ListingBookingModelState.loaded);
  }

  void updateListTimeSlot(String? timeSlot, int weekday, int index) async {
    var value = '$weekday|$index';
    if (listTimeSlot.contains(timeSlot)) {
      clearTimeSlot();
    } else {
      clearTimeSlot();
      listTimeSlot.add(timeSlot);
      listTimeSlot.add(value);
    }

    EasyDebounce.debounce(
        'update-list-time-slot',
        const Duration(milliseconds: 500),
        () async => await checkAvailability());

    _updateState(ListingBookingModelState.loaded);
  }

  void clearTimeSlot() {
    listTimeSlot.clear();
  }

  Future<BookStatus> requestBooking(User? user, BuildContext context) async {
    _updateState(ListingBookingModelState.loading);

    final data = _getDataForBooking();
    var status = BookStatus.unavailable;
    if (listTimeSlot.isNotEmpty || isHourScreen) {
      status = await (_services.api.bookService(
        userId: user!.id,
        value: data,
        message: S.of(context).loading,
      ) as Future<BookStatus>);
    }

    _updateState(ListingBookingModelState.loaded);
    return status;
  }
}
