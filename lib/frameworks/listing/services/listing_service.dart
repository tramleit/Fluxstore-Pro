import 'dart:async';
import 'dart:convert' as convert;
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:quiver/strings.dart';

import '../../../common/config.dart';
import '../../../common/constants.dart';
import '../../../common/tools.dart';
import '../../../models/entities/listing_location.dart';
import '../../../models/entities/prediction.dart';
import '../../../models/index.dart';
import '../../../services/base_services.dart';
import '../../../services/https.dart';
import '../../../services/service_config.dart';
import '../../woocommerce/services/woo_commerce.dart';
import '../mapping/mapping.dart';
import 'listing_api.dart';

class ListingService extends WooCommerceService {
  ListingService({
    required String domain,
    String? blogDomain,
    required String type,
  })  : listingAPI = ListingAPI(
          url: domain,
        ),
        super(
          domain: domain,
          blogDomain: blogDomain,
          consumerSecret: '',
          consumerKey: '',
        ) {
    Mapping.init(type);
  }

  final ListingAPI listingAPI;

  List<Category>? cats;
  List<Map<String, dynamic>>? productOptions;
  List<Map<String, dynamic>>? productOptionValues;
  String? idLang;

  @override
  Future<User?> createUser({
    String? firstName,
    String? lastName,
    String? username,
    String? password,
    String? phoneNumber,
    bool isVendor = false,
  }) async {
    try {
      var niceName = '${firstName!} ${lastName!}';
      var data = {
        'user_email': username,
        'user_login': username,
        'username': username,
        'user_pass': password,
        'email': username,
        'user_nicename': niceName,
        'display_name': niceName,
        'first_name': firstName,
        'last_name': lastName,
      };
      if (isVendor && ServerConfig().isListeoType) {
        data['role'] = 'owner';
      }
      final response = await httpPost(
          '$domain/wp-json/api/flutter_user/register/?insecure=cool&'.toUri()!,
          body: convert.jsonEncode(data));
      var body = convert.jsonDecode(response.body);
      if (response.statusCode == 200 && body['message'] == null) {
        var cookie = body['cookie'];
        return await getUserInfo(cookie);
      } else {
        var message = body['message'];
        throw Exception(message ?? 'Can not create the user.');
      }
    } catch (err) {
      //This error exception is about your Rest API is not config correctly so that not return the correct JSON format, please double check the document from this link https://docs.inspireui.com/fluxstore/woocommerce-setup/
      rethrow;
    }
  }

  @override
  Future<List<Product>?> fetchProductsByCategory(
      {categoryId,
      tagId,
      page,
      minPrice,
      maxPrice,
      orderBy,
      lang,
      order,
      featured,
      onSale,
      attribute,
      attributeTerm,
      listingLocation,
      userId,
      String? include,
      String? search,
      nextCursor}) async {
    var list = <Product>[];
    var endPoint =
        '$domain/wp-json/wp/v2/${DataMapping().kProductPath}?_embed=true&per_page=$apiPageSize&page=$page';
    if (kAdvanceConfig.isMultiLanguages) {
      endPoint += '&lang=$lang';
    }
    if (listingLocation != null) {
      endPoint += '&${DataMapping().kLocationPath}=$listingLocation';
    }
    if (categoryId != null && int.parse(categoryId) > -1) {
      endPoint += '&${DataMapping().kCategoryPath}=$categoryId';
    }
    if (orderBy != null) {
      endPoint += '&orderby=$orderBy';
    }
    if (order != null) {
      endPoint += '&order=$order';
    }
    if (search != null) {
      endPoint += '&search=$search';
    }
    printLog(endPoint);

    var response = await httpGet(endPoint.toUri()!);

    if (response.statusCode == 200) {
      for (var item in convert.jsonDecode(response.body)) {
        try {
          var product = Product.fromListingJson(item);
          list.add(product);
        } catch (e) {
          continue;
        }
      }
    }
    return list;
  }

  @override
  Future<List<Product>?> fetchProductsLayout(
      {config, lang, userId, bool refreshCache = false}) async {
    try {
      var list = <Product>[];

      var endPoint =
          '$domain/wp-json/wp/v2/${DataMapping().kProductPath}?page=${config['page'] ?? 1}&per_page=${config['limit'] ?? 10}';
      if (kAdvanceConfig.isMultiLanguages) {
        endPoint += '&lang=$lang';
      }
      if (config.containsKey('category') &&
          config['category'] != null &&
          config['category'].isNotEmpty) {
        endPoint += '&${DataMapping().kCategoryPath}=${config["category"]}';
      }
      if (config.containsKey('location') &&
          config['location'] != null &&
          config['location'].isNotEmpty) {
        endPoint += "&${DataMapping().kLocationPath}=${config['location']}";
      }

      var response = await httpCache(
        endPoint.toUri()!,
        refreshCache: refreshCache,
      );

      printLog(endPoint);
      if (response.statusCode == 200) {
        for (var item in convert.jsonDecode(response.body)) {
          var product = Product.fromListingJson(item);
          list.add(product);
        }
      }

      return list;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<Category>> getCategoriesByPage(
      {lang,
      page,
      limit,
      storeId,
      String? searchTerm,
      int? parent,
      bool useCompute = true}) async {
    try {
      var endpoint =
          '$domain/wp-json/wp/v2/${DataMapping().kCategoryPath}?hide_empty=${kAdvanceConfig.hideEmptyCategories}&_embed&per_page=$limit&page=$page';
      if (lang != null && kAdvanceConfig.isMultiLanguages) {
        endpoint += '&lang=$lang';
      }
      var response = await httpGet(endpoint.toUri()!);
      final body = convert.jsonDecode(response.body);
      if (body is Map && body['message'] != null) {
        throw Exception(body['message']);
      } else {
        var list = <Category>[];
        for (var item in body) {
          list.add(Category.fromListingJson(item));
        }
        return list;
      }
    } catch (e) {
      printLog('getCategories: $e');
      return [];
    }
  }

  @override
  Future<List<Category>> getCategories({lang}) async {
    try {
      var list = <Category>[];
      var isEnd = false;
      var page = 1;
      var limit = 100;

      while (!isEnd) {
        var categories =
            await getCategoriesByPage(lang: lang, page: page, limit: limit);
        if (categories.isEmpty || categories.length < limit - 1) {
          isEnd = true;
        }
        page = page + 1;
        list = [...list, ...categories];
      }
      return list;
    } catch (e) {
      printLog('getCategories: $e');
      return [];
    }
  }

  @override
  Future<List<PaymentMethod>> getPaymentMethods(
      {CartModel? cartModel,
      ShippingMethod? shippingMethod,
      String? token,
      String? langCode}) async {
    try {
      var endpoint = '$domain/wp-json/wp/v2/payment';

      if (token != null) {
        endpoint += '?cookie=$token';
      }
      var list = <PaymentMethod>[];
      final response = await httpGet(
        endpoint.toUri()!,
      );
      final body = convert.jsonDecode(response.body);
      if (response.statusCode == 200) {
        for (var item in body) {
          list.add(PaymentMethod.fromJson(item));
        }
      }
      if (list.isEmpty) {
        throw Exception('No payment methods');
      }
      return list;
    } catch (err) {
      rethrow;
    }
  }

  @override
  Future<List<Product>> getProducts({userId}) {
    throw UnimplementedError();
  }

  @override
  Future<List<ShippingMethod>> getShippingMethods(
      {CartModel? cartModel,
      String? token,
      String? checkoutId,
      Store? store,
      String? langCode}) {
    throw UnimplementedError();
  }

  @override
  Future<PagingResponse<Review>> getReviews(productId,
      {int page = 1, int perPage = 10}) async {
    try {
      var list = <Review>[];

      ///get reviews for my listing/listeo
      if (DataMapping().kListingReviewMapping['review'] == 'getReviews') {
        final response = await httpGet(
          '$domain/wp-json/wp/v2/${DataMapping().kListingReviewMapping['review']}/$productId?per_page=100'
              .toUri()!,
        );
        if (response.statusCode == 200) {
          for (Map<String, dynamic> item in convert.jsonDecode(response.body)) {
            try {
              var review = Review.fromListing(item);
              if (review.status == 'approved') {
                list.add(review);
              }
            } catch (e) {
              printLog('Error converting review Listing $e');
            }
          }
        }
        return PagingResponse(data: list);
      }

      ///get reviews for listingpro
      final response = await httpGet(
        '$domain/wp-json/wp/v2/${DataMapping().kListingReviewMapping['review']}?per_page=100'
            .toUri()!,
      );
      if (response.statusCode == 200) {
        for (Map<String, dynamic> item in convert.jsonDecode(response.body)) {
          try {
            var listingId = Tools.getValueByKey(
                item, DataMapping().kListingReviewMapping['item']);
            if (listingId.toString() == (productId.toString())) {
              list.add(Review.fromListing(item));
            }
          } catch (e) {
            printLog('Error converting review Listing $e');
          }
        }
      }
      return PagingResponse(data: list);
    } catch (e) {
      //This error exception is about your Rest API is not config correctly so that not return the correct JSON format, please double check the document from this link https://docs.inspireui.com/fluxstore/woocommerce-setup/
      rethrow;
    }
  }

  @override
  Future<PagingResponse<Product>> searchProducts(
      {name,
      categoryId,
      categoryName,
      tag,
      attribute,
      attributeId,
      page,
      lang,
      listingLocation,
      userId}) async {
    try {
      var list = <Product>[];

      var endPoint =
          '$domain/wp-json/wp/v2/${DataMapping().kProductPath}?search=$name&page=$page&per_page=$apiPageSize';

      if ((lang?.isNotEmpty ?? false) && kAdvanceConfig.isMultiLanguages) {
        endPoint += '&lang=$lang';
      }

      if (categoryId != null && categoryId.isNotEmpty) {
        endPoint += '&${DataMapping().kCategoryPath}=$categoryId';
      }

      if (listingLocation != null && listingLocation.isNotEmpty) {
        endPoint += '&${DataMapping().kLocationPath}=$listingLocation';
      }
      printLog(endPoint);

      var response = await httpGet(endPoint.toUri()!);

      for (var item in convert.jsonDecode(response.body)) {
        try {
          var product = Product.fromListingJson(item);
          list.add(product);
        } catch (e) {
          continue;
        }
      }
      return PagingResponse(data: list);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future createReview(
      {String? productId, Map<String, dynamic>? data, String? token}) async {
    try {
      if (ServerConfig().isListProType) {
        await httpPost('$domain/wp-json/wp/v2/submitReview'.toUri()!, body: {
          'listing_id': productId.toString(),
          'post_content': data!['post_content'],
          'post_author': data['post_author'].toString(),
          'post_title': data['post_title'],
          'rating': data['rating'].toString(),
        });
      }
      if (ServerConfig().isListeoType) {
        var request = http.MultipartRequest(
            'POST', Uri.parse('$domain/wp-comments-post.php'));
        request.fields['comment_post_ID'] = productId.toString();
        request.fields['comment'] = data!['post_content'];
        request.fields['submit'] = 'Post Comment';
        request.fields['comment_parent'] = '0';
        request.fields['value-for-money'] = data['rating'].toString();
        request.fields['service'] = data['rating'].toString();
        request.fields['location'] = data['rating'].toString();
        request.fields['cleanliness'] = data['rating'].toString();
        request.fields['email'] = data['email'].toString();
        request.fields['author'] = data['name'].toString();
        await request.send();
      }
      if (ServerConfig().isMyListingType) {
        var request = http.MultipartRequest(
            'POST', Uri.parse('$domain/wp-comments-post.php'));
        request.fields['comment_post_ID'] = productId.toString();
        request.fields['comment'] = data!['post_content'];
        request.fields['submit'] = 'Post Comment';
        request.fields['comment_parent'] = '0';
        request.fields['rating_star_rating'] = (data['rating'] * 2).toString();
        request.fields['hospitality_star_rating'] =
            (data['rating'] * 2).toString();
        request.fields['service_star_rating'] = (data['rating'] * 2).toString();
        request.fields['pricing_star_rating'] = (data['rating'] * 2).toString();
        request.fields['email'] = data['email'].toString();
        request.fields['author'] = data['name'].toString();
        await request.send();
      }
    } catch (e) {
      //This error exception is about your Rest API is not config correctly so that not return the correct JSON format, please double check the document from this link https://docs.inspireui.com/fluxstore/woocommerce-setup/
      rethrow;
    }
  }

  @override
  Future<BookStatus> bookService({userId, value, message}) async {
    try {
      var str = convert.jsonEncode(value);
      var response =
          await httpPost('$domain/wp-json/wp/v2/booking'.toUri()!, body: {
        'user_id': userId.toString(),
        'value': str,
        'message': message,
      });
      String? status = convert.jsonDecode(response.body);
      BookStatus bookStatus;
      switch (status) {
        case 'booked':
          {
            bookStatus = BookStatus.booked;
            break;
          }

        case 'waiting':
          {
            bookStatus = BookStatus.waiting;
            break;
          }

        case 'confirmed':
          {
            bookStatus = BookStatus.confirmed;
            break;
          }

        case 'unavailable':
          {
            bookStatus = BookStatus.unavailable;
            break;
          }

        default:
          {
            bookStatus = BookStatus.error;
            break;
          }
      }
      return bookStatus;
    } catch (e) {
      printLog('bookService error: $e');
      return BookStatus.error;
    }
  }

  @override
  Future<List<Product>> getProductNearest(location) async {
    try {
      var list = <Product>[];
      var page = location['page'];
      var perPage = location['perPage'];
      var lat = location['lat'];
      var long = location['long'];
      var radius = location['radius'];
      var domainReq =
          '$domain/wp-json/wp/v2/get-nearby-listings?page=$page&per_page=$perPage&radius=$radius&lat=$lat&long=$long';
      printLog(domainReq);
      final response = await httpGet(domainReq.toUri()!);
      if (response.statusCode == 200) {
        for (var item in convert.jsonDecode(response.body)) {
          var product = Product.fromListingJson(item);
          list.add(product);
        }
      }
      return list;
    } catch (err) {
      printLog('getProductNearest ${err.toString()}');
      rethrow;
    }
  }

  @override
  Future<List<ListingBooking>> getBooking({userId, page, perPage}) async {
    var endpoint =
        '$domain//wp-json/wp/v2/get-bookings?user_id=$userId&page=$page&per_page=$perPage';
    var bookings = <ListingBooking>[];
    try {
      final response = await httpGet(endpoint.toUri()!);
      for (var item in convert.jsonDecode(response.body)) {
        var booking = ListingBooking.fromJson(item);
        bookings.add(booking);
      }
    } catch (e) {
      printLog('listing_service.dart getBooking $e');
    }
    return bookings;
  }

  @override
  Future<Map<String, dynamic>>? checkBookingAvailability({data}) async {
    var endpoint = '$domain/wp-json/wp/v2/check-availability';
    try {
      final response = await http
          .post(endpoint.toUri()!, body: convert.jsonEncode(data), headers: {
        'Content-type': 'application/json',
        'Accept': 'application/json',
      });

      return convert.jsonDecode(response.body);
    } catch (e) {
      printLog('listing_service.dart checkBookingAvailability $e');
    }
    return {};
  }

  @override
  Future<List<Prediction>> getAutoCompletePlaces(
      String term, String? sessionToken) {
    throw UnimplementedError();
  }

  @override
  Future<List<ListingLocation>> getLocations() async {
    var list = <ListingLocation>[];
    if (ServerConfig().isListingType) {
      var i = 1;
      while (true) {
        var endpoint =
            '$domain/wp-json/wp/v2/${DataMapping().kLocationPath}?page=$i&per_page=100';
        printLog(endpoint);
        var response = await httpGet(
          endpoint.toUri()!,
        );
        var result = convert.jsonDecode(response.body);
        if (result.isEmpty ||
            (result is Map && isNotBlank(result['message']))) {
          return list;
        }
        for (var item in result) {
          list.add(ListingLocation.fromJson(item));
        }
        i++;
      }
    }
    return list;
  }

  @override
  Future<PagingResponse<Blog>> getBlogs(cursor) async {
    try {
      // dynamic page = cursor ?? 1;
      final param =
          '_embed&page=$cursor${kAdvanceConfig.alwaysRefreshBlog ? '&dummy=${DateTime.now().millisecondsSinceEpoch}' : ''}';
      final response = await http.get(
          '${ServerConfig().blog ?? domain}/wp-json/wp/v2/posts?$param'
              .toUri()!);

      if (response.statusCode != 200) {
        return const PagingResponse();
      }
      List data = jsonDecode(response.body);

      return PagingResponse(
        data: data.map((json) {
          return Blog.fromJson(json);
        }).toList(),
      );
    } on Exception catch (_) {
      return const PagingResponse();
    }
  }

  @override
  Future<Product> getProduct(id, {lang}) async {
    try {
      var endPoint = '$domain/wp-json/wp/v2/${DataMapping().kProductPath}/$id';
      var response = await httpGet(endPoint.toUri()!);
      return Product.fromListingJson(jsonDecode(response.body));
    } catch (e) {
      //This error exception is about your Rest API is not config correctly so that not return the correct JSON format, please double check the document from this link https://docs.inspireui.com/fluxstore/woocommerce-setup/
      rethrow;
    }
  }

  @override
  Future<bool> deleteAccount(String token) async {
    try {
      final response = await httpDelete(
          '$domain/wp-json/api/flutter_user/delete_account'.toUri()!,
          headers: {
            'User-Cookie': token,
            'Content-Type': 'application/json',
          });
      var body = convert.jsonDecode(response.body);
      if (body is Map && body['message'] != null) {
        throw body['message'];
      }
      return body;
    } catch (e) {
      rethrow;
    }
  }
}
