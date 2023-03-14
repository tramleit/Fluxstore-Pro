import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:quiver/strings.dart';

import '../../../common/config.dart';
import '../../../common/constants.dart';
import '../../../common/tools.dart';
import '../../../generated/l10n.dart';
import '../../../models/entities/index.dart';
import '../../../models/user_model.dart';
import '../../../widgets/common/start_rating.dart';
import 'booking/booking.dart';
import 'product_categories.dart';

class ProductTitle extends StatelessWidget {
  final Product? product;

  const ProductTitle({this.product});

  void _bookNow(context) {
    final user = Provider.of<UserModel>(context, listen: false).user;
    if (user == null) {
      Navigator.of(context).pushNamed(RouteList.login);
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BookingScreen(
            product: product,
          ),
        ),
      );
    }
  }

  List<Widget> getPricing(context) {
    final theme = Theme.of(context);
    return [
      if ((product!.price != null && product!.regularPrice == null) ||
          (product!.price == null && product!.regularPrice != null))
        Row(
          children: <Widget>[
            Text(
                PriceTools.getCurrencyFormatted(
                    product!.price ?? product!.regularPrice ?? '0', null)!,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ))
          ],
        ),
      if (product!.price != null && product!.regularPrice != null)
        Row(
          children: <Widget>[
            Text(PriceTools.getCurrencyFormatted(product!.regularPrice, null)!,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                )),
            const Text(' - ',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                )),
            Text(PriceTools.getCurrencyFormatted(product!.price, null)!,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ))
          ],
        ),
      const SizedBox(height: 2),
      if (product!.averageRating != null && product!.averageRating != 0.0)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              SmoothStarRating(
                allowHalfRating: true,
                starCount: 5,
                rating: product!.averageRating ?? 0.0,
                size: 14.0,
                color: theme.primaryColor,
                borderColor: theme.primaryColor,
                spacing: 0.0,
                // label: Text(
                //   product!.ratingCount == 0 || product!.ratingCount == null
                //       ? ''
                //       : '${product!.ratingCount}',
                //   style: Theme.of(context).textTheme.caption!.apply(
                //       fontSizeFactor: 0.9,
                //       color: Colors.white.withOpacity(0.7)),
                // ),
              ),
              const SizedBox(width: 2),
              if (product!.totalReview != 0)
                Text(
                  ' (${product!.totalReview}) ',
                  style: TextStyle(
                      fontSize: 14, color: Colors.white.withOpacity(0.8)),
                ),
            ],
          ),
        ),
    ];
  }

  Widget getPricingButton(context) {
    return Container(
      color: Colors.white.withOpacity(0.1),
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.only(top: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: getPricing(context)),
          TextButton(
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 15),
              backgroundColor: Colors.redAccent,
            ),
            onPressed: () => _bookNow(context),
            child: Text(
              S.of(context).bookingNow,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var list = <Widget>[];
    var supportBooking = product?.listingBookingStatus ?? false;

    if (isNotBlank(product!.location)) {
      list.add(InfoItem(
        icon: Icons.location_on,
        title: product!.location,
      ));
    }
    if (isNotBlank(product!.phone)) {
      list.add(InfoItem(
        icon: Icons.phone,
        title: product!.phone,
        onTap: () async {
          await Tools.launchURL('tel:${product!.phone!}');
        },
      ));
    }
    if (isNotBlank(product!.email)) {
      list.add(InfoItem(
        icon: Icons.email,
        title: product!.email,
        onTap: () async {
          await Tools.launchURL('mailto:${product!.email!}');
        },
      ));
    }
    if (isNotBlank(product!.website)) {
      list.add(InfoItem(
        icon: Icons.language,
        title: product!.website,
        onTap: () async {
          await Tools.launchURL(product!.website);
        },
      ));
    }

    list.add(Wrap(
      children: <Widget>[
        if (isNotBlank(product!.whatsapp))
          SocialItem(
            color: Colors.green,
            title: 'WhatsApp',
            icon: 'assets/icons/brands/whatsapp.svg',
            onTap: () async {
              await Tools.launchURL(product!.whatsapp?.contains('http') ?? false
                  ? product!.whatsapp
                  : 'https://wa.me/${product!.whatsapp}');
            },
          ),
        if (isNotBlank(product!.skype))
          SocialItem(
            color: Colors.blueAccent,
            title: 'Skype',
            icon: 'assets/icons/brands/skype.svg',
            onTap: () async {
              await Tools.launchURL('skype:${product!.skype}?chat');
            },
          ),
        if (isNotBlank(product!.facebook))
          SocialItem(
            color: Colors.blue,
            title: 'Facebook',
            icon: 'assets/icons/brands/facebook.svg',
            onTap: () async {
              await Tools.launchURL(product!.facebook);
            },
          ),
        if (isNotBlank(product!.youtube))
          SocialItem(
            color: Colors.red,
            title: 'YouTube',
            icon: 'assets/icons/brands/youtube.svg',
            onTap: () async {
              await Tools.launchURL(product!.youtube);
            },
          ),
        if (isNotBlank(product!.twitter))
          SocialItem(
            color: Colors.blueAccent,
            title: 'Twitter',
            icon: 'assets/icons/brands/twitter.svg',
            onTap: () async {
              await Tools.launchURL(product!.twitter);
            },
          ),
        if (isNotBlank(product!.instagram))
          SocialItem(
            color: Colors.redAccent,
            title: 'Instagram',
            icon: 'assets/icons/brands/instagram.svg',
            onTap: () async {
              await Tools.launchURL(product!.instagram);
            },
          ),
      ],
    ));

    return Container(
      color: Colors.black,
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
//          SizedBox(height: 10),
//          Text(product.categoryName.toUpperCase(),
//              style: TextStyle(
//                fontSize: 12,
//                color: Colors.white.withOpacity(0.7),
//                letterSpacing: 2,
//                fontWeight: FontWeight.w600,
//              )),
          const SizedBox(height: 5),
          ProductCategories(
              product: product, type: DataMapping().kTaxonomies['category']),
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Text(
                  product!.name!,
                  style: TextStyle(
                    fontSize: 30,
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.clip,
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              product!.verified!
                  ? Icon(
                      Icons.verified_user,
                      color: Theme.of(context).primaryColor,
                    )
                  : Container()
            ],
          ),
          const SizedBox(height: 10),
          if (supportBooking) getPricingButton(context),
          if (!supportBooking) ...getPricing(context),
          const SizedBox(height: 5),

          if (list.isNotEmpty)
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: list,
              ),
            ),
        ],
      ),
    );
  }
}

class InfoItem extends StatelessWidget {
  final String? title;
  final IconData? icon;
  final VoidCallback? onTap;

  const InfoItem({this.title, this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Icon(
              icon,
              size: 16,
              color: Colors.white70,
            ),
            const SizedBox(
              width: 15.0,
            ),
            Expanded(
                child: Text(
              title!,
              style: TextStyle(
                fontSize: 15,
                color: Colors.white.withOpacity(0.9),
              ),
            )),
          ],
        ),
      ),
    );
  }
}

class SocialItem extends StatelessWidget {
  final Color? color;
  final String? icon;
  final String? title;
  final VoidCallback? onTap;

  const SocialItem({this.color, this.title, this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(top: 10, right: 5),
        padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 8),
        decoration:
            BoxDecoration(color: color, borderRadius: BorderRadius.circular(5)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SvgPicture.asset(
              icon ?? '',
              width: 15.0,
              height: 15.0,
              color: Colors.white,
            ),
            const SizedBox(
              width: 5,
            ),
            Text(
              title!,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            )
          ],
        ),
      ),
    );
  }
}
