import '../../../services/service_config.dart';
import '../index.dart';
import 'listing_service.dart';

mixin ListingMixin on ConfigMixin {
  @override
  void configListing(appConfig) {
    api = ListingService(
      domain: appConfig['url'],
      blogDomain: appConfig['blog'],
      type: appConfig['type'],
    );
    widget = ListingWidget();
  }
}
