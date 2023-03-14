import 'package:flutter/material.dart';

class PaymentMethodWidget extends StatelessWidget {
  final bool isSelect;
  final String? title;
  final Widget? image;

  const PaymentMethodWidget(
      {Key? key, required this.isSelect, this.image, required this.title})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 10.0,
        vertical: 10.0,
      ),
      decoration: BoxDecoration(
        color: isSelect
            ? Theme.of(context).primaryColor
            : Theme.of(context).colorScheme.secondary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(9.0),
      ),
      height: 110,
      width: MediaQuery.of(context).size.width,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (image != null) image!,
          if (image == null) ...[
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                title!,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium!
                    .copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      color: isSelect
                          ? Colors.white
                          : Theme.of(context).colorScheme.secondary,
                    )
                    .apply(fontSizeFactor: 1.5),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
