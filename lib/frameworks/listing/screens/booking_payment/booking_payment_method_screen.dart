import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../common/config.dart';
import '../../../../widgets/common/flux_image.dart';
import 'booking_payment_model.dart';
import 'widgets/payment_method_widget.dart';

class BookingPaymentMethodScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Consumer<BookingPaymentModel>(
      builder: (context, model, _) => Container(
        width: size.width,
        height: size.height,
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
              const SizedBox(height: 40.0),
              if (model.state == BookingPaymentModelState.loading)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 50.0),
                    child: kLoadingWidget(context),
                  ),
                ),
              if (model.state == BookingPaymentModelState.loaded ||
                  model.state == BookingPaymentModelState.paymentProcessing)
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: List.generate(
                      model.lstPaymentMethod.length,
                      (index) => InkWell(
                            onTap: () => model.updatePaymentMethodIndex(index),
                            borderRadius: BorderRadius.circular(12),
                            child: PaymentMethodWidget(
                              title: model.lstPaymentMethod[index].title,
                              image:
                                  kPayments[model.lstPaymentMethod[index].id] !=
                                          null
                                      ? FluxImage(
                                          imageUrl: kPayments[model
                                              .lstPaymentMethod[index].id]!,
                                          height: 30,
                                        )
                                      : null,
                              isSelect: model.index == index,
                            ),
                          )),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
