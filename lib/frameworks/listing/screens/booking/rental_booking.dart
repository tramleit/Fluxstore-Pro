import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../common/constants.dart';
import '../../../../common/tools.dart';
import '../../../../generated/l10n.dart';
import '../../../../models/entities/index.dart' show Product, User;
import 'listing_booking_model.dart';
import 'thumbnail.dart';

class RentalBooking extends StatelessWidget {
  final Product? product;
  final User? user;
  final GlobalKey<ScaffoldMessengerState>? scaffoldMessenger;

  const RentalBooking({
    this.product,
    this.user,
    this.scaffoldMessenger,
  });

  Widget renderServices(ListingBookingModel model) {
    if (product!.listingMenu!.isEmpty) {
      return const SizedBox();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: List.generate(
        product!.listingMenu!.length,
        (i) => product!.listingMenu![i].menu.isNotEmpty
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (product!.listingMenu![i].title.isNotEmpty)
                    Text(
                      product!.listingMenu![i].title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                    ),
                  Wrap(
                    children: List.generate(
                      product!.listingMenu![i].menu.length,
                      (index) => InkWell(
                        onTap: () => model.updateListServices(
                            product!.listingMenu![i].menu[index].name),
                        child: Container(
                          padding: const EdgeInsets.all(5.0),
                          margin: const EdgeInsets.all(5.0),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.red, width: 1),
                            borderRadius: BorderRadius.circular(10.0),
                            color: model.listServices.contains(
                                    product!.listingMenu![i].menu[index].name)
                                ? kColorRed
                                : null,
                          ),
                          child: Text(
                            product!.listingMenu![i].menu[index].name,
                            style: TextStyle(
                              color: model.listServices.contains(
                                      product!.listingMenu![i].menu[index].name)
                                  ? Colors.white
                                  : Colors.black54,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : const SizedBox(),
      ),
    );
  }

  Future<void> setDateStart(
      BuildContext context, ListingBookingModel model) async {
    final picked = await showDatePicker(
        context: context,
        initialDate: model.dateStart,
        firstDate: DateTime.now(),
        lastDate: DateTime(2101));
    if (picked != null && picked != model.dateStart) {
      await model.setDateStart(picked);
    }
  }

  Future<void> setDateEnd(
      BuildContext context, ListingBookingModel model) async {
    final picked = await showDatePicker(
        context: context,
        initialDate: model.dateEnd,
        firstDate: model.dateStart,
        lastDate: DateTime(2101));
    if (picked != null && picked != model.dateEnd) {
      await model.setDateEnd(picked);
    }
  }

  void _showMessage(BuildContext context, BookStatus status,
      Availability availability) async {
    var message = '';
    if (availability == Availability.notEmpty) {
      message = S.of(context).thisDateIsNotAvailable;
      Tools.showSnackBar(scaffoldMessenger?.currentState, message);
      return;
    } else if (availability == Availability.error) {
      message = S.of(context).bookingError;
      Tools.showSnackBar(scaffoldMessenger?.currentState, message);
      return;
    } else {
      switch (status) {
        case BookStatus.booked:
          message = S.of(context).booked;
          break;
        case BookStatus.waiting:
          message = S.of(context).waitingForConfirmation;
          break;
        case BookStatus.confirmed:
          message = S.of(context).bookingConfirm;
          break;
        case BookStatus.cancelled:
          message = S.of(context).bookingCancelled;
          break;
        case BookStatus.unavailable:
          message = S.of(context).bookingUnavailable;
          break;
        default:
          message = S.of(context).bookingError;
          break;
      }

      if (status == BookStatus.error ||
          status == BookStatus.booked ||
          status == BookStatus.unavailable) {
        Tools.showSnackBar(scaffoldMessenger?.currentState, message);
        return;
      }

      await showDialog(
          context: context,
          builder: (subContext) {
            return AlertDialog(
              title: Text(message),
              actions: <Widget>[
                GestureDetector(
                  onTap: () {
                    Navigator.pop(subContext);
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(5)),
                    child: Text(
                      S.of(context).ok,
                      style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                )
              ],
            );
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ListingBookingModel>(
      builder: (context, model, _) => SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Thumbnail(
              product: product,
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColorLight,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(6),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(S.of(context).dateStart,
                            style: const TextStyle(fontSize: 14)),
                      ),
                      SizedBox(
                        width: 100,
                        child: Text(
                            DateFormat('yyyy-MM-dd').format(model.dateStart),
                            style: const TextStyle(fontSize: 14)),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(S.of(context).dateEnd,
                            style: const TextStyle(fontSize: 15)),
                      ),
                      SizedBox(
                        width: 100,
                        child: Text(
                            DateFormat('yyyy-MM-dd').format(model.dateEnd),
                            style: const TextStyle(fontSize: 15)),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(S.of(context).guests,
                            style: const TextStyle(fontSize: 15)),
                      ),
                      SizedBox(
                        width: 100,
                        child: Text(model.adults.toString(),
                            style: const TextStyle(fontSize: 14)),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const Divider(
                    height: 1,
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(S.of(context).total,
                            style: const TextStyle(fontSize: 20)),
                      ),
                      SizedBox(
                        width: 100,
                        child: Text(
                            PriceTools.getCurrencyFormatted(
                                model.price.toString(), null)!,
                            style: const TextStyle(fontSize: 20)),
                      )
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              S.of(context).dateStart,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium!
                                  .copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black54,
                                  ),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            GestureDetector(
                              onTap: () => setDateStart(context, model),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                    color: Theme.of(context).primaryColorLight,
                                    border: Border.all(
                                        color: Theme.of(context).primaryColor,
                                        width: 1.0),
                                    borderRadius: BorderRadius.circular(3)),
                                child: Center(
                                  child: Text(
                                      DateFormat('yyyy-MM-dd')
                                          .format(model.dateStart),
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              S.of(context).dateEnd,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium!
                                  .copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black54,
                                  ),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            GestureDetector(
                              onTap: () => setDateEnd(context, model),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColorLight,
                                  border: Border.all(
                                      color: Theme.of(context).primaryColor,
                                      width: 1.0),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                                child: Center(
                                  child: Text(
                                      DateFormat('yyyy-MM-dd')
                                          .format(model.dateEnd),
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  if (product!.listingMenu!.isNotEmpty)
                    Text(
                      S.of(context).extraServices,
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                            fontWeight: FontWeight.w700,
                            color: Colors.black54,
                          ),
                    ),
                  if (product!.listingMenu!.isNotEmpty)
                    const SizedBox(
                      height: 10,
                    ),
                  if (product!.listingMenu!.isNotEmpty) renderServices(model),
                  if (product!.listingMenu!.isNotEmpty)
                    const SizedBox(
                      height: 10,
                    ),
                  Text(
                    S.of(context).guests,
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          fontWeight: FontWeight.w700,
                          color: Colors.black54,
                        ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                    color: Theme.of(context).primaryColorLight,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        GestureDetector(
                          onTap: () => model.setGuest(false),
                          child: const Icon(
                            Icons.remove_circle_outline,
                            size: 26,
                          ),
                        ),
                        const SizedBox(
                          width: 40,
                        ),
                        Text(
                          model.adults.toString(),
                          style: const TextStyle(fontSize: 20),
                        ),
                        const SizedBox(
                          width: 40,
                        ),
                        GestureDetector(
                          onTap: () => model.setGuest(true),
                          child: const Icon(
                            Icons.add_circle_outline,
                            size: 26,
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            Center(
              child: model.state == ListingBookingModelState.loading
                  ? SpinKitFadingCircle(
                      color: Theme.of(context).primaryColor,
                      size: 28.0,
                    )
                  : GestureDetector(
                      onTap: () async {
                        final status =
                            await model.requestBooking(user, context);
                        _showMessage(context, status, model.availability);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 15, horizontal: 30),
                        decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(3)),
                        child: Text(
                          S.of(context).requestBooking,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
            ),
            const SizedBox(
              height: 40,
            )
          ],
        ),
      ),
    );
  }
}
