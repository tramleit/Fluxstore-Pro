import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../common/config.dart';
import '../../../common/constants.dart';
import '../../../common/theme/colors.dart';
import '../../../common/tools.dart';
import '../../../generated/l10n.dart';
import '../../../models/index.dart';
import '../../../services/index.dart';
import '../../../widgets/common/start_rating.dart';
import '../../../widgets/html/index.dart';

class Reviews extends StatefulWidget {
  final int productId;

  const Reviews(this.productId);

  @override
  State<Reviews> createState() => _StateReviews();
}

class _StateReviews extends State<Reviews> {
  final services = Services();
  double rating = 0.0;
  final comment = TextEditingController();
  List<Review>? reviews;

  @override
  void initState() {
    super.initState();
    getListReviews();
  }

  @override
  void dispose() {
    comment.dispose();
    super.dispose();
  }

  void updateRating(double index) {
    if (mounted) {
      setState(() {
        rating = index;
      });
    }
  }

  void sendReview() {
    if (rating == 0.0) {
      Tools.showSnackBar(
          ScaffoldMessenger.of(context), S.of(context).ratingFirst);
      return;
    }
    if (comment.text.isEmpty) {
      Tools.showSnackBar(
          ScaffoldMessenger.of(context), S.of(context).commentFirst);
      return;
    }
    final user = Provider.of<UserModel>(context, listen: false);

    if (ServerConfig().typeName != 'listpro') {
      Tools.showSnackBar(ScaffoldMessenger.of(context),
          'Your feedback has been submitted and is under review!');
    } else {
      Tools.showSnackBar(ScaffoldMessenger.of(context), 'Review submitted!');
    }
    services.api
        .createReview(
            productId: widget.productId.toString(),
            data: {
              'post_content': comment.text,
              'post_title': comment.text,
              'post_author': user.user!.id,
              'name': '${user.user!.firstName} ${user.user!.lastName}',
              'email': user.user!.email,
              'rating': rating.toInt()
            },
            token: user.user!.cookie)!
        .then((onValue) {
      if (mounted) {
        setState(getListReviews);
      }
    });
    setState(() {
      rating = 0.0;
      comment.text = '';
    });
  }

  void getListReviews() {
    services.api.getReviews(widget.productId)!.then((onValue) {
      if (mounted) {
        setState(() {
          reviews = onValue.data;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserModel>(context, listen: false);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          (user.user != null)
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      S.of(context).productRating.toUpperCase(),
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context)
                              .colorScheme
                              .secondary
                              .withOpacity(0.5)),
                    ),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 15),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColorLight,
                          borderRadius: BorderRadius.circular(40),
                        ),
                        child: SmoothStarRating(
                          allowHalfRating: false,
                          onRatingChanged: updateRating,
                          starCount: 5,
                          rating: rating,
                          size: 25.0,
                          color: Theme.of(context).primaryColor,
                          borderColor: Theme.of(context).primaryColor,
                          spacing: 10.0,
                          label: Container(),
                        ),
                      ),
                    ),
                  ],
                )
              : Container(),
          if (user.user != null)
            Container(
              margin: const EdgeInsets.only(bottom: 30),
              padding: const EdgeInsets.only(left: 5.0, bottom: 5.0, top: 5.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      keyboardType: TextInputType.multiline,
                      controller: comment,
                      maxLines: null,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.send,
                      color: Theme.of(context).primaryColor,
                    ),
                    onPressed: sendReview,
                  )
                ],
              ),
            ),
          reviews == null
              ? kLoadingWidget(context)
              : (reviews!.isEmpty
                  ? SizedBox(
                      height: 30,
                      child: Center(
                        child: Text(S.of(context).noReviews),
                      ),
                    )
                  : Column(
                      children: <Widget>[
                        for (var i = 0; i < reviews!.length; i++)
                          renderItem(context, reviews![i])
                      ],
                    )),
        ],
      ),
    );
  }

  Widget renderItem(context, Review review) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const SizedBox(height: 5),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Text(review.name!.toUpperCase(),
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.bold)),
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColorLight,
                borderRadius: BorderRadius.circular(20),
              ),
              child: SmoothStarRating(
                allowHalfRating: true,
                starCount: 5,
                rating: review.rating,
                size: 12.0,
                color: theme.primaryColor,
                borderColor: theme.primaryColor,
                spacing: 0.0,
                label: Container(),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(left: 10.0),
          child: Text(timeago.format(review.createdAt),
              style: const TextStyle(color: kGrey400, fontSize: 10)),
        ),
        const SizedBox(height: 5),
        Padding(
          padding: const EdgeInsets.only(left: 10.0),
          child: HtmlWidget(
            review.review ?? '',
            textStyle: const TextStyle(color: kGrey600, fontSize: 14),
          ),
        ),
        const SizedBox(height: 5),
        const Divider(),
      ],
    );
  }
}
