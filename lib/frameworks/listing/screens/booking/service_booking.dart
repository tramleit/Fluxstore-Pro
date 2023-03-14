import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../common/constants.dart';
import '../../../../common/tools.dart';
import '../../../../generated/l10n.dart';
import '../../../../models/entities/index.dart';
import 'listing_booking_model.dart';
import 'thumbnail.dart';

class ServiceBooking extends StatelessWidget {
  final Product? product;
  final User? user;
  final GlobalKey<ScaffoldMessengerState>? scaffoldMessenger;

  const ServiceBooking({this.product, this.user, this.scaffoldMessenger});

  int getListeoTimeSlotDate(DateTime date) {
    return date.weekday - 1;
  }

  Widget renderTimeSlots(BuildContext context, ListingBookingModel model) {
    var weekday = getListeoTimeSlotDate(model.date);

    if (product!.slots == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          InkWell(
            onTap: () => setTime(context, model),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColorLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.access_time,
                    size: 18,
                    color: Theme.of(context)
                        .colorScheme
                        .secondary
                        .withOpacity(0.5),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Text(
                    model.time.format(context),
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ],
              ),
            ),
          )
        ],
      );
    }
    if (product!.slots!.timeSlots[weekday].isEmpty) {
      return Container(
        padding: const EdgeInsets.all(5.0),
        margin: const EdgeInsets.all(5.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.red, width: 1),
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Text(
          S.of(context).noSlotAvailable,
        ),
      );
    }
    return Wrap(
      children: List.generate(
        product!.slots!.timeSlots[weekday].length,
        (index) => InkWell(
          onTap: () {
            model.updateListTimeSlot(
                product!.slots!.timeSlots[weekday][index], weekday, index);
          },
          child: Container(
            padding: const EdgeInsets.all(5.0),
            margin: const EdgeInsets.all(5.0),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.red, width: 1),
              borderRadius: BorderRadius.circular(10.0),
              color: model.listTimeSlot
                      .contains(product!.slots!.timeSlots[weekday][index])
                  ? kColorRed
                  : null,
            ),
            child: Text(
              product!.slots!.timeSlots[weekday][index],
              style: TextStyle(
                  color: model.listTimeSlot
                          .contains(product!.slots!.timeSlots[weekday][index])
                      ? Colors.white
                      : null),
            ),
          ),
        ),
      ),
    );
  }

  Widget renderServices(BuildContext context, ListingBookingModel model) {
    if (product!.listingMenu!.isEmpty) {
      return const SizedBox();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: List.generate(
        product!.listingMenu!.length,
        (i) => product!.listingMenu![i].menu.isNotEmpty
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (product!.listingMenu![i].title.isNotEmpty)
                    Text(product!.listingMenu![i].title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        )),
                  Wrap(
                    children: List.generate(
                      product!.listingMenu![i].menu.length,
                      (index) => InkWell(
                        onTap: () => model.updateListServices(
                            product!.listingMenu![i].menu[index].name),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 6),
                          margin: const EdgeInsets.only(right: 10.0, top: 10.0),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: kColorRed,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(10.0),
                            color: model.listServices.contains(
                                    product!.listingMenu![i].menu[index].name)
                                ? kColorRed
                                : null,
                          ),
                          child: Text(
                            product!.listingMenu![i].menu[index].name,
                            style: TextStyle(
                                color: model.listServices.contains(product!
                                        .listingMenu![i].menu[index].name)
                                    ? Colors.white
                                    : null),
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

  Future<void> setDate(BuildContext context, ListingBookingModel model) async {
    final picked = await showDatePicker(
        context: context,
        initialDate: model.date,
        firstDate: DateTime(2019, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != model.date) {
      await model.setDate(picked);
    }
  }

  Future<void> setTime(BuildContext context, ListingBookingModel model) async {
    final picked =
        await showTimePicker(context: context, initialTime: model.time);
    if (picked != null && picked != model.time) {
      await model.setTime(picked);
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
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColorLight,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(9),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const SizedBox(
                    height: 5,
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(S.of(context).date,
                            style: const TextStyle(
                                fontSize: 16, fontFamily: 'Roboto')),
                      ),
                      SizedBox(
                        width: 100,
                        child: Text(DateFormat('yyyy-MM-dd').format(model.date),
                            style: const TextStyle(
                                fontSize: 16, fontFamily: 'Roboto')),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(S.of(context).hour,
                            style: const TextStyle(
                                fontSize: 16, fontFamily: 'Roboto')),
                      ),
                      SizedBox(
                        width: 100,
                        child: Text(model.time.format(context),
                            style: const TextStyle(
                                fontSize: 16, fontFamily: 'Roboto')),
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
                            style: const TextStyle(
                                fontSize: 16, fontFamily: 'Roboto')),
                      ),
                      SizedBox(
                        width: 100,
                        child: Text('${model.adults}',
                            style: const TextStyle(
                                fontSize: 16, fontFamily: 'Roboto')),
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
                            style: const TextStyle(
                                fontSize: 20, fontFamily: 'Roboto')),
                      ),
                      SizedBox(
                        width: 100,
                        child: Text(
                            PriceTools.getCurrencyFormatted(
                                model.price.toString(), null)!,
                            style: const TextStyle(
                                fontSize: 20, fontFamily: 'Roboto')),
                      )
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Text(
              S.of(context).pickADate,
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 10),
            InkWell(
              onTap: () => setDate(context, model),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                decoration: BoxDecoration(
                    color: Theme.of(context).primaryColorLight,
                    borderRadius: BorderRadius.circular(10)),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 18,
                      color: Theme.of(context)
                          .colorScheme
                          .secondary
                          .withOpacity(0.7),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Center(
                      child: Text(
                        DateFormat('yyyy-MM-dd').format(model.date),
                        style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            renderTimeSlots(context, model),
            const SizedBox(height: 30),
            if (product!.listingMenu!.isNotEmpty)
              Text(
                S.of(context).extraServices,
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            if (product!.listingMenu!.isNotEmpty) const SizedBox(height: 5),
            if (product!.listingMenu!.isNotEmpty)
              renderServices(context, model),
            if (product!.listingMenu!.isNotEmpty) const SizedBox(height: 30),
            Text(
              S.of(context).guests,
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColorLight,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  IconButton(
                    icon: Icon(
                      Icons.remove_circle,
                      size: 25,
                      color: Theme.of(context).primaryColor,
                    ),
                    onPressed: () => model.setGuest(false),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  Text(
                    '${model.adults}',
                    style: const TextStyle(fontSize: 20, fontFamily: 'Roboto'),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.add_circle_rounded,
                      size: 25,
                      color: Theme.of(context).primaryColor,
                    ),
                    onPressed: () => model.setGuest(true),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
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
            const SizedBox(height: 40)
          ],
        ),
      ),
    );
  }
}

Widget ticketDetailsWidget(String firstTitle, String firstDesc,
    String secondTitle, String secondDesc) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: <Widget>[
      Padding(
        padding: const EdgeInsets.only(left: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              firstTitle,
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                firstDesc,
                style: const TextStyle(
                  color: Colors.black,
                ),
              ),
            )
          ],
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(right: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              secondTitle,
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                secondDesc,
                style: const TextStyle(
                  color: Colors.black,
                ),
              ),
            )
          ],
        ),
      )
    ],
  );
}
