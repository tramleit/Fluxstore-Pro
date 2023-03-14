///-----FLUXSTORE LISTING-----///
const kCategoryDataMapping = {
  'id': 'id',
  'name': 'name',
  'parent': 'parent',
  'count': 'count',
  'image': 'term_image'
};

const kCategoryImages = {
  '29':
      'https://trello-attachments.s3.amazonaws.com/5d29325d2000ef2fad36345f/5f819c1647913f104387c46c/704a5e38cd981ba27bbd56fa6e8b9aea/travel53.jpg',
  '19':
      'https://trello-attachments.s3.amazonaws.com/5d29325d2000ef2fad36345f/5f819c1647913f104387c46c/49bb344c8a5ea67c99922f396b37ea96/travel13.jpg',
  '34':
      'https://trello-attachments.s3.amazonaws.com/5d29325d2000ef2fad36345f/5f819c1647913f104387c46c/a3ccbe5c3a78161975181f87e836d279/travel39.jpg',
  '33':
      'https://trello-attachments.s3.amazonaws.com/5d29325d2000ef2fad36345f/5f819c1647913f104387c46c/527bee78112c0b826038bbb587ae3a98/travel30.jpg',
  '37':
      'https://trello-attachments.s3.amazonaws.com/5d29325d2000ef2fad36345f/5f819c1647913f104387c46c/dfa82e326327aab9d12e073cdd6829fd/travel27.jpg',
  '35':
      'https://trello-attachments.s3.amazonaws.com/5f819c1647913f104387c46c/1200x857/53b0a9b29ab99d61ef33b71615aa1a33/travel60.jpg'
};

const kProductDataMapping = {
  'id': 'id',
  'title': 'title.rendered',
  'description': 'content.rendered',
  'link': 'link',
  'distance': 'distance',
  'totalReview': 'comments_ratings.totalReview',
  'rating': 'listing_data.listeo-avg-rating',
  'type': 'listing_data._listing_type',
  'address': 'listing_data._address',
  'lat': 'listing_data._geolocation_lat',
  'lng': 'listing_data._geolocation_long',
  'gallery': 'gallery_images',
  'phone': 'listing_data._phone',
  'email': 'listing_data._email',
  'website': 'listing_data._website',
  'facebook': 'listing_data._facebook',
  'twitter': 'listing_data._twitter',
  'youtube': 'listing_data._youtube',
  'instagram': 'listing_data._instagram',
  'skype': 'listing_data._skype',
  'whatsapp': 'listing_data._whatsapp',
  'tagLine': 'listing_data._friendly_address',
  'eventDate': 'listing_data._event_date',
  'regularPrice': 'listing_data._price_min',
  'priceRange': 'listing_data._price_max',
  'menu': 'listing_data._menu',
  'pureTaxonomies': 'pure_taxonomies',
  'categoryIds': 'listing_category',
  'featured': 'listing_data._featured',
  'verified': 'listing_data._verified',
  'featured_media': 'featured_image'
};

// this taxonomies are use for display the Listing detail
const kTaxonomies = {
  'category': 'listing_category',
  'region': 'region',
  'features': 'listing_feature'
};
const kProductPath = 'listing';
const kCategoryPath = 'listing_category';
const kListingReviewMapping = {'review': 'getReviews', 'item': ''};
const kLocationPath = 'region';
