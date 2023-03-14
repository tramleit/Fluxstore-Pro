import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../../common/config.dart';
import '../../../../generated/l10n.dart';
import '../../../../models/index.dart';
import 'booking_history_model.dart';
import 'widgets/booking_detail.dart';

class BookingHistoryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final userId = Provider.of<UserModel>(context, listen: false).user!.id;
    return ChangeNotifierProvider<BookingHistoryModel>(
      create: (_) => BookingHistoryModel(userId),
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        appBar: AppBar(
          leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.of(context).pop();
              }),
          backgroundColor: Theme.of(context).colorScheme.background,
          elevation: 0.0,
          title: Text(
            S.of(context).bookingHistory,
            style: Theme.of(context)
                .textTheme
                .headlineSmall!
                .apply(fontSizeFactor: 0.9),
          ),
        ),
        body: SizedBox(
          width: size.width,
          height: size.height,
          child: Consumer<BookingHistoryModel>(
            builder: (context, model, _) {
              if (model.state == BookingHistoryState.loading) {
                return kLoadingWidget(context);
              }

              return SmartRefresher(
                enablePullDown: true,
                enablePullUp: true,
                header: const WaterDropHeader(),
                footer: CustomFooter(
                  builder: (BuildContext context, LoadStatus? mode) {
                    Widget body = const SizedBox();
                    if (model.state == BookingHistoryState.isLoadingMore) {
                      body = const CupertinoActivityIndicator();
                    }
                    if (model.state == BookingHistoryState.noMore) {
                      body = Text(S.of(context).noData);
                    }
                    if (model.state == BookingHistoryState.loaded) {
                      body = Text(S.of(context).pullToLoadMore);
                    }
                    return SizedBox(
                      height: 55.0,
                      child: Center(child: body),
                    );
                  },
                ),
                controller: model.refreshController,
                onRefresh: () => model.loadBooking(userId),
                onLoading: () => model.loadMore(userId),
                child: ListView.builder(
                  itemBuilder: (context, index) {
                    return BookingDetail(
                      booking: model.bookings[index],
                    );
                  },
                  itemCount: model.bookings.length,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
