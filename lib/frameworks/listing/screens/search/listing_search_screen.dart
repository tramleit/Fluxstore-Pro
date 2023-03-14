import 'dart:async';

import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../../app.dart';
import '../../../../common/constants.dart';
import '../../../../generated/l10n.dart';
import '../../../../models/index.dart';
import '../../../../modules/dynamic_layout/index.dart';
import '../../../../routes/flux_navigate.dart';
import '../../../../screens/common/app_bar_mixin.dart';
import '../../../../services/index.dart';
import '../../widgets/category_horizon.dart';
import '../../widgets/listing_card_view.dart';
import '../../widgets/recent_list.dart';
import '../map/map_screen.dart';

/// Search Screen
class ListingSearchScreen extends StatefulWidget {
  @override
  ListingSearchScreenState createState() => ListingSearchScreenState();
}

class ListingSearchScreenState extends State<ListingSearchScreen>
    with
        AutomaticKeepAliveClientMixin,
        SingleTickerProviderStateMixin,
        AppBarMixin {
  TextEditingController? textController;
  FocusNode? _focus;
  String? searchText;
  bool isVisibleSearch = false;

  late Animation<double> animation;
  late AnimationController controller;

  Future<bool> requestLocation() async {
    var location = Location();

    bool serviceEnabled;
    // PermissionStatus _permissionGranted;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return false;
      }
    }

    var allow = await location.hasPermission();
    if (allow == PermissionStatus.denied) {
      allow = await location.requestPermission();
      if (allow != PermissionStatus.granted) {
        return false;
      }
    }

    return true;
  }

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
        duration: const Duration(milliseconds: 300), vsync: this);
    textController = TextEditingController();
    animation = Tween<double>(begin: 0, end: 50).animate(controller);
    animation.addListener(_animationListener);
    // focus change
    _focus = FocusNode();
    _focus!.addListener(_onFocusChange);
  }

  void _animationListener() {
    if (mounted) {
      setState(() {});
    }
  }

  void _onFocusChange() {
    if (_focus!.hasFocus && animation.value == 0) {
      controller.forward();
      setState(() {
        isVisibleSearch = true;
      });
    }
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    animation.removeListener(_animationListener);
    controller.dispose();
    textController!.dispose();
    super.dispose();
  }

  AppBar? renderAppBar() {
    if (Navigator.canPop(context)) {
      return AppBar(
        elevation: 0.1,
        backgroundColor: Theme.of(context).colorScheme.background,
        title: Text(
          S.of(context).search,
          style: Theme.of(context)
              .textTheme
              .headlineSmall
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        leading: Navigator.of(context).canPop()
            ? Center(
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(
                    Icons.arrow_back_ios,
                  ),
                ),
              )
            : const SizedBox(),
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final search = Provider.of<SearchModel>(context);

    return renderScaffold(
      routeName: RouteList.search,
      secondAppBar: renderAppBar(),
      floatingActionButton: FloatingActionButton(
        heroTag: 'location',
        backgroundColor: Theme.of(context).primaryColor,
        onPressed: () async {
          var grantPermission = await requestLocation();

          if (grantPermission) {
            await FluxNavigate.push(MaterialPageRoute(
                builder: (BuildContext context) =>
                    isMacOS || isWindow || isFuchsia
                        ? Scaffold(
                            backgroundColor: Theme.of(context).colorScheme.background,
                            body: const Center(
                              child: Text('This platform is not support'),
                            ),
                          )
                        : MapScreen()));
          }
        },
        child: const Icon(Icons.location_on, color: Colors.white),
      ),
      child: Container(
        color: Theme.of(context).colorScheme.background,
        child: SafeArea(
          child: ListenableProvider<SearchModel>.value(
            value: search,
            child: Consumer<SearchModel>(
              builder: (context, value, child) {
                return LayoutBuilder(builder:
                    (BuildContext context, BoxConstraints viewportConstraints) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 15.0),
                    child: Column(
                      children: <Widget>[
                        Row(children: [
                          /// SearchBar
                          Expanded(
                            child: Container(
                              height: 40,
                              decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.background,
                                  borderRadius: BorderRadius.circular(20)),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              margin: const EdgeInsets.all(10.0),
                              child: InkWell(
                                onTap: () {
                                  Navigator.of(App.fluxStoreNavigatorKey
                                          .currentContext!)
                                      .pushNamed(RouteList.homeSearch);
                                },
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Icon(
                                      Icons.search,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: TextField(
                                        controller: textController,
                                        focusNode: _focus,
                                        enabled: false,
                                        decoration: InputDecoration(
                                          fillColor: Theme.of(context)
                                              .colorScheme
                                              .secondary,
                                          border: InputBorder.none,
                                          hintText:
                                              S.of(context).searchForItems,
                                          focusColor: Theme.of(context)
                                              .colorScheme
                                              .secondary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(
                            width: 5,
                          )
                        ]),
                        Expanded(
                          child: isVisibleSearch
                              ? SearchTab(searchText, (text) {
                                  setState(() {
                                    searchText = text;
                                  });
                                  textController?.text = text;
                                  FocusScope.of(context).requestFocus(
                                      FocusNode()); //dismiss keyboard
                                  Provider.of<SearchModel>(context,
                                          listen: false)
                                      .searchListingProducts(
                                          name: text, page: 1);
                                })
                              : renderDefault(context, viewportConstraints),
                        ),
                      ],
                    ),
                  );
                });
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget renderDefault(context, viewportConstraints) {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          CategoryHorizontal(viewportConstraints),
          const SizedBox(
            height: 15.0,
          ),
          RecentList(),
        ],
      ),
    );
  }
}

/// Search Screen
class SearchTab extends StatelessWidget {
  final String? searchText;
  final Function onSearch;

  const SearchTab(this.searchText, this.onSearch);

  @override
  Widget build(BuildContext context) {
    return ListenableProvider<SearchModel>.value(
      value: Provider.of<SearchModel>(context),
      child: Consumer<SearchModel>(builder: (context, model, child) {
        if (searchText == null || searchText!.isEmpty) {
          return RecentSearches(onTap: onSearch);
        }

        if (model.isLoading) {
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: Theme.of(context).primaryColor,
              strokeWidth: 2.0,
            ),
          );
        }

        if (model.errMsg != null && model.errMsg!.isNotEmpty) {
          return Center(
              child: Text(model.errMsg!,
                  style: const TextStyle(color: kErrorRed)));
        }

        if (model.products!.isEmpty) {
          return Center(child: Text(S.of(context).noProduct));
        }

        return Column(
          children: <Widget>[
            Container(
              height: 45,
              decoration:
                  BoxDecoration(color: Theme.of(context).colorScheme.background),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  Text(
                    'We found ${model.products!.length} listings',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10.0, vertical: 20.0),
                child: ProductList(name: searchText, products: model.products),
              ),
            )
          ],
        );
      }),
    );
  }
}

/// ProductList
class ProductList extends StatefulWidget {
  final name;
  final padding;
  final products;

  const ProductList({this.products, this.name, this.padding = 10.0});

  @override
  State<ProductList> createState() => _ProductListState();
}

class _ProductListState extends State<ProductList> {
  late RefreshController _refreshController;
  final _service = Services();
  List<Product>? _products;
  int _page = 1;

  @override
  void initState() {
    super.initState();
    _products = widget.products ?? [];
    _refreshController = RefreshController(initialRefresh: _products!.isEmpty);
  }

  void _loadProduct() async {
    var pagingResponse =
        await _service.api.searchProducts(name: widget.name, page: _page)!;
    final newProducts = pagingResponse.data ?? [];
    _products = [..._products!, ...newProducts];
  }

  void _onRefresh() async {
    _page = 1;
    _products = [];
    _loadProduct();
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    _page = _page + 1;
    _loadProduct();
    _refreshController.loadComplete();
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final heightImage = constraints.maxWidth / 4;
        final widthImage = constraints.maxWidth / 4;

        return SmartRefresher(
          header: MaterialClassicHeader(
              backgroundColor: Theme.of(context).primaryColor),
          enablePullDown: false,
          enablePullUp: false,
          controller: _refreshController,
          onRefresh: _onRefresh,
          onLoading: _onLoading,
          child: _products == null
              ? Container(child: null)
              : ListView(children: <Widget>[
                  for (var item in _products!)
                    ListingCardView(
                      item: item,
                      width: widthImage,
                      height: heightImage,
                      config: ProductConfig.empty()
                        ..layout = 'list'
                        ..showHeart = true,
                    )
                ]),
        );
      },
    );
  }
}
