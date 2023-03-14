import 'package:flutter/material.dart';
import 'package:inspireui/utils/encode.dart';
import 'package:provider/provider.dart';

import '../../../models/index.dart';
import '../../../services/service_config.dart';
import '../../../widgets/common/webview_inapp.dart';

class AddListingScreen extends StatefulWidget {
  @override
  State<AddListingScreen> createState() => _AddListingScreenState();
}

class _AddListingScreenState extends State<AddListingScreen> {
  String addListingUrl = '';
  late var authUrl;

  @override
  void initState() {
    super.initState();
    var id = Provider.of<UserModel>(context, listen: false).user!.id;
    var cookie = Provider.of<UserModel>(context, listen: false).user!.cookie;
    var base64Str = EncodeUtils.encodeCookie(cookie!);


    addListingUrl =
        ServerConfig().addListingUrl ?? '${ServerConfig().url}/add-listing';

    authUrl =
        '${ServerConfig().url}/wp-json/wp/v2/add-listing?id=$id&url=$addListingUrl?cookie=$base64Str';
  }

  @override
  Widget build(BuildContext context) {
    return WebViewInApp(url: authUrl);
  }
}
