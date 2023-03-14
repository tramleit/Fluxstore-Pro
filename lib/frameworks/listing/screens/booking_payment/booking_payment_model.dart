import 'package:flutter/cupertino.dart';

import '../../../../common/config.dart';
import '../../../../models/entities/index.dart';
import '../../../../services/index.dart';

enum BookingPaymentModelState { loading, loaded, paymentProcessing }

class BookingPaymentModel extends ChangeNotifier {
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final phoneNumberController = TextEditingController();
  final emailController = TextEditingController();
  final stateController = TextEditingController();
  final cityController = TextEditingController();
  final address1 = TextEditingController();
  final address2 = TextEditingController();
  final zipCodeController = TextEditingController();

  final _services = Services();

  List<PaymentMethod> lstPaymentMethod = [];
  User? user;
  ListingBooking? booking;
  int index = 0;
  var state = BookingPaymentModelState.loading;
  String? langCode;

  BookingPaymentModel({this.user, this.booking, required this.langCode}) {
    _setTextController();
    _getPaymentMethod(langCode);
  }

  void _updateState(state) {
    this.state = state;
    notifyListeners();
  }

  Future<void> _getPaymentMethod(String? langCode) async {
    _updateState(BookingPaymentModelState.loading);
    var list = await _services.api
        .getPaymentMethods(token: user!.cookie, langCode: langCode)!;
    for (var element in list) {
      if (element.id!.contains(kPaypalConfig['paymentMethodId']) &&
          kPaypalConfig['enabled'] == true) {
        lstPaymentMethod.add(element);
      }
      if (element.id!.contains(kRazorpayConfig['paymentMethodId']) &&
          kRazorpayConfig['enabled'] == true) {
        lstPaymentMethod.add(element);
      }
      if (element.id!.contains(kTapConfig['paymentMethodId']) &&
          kTapConfig['enabled'] == true) {
        lstPaymentMethod.add(element);
      }
      if (element.id!.contains(kStripeConfig['paymentMethodId']) &&
          kStripeConfig['enabled'] == true) {
        lstPaymentMethod.add(element);
      }
      if (element.id!.contains(kMyFatoorahConfig['paymentMethodId']) &&
          kMyFatoorahConfig['enabled'] == true) {
        lstPaymentMethod.add(element);
      }
      if (['bacs', 'cod'].contains(element.id!)) {
        lstPaymentMethod.add(element);
      }
    }
    _updateState(BookingPaymentModelState.loaded);
  }

  void updatePaymentMethodIndex(index) {
    this.index = index;
    _updateState(BookingPaymentModelState.loaded);
  }

  void _setTextController() {
    firstNameController.text = user!.firstName ?? '';
    lastNameController.text = user!.lastName ?? '';
    phoneNumberController.text = user!.billing?.phone ?? '';
    emailController.text = user!.email ?? '';
    stateController.text = user!.billing?.state ?? '';
    cityController.text = user!.billing?.city ?? '';
    address1.text = user!.billing?.address1 ?? '';
    address2.text = user!.billing?.address2 ?? '';
    zipCodeController.text = user!.billing?.postCode ?? '';
  }

  Future<Order?> updateBookingStatus(bool isPaid) async {
    _updateState(BookingPaymentModelState.paymentProcessing);
    final order = await _services.api.updateOrder(booking!.orderId,
        status: isPaid ? 'processing' : 'pending', token: null);
    _updateState(BookingPaymentModelState.loaded);
    return order;
  }
}
