import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../generated/l10n.dart';
import 'booking_payment_model.dart';
import 'widgets/information_text_widget.dart';

class BookingAddressScreen extends StatelessWidget {
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
              Row(
                children: [
                  Expanded(
                    child: InformationTextWidget(
                      controller: model.firstNameController,
                      title: S.of(context).firstName,
                    ),
                  ),
                  const SizedBox(
                    width: 10.0,
                  ),
                  Expanded(
                    child: InformationTextWidget(
                      controller: model.lastNameController,
                      title: S.of(context).lastName,
                    ),
                  ),
                ],
              ),
              InformationTextWidget(
                controller: model.phoneNumberController,
                title: S.of(context).phone,
              ),
              InformationTextWidget(
                controller: model.emailController,
                title: S.of(context).email,
              ),
              InformationTextWidget(
                controller: model.address1,
                title: '${S.of(context).address} 1',
              ),
              InformationTextWidget(
                controller: model.address2,
                title: '${S.of(context).address} 2',
              ),
              Row(
                children: [
                  Expanded(
                    child: InformationTextWidget(
                      controller: model.stateController,
                      title: S.of(context).stateProvince,
                    ),
                  ),
                  const SizedBox(
                    width: 10.0,
                  ),
                  Expanded(
                    child: InformationTextWidget(
                      controller: model.cityController,
                      title: S.of(context).city,
                    ),
                  ),
                ],
              ),
              InformationTextWidget(
                controller: model.zipCodeController,
                title: S.of(context).zipCode,
              ),
              const SizedBox(
                height: 60.0,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
