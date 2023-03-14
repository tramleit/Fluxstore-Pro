import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../common/config.dart';
import '../../../../../common/constants.dart';
import '../../../../../common/tools/price_tools.dart';
import '../../../../../generated/l10n.dart';
import '../../../../../models/app_model.dart';
import '../../../../../models/entities/listing_booking.dart';
import '../../../../../models/user_model.dart';
import '../../booking_payment/booking_payment_model.dart';
import '../../booking_payment/booking_payment_screen.dart';
import '../booking_history_model.dart';

class BookingDetail extends StatefulWidget {
  final ListingBooking? booking;

  const BookingDetail({Key? key, this.booking}) : super(key: key);
  @override
  State<BookingDetail> createState() => _BookingDetailState();
}

class _BookingDetailState extends State<BookingDetail> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final bookingHistoryModel =
        Provider.of<BookingHistoryModel>(context, listen: false);
    final currencyRate =
        Provider.of<AppModel>(context, listen: false).currencyRate;
    final langCode = Provider.of<AppModel>(context, listen: false).langCode;
    return Container(
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.symmetric(
        vertical: 20.0,
        horizontal: 10,
      ),
      padding: const EdgeInsets.only(top: 20, left: 5, right: 5),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: () => setState(() => isExpanded = !isExpanded),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  width: 10,
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(9),
                  child: CachedNetworkImage(
                    imageUrl: widget.booking!.featuredImage!,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  flex: 4,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.booking!.title!,
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Text(
                        '${S.of(context).total}: ${PriceTools.getCurrencyFormatted(
                          widget.booking!.price,
                          currencyRate,
                          currency:
                              kAdvanceConfig.defaultCurrency?.currencyCode,
                        )}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Text(
                        '${S.of(context).on} ${widget.booking!.createdDate}',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColorLight,
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: Text(
                    widget.booking!.orderStatus?.toLowerCase() ==
                                'processing' &&
                            widget.booking!.status!.toLowerCase() == 'confirmed'
                        ? widget.booking!.orderStatus!.toUpperCase()
                        : widget.booking!.status!.toUpperCase(),
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall!
                        .copyWith(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                        )
                        .apply(fontSizeFactor: 0.7),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          InkWell(
            onTap: () => setState(() => isExpanded = !isExpanded),
            child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.fastOutSlowIn,
                width: MediaQuery.of(context).size.width,
                height: isExpanded ? 210 : 44,
                decoration: BoxDecoration(
                  color: isExpanded
                      ? Theme.of(context).primaryColor.withOpacity(0.2)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12.0),
                ),
                margin: const EdgeInsets.symmetric(horizontal: 10),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    if (isExpanded)
                      Flexible(
                        child: Padding(
                          padding: const EdgeInsets.only(
                            top: 20,
                          ),
                          child: Text(
                            S.of(context).yourBookingDetail,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                      ),
                    if (isExpanded)
                      Flexible(
                          child: widget.booking!.adults['adults'] != null
                              ? Text(
                                  '${S.of(context).adults}: ${widget.booking!.adults['adults']}',
                                  style: Theme.of(context).textTheme.titleLarge,
                                )
                              : Text(
                                  '${S.of(context).tickets}: ${widget.booking!.adults['tickets']}',
                                  style: Theme.of(context).textTheme.titleLarge,
                                )),
                    Flexible(
                        child: Text(
                      '${S.of(context).additionalServices}:',
                      style: Theme.of(context).textTheme.titleLarge,
                    )),
                    if (isExpanded)
                      if (widget.booking!.services.isEmpty)
                        Flexible(
                          child: Container(
                            margin: const EdgeInsets.all(5.0),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .secondary
                                  .withOpacity(0.2),
                              borderRadius: BorderRadius.circular(6.0),
                            ),
                            child: Center(
                              child: Text(
                                S.of(context).none.toString().toUpperCase(),
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ),
                          ),
                        ),

                    if (isExpanded)
                      if (widget.booking!.services.isNotEmpty)
                        Expanded(
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (context, index) => Container(
                              margin: const EdgeInsets.all(5.0),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: kColorRed,
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: Center(
                                child: Text(
                                  widget.booking!.services[index]!,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.w300,
                                      fontFamily: 'Roboto',
                                      color: Colors.white),
                                ),
                              ),
                            ),
                            itemCount: widget.booking!.services.length,
                          ),
                        ),
//                      Flexible(
//                          child: Text(
//                              'Services: ${widget.booking.bookingComment.services}')),
                    Icon(
                      isExpanded ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                      size: 44,
                      color: Theme.of(context).primaryColor,
                    )
                  ],
                )),
          ),
          if (widget.booking!.status!.toLowerCase() == 'confirmed' &&
              widget.booking!.orderStatus?.toLowerCase() == 'pending')
            InkWell(
              onTap: () => Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) {
                final user =
                    Provider.of<UserModel>(context, listen: false).user;
                return ChangeNotifierProvider<BookingPaymentModel>(
                    create: (_) => BookingPaymentModel(
                        user: user,
                        booking: widget.booking,
                        langCode: langCode),
                    child: BookingPaymentScreen(
                      callback: () => bookingHistoryModel.loadBooking(user!.id),
                    ));
              })),
              child: Container(
                height: 55,
                margin: const EdgeInsets.symmetric(
                  vertical: 15.0,
                  horizontal: 10.0,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Center(
                  child: Text(
                    S.of(context).payNow,
                    style: Theme.of(context)
                        .textTheme
                        .labelLarge!
                        .copyWith(
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        )
                        .apply(fontSizeFactor: 1.2),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
