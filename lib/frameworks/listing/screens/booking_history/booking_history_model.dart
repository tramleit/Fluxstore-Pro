import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../../models/entities/listing_booking.dart';
import '../../../../services/index.dart';

enum BookingHistoryState { loading, loaded, isLoadingMore, noMore }

class BookingHistoryModel extends ChangeNotifier {
  var state = BookingHistoryState.loaded;
  List<ListingBooking> bookings = [];
  final _service = Services();
  final RefreshController refreshController =
      RefreshController(initialRefresh: false);
  int page = 0;
  int perPage = 10;

  void _updateState(state) {
    this.state = state;
    notifyListeners();
  }

  BookingHistoryModel(userId) {
    loadBooking(userId);
  }

  void loadBooking(userId) async {
    if (state == BookingHistoryState.loaded) {
      page = 0;
      _updateState(BookingHistoryState.loading);
      bookings.clear();
      bookings = await _service.api.getBooking(
        userId: userId,
        page: page,
        perPage: perPage,
      )!;
      refreshController.refreshCompleted();
      _updateState(BookingHistoryState.loaded);
    }
  }

  void loadMore(userId) async {
    if (state == BookingHistoryState.loaded) {
      page++;
      _updateState(BookingHistoryState.isLoadingMore);

      final list = await _service.api.getBooking(
        userId: userId,
        page: page,
        perPage: perPage,
      )!;
      refreshController.loadComplete();

      if (list.isEmpty) {
        _updateState(BookingHistoryState.noMore);
        return;
      }
      bookings.addAll(list);
      _updateState(BookingHistoryState.loaded);
    }
  }
}
