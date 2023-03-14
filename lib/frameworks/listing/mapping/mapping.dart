import '../../../common/config.dart';
import 'listeo.dart' as listeo;
import 'listpro.dart' as listpro;
import 'mylisting.dart' as mylisting;

class Mapping {
  static void init(String? type) {
    String kProductPath;
    String kCategoryPath;
    String? kLocationPath;
    Map<String, dynamic> kProductDataMapping;
    Map<String, dynamic> kCategoryDataMapping;
    Map<String, dynamic> kCategoryImages;
    // this taxonomies are use for display the Listing detail
    Map<String, dynamic> kTaxonomies;
    Map<String, dynamic> kListingReviewMapping;
    switch (type) {
      case 'mylisting':
        {
          kCategoryPath = mylisting.kCategoryPath;
          kProductPath = mylisting.kProductPath;
          kProductDataMapping =
              Map<String, dynamic>.from(mylisting.kProductDataMapping);
          kCategoryDataMapping =
              Map<String, dynamic>.from(mylisting.kCategoryDataMapping);
          kCategoryImages =
              Map<String, dynamic>.from(mylisting.kCategoryImages);
          kTaxonomies = Map<String, dynamic>.from(mylisting.kTaxonomies);
          kListingReviewMapping =
              Map<String, dynamic>.from(mylisting.kListingReviewMapping);
          break;
        }
      case 'listpro':
        {
          kCategoryPath = listpro.kCategoryPath;
          kProductPath = listpro.kProductPath;
          kLocationPath = listpro.kLocationPath;
          kProductDataMapping =
              Map<String, dynamic>.from(listpro.kProductDataMapping);
          kCategoryDataMapping =
              Map<String, dynamic>.from(listpro.kCategoryDataMapping);
          kCategoryImages = Map<String, dynamic>.from(listpro.kCategoryImages);
          kTaxonomies = Map<String, dynamic>.from(listpro.kTaxonomies);
          kListingReviewMapping =
              Map<String, dynamic>.from(listpro.kListingReviewMapping);
          break;
        }
      default:
        {
          kCategoryPath = listeo.kCategoryPath;
          kProductPath = listeo.kProductPath;
          kLocationPath = listeo.kLocationPath;
          kProductDataMapping =
              Map<String, dynamic>.from(listeo.kProductDataMapping);
          kCategoryDataMapping =
              Map<String, dynamic>.from(listeo.kCategoryDataMapping);
          kCategoryImages = Map<String, dynamic>.from(listeo.kCategoryImages);
          kTaxonomies = Map<String, dynamic>.from(listeo.kTaxonomies);
          kListingReviewMapping =
              Map<String, dynamic>.from(listeo.kListingReviewMapping);
        }
    }
    DataMapping().setMapping(
        kProductPath,
        kCategoryPath,
        kLocationPath,
        kProductDataMapping,
        kCategoryDataMapping,
        kCategoryImages,
        kTaxonomies,
        kListingReviewMapping);
  }
}
