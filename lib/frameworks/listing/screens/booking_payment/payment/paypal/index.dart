import 'dart:core';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../../models/app_model.dart';
import '../../../../../../models/entities/index.dart';
import '../../../../../../modules/native_payment/paypal/index.dart';

class PaypalPayment2 extends PaypalPayment {
  final ListingBooking? booking;

  const PaypalPayment2({onFinish, this.booking}) : super(onFinish: onFinish);

  @override
  State<StatefulWidget> createState() {
    // ignore: no_logic_in_create_state
    return PaypalPaymentState2(booking);
  }
}

class PaypalPaymentState2 extends PaypalPaymentState {
  final ListingBooking? booking;

  PaypalPaymentState2(this.booking);

  @override
  Map<String, dynamic> getOrderParams() {
    final currency = Provider.of<AppModel>(context, listen: false).currency;
    var temp = <String, dynamic>{
      'intent': 'sale',
      'payer': {'payment_method': 'paypal'},
      'transactions': [
        {
          'amount': {
            'total': formatPrice(booking!.price),
            'currency': currency,
          },
          'description': 'The payment transaction description.',
          'payment_options': {
            'allowed_payment_method': 'INSTANT_FUNDING_SOURCE'
          },
          'item_list': {
            'items': [
              {
                'name': booking!.title,
                'quantity': 1,
                'price': formatPrice(booking!.price),
                'currency': currency
              }
            ],
          }
        }
      ],
      'note_to_payer': 'Contact us for any questions on your order.',
      'redirect_urls': {
        'return_url': 'http://return.example.com',
        'cancel_url': 'http://cancel.example.com'
      }
    };
    return temp;
  }
}
