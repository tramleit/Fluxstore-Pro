const kCategoryImages = {
  '28':
      'https://trello-attachments.s3.amazonaws.com/5d29325d2000ef2fad36345f/5f819c1647913f104387c46c/dfa82e326327aab9d12e073cdd6829fd/travel27.jpg',
  '29':
      'https://trello-attachments.s3.amazonaws.com/5d29325d2000ef2fad36345f/5f819c1647913f104387c46c/49bb344c8a5ea67c99922f396b37ea96/travel13.jpg',
  '53':
      'https://trello-attachments.s3.amazonaws.com/5d29325d2000ef2fad36345f/5f819c1647913f104387c46c/f91acac11d3f590f45bf56e1e6d570e7/travel10.jpg',
  '65':
      'https://trello-attachments.s3.amazonaws.com/5d29325d2000ef2fad36345f/5f819c1647913f104387c46c/829235a54da69fb543f8cad9e76e54b1/travel57.jpg',
  '77':
      'https://trello-attachments.s3.amazonaws.com/5f819c1647913f104387c46c/1200x857/53b0a9b29ab99d61ef33b71615aa1a33/travel60.jpg',
  '73':
      'https://trello-attachments.s3.amazonaws.com/5d29325d2000ef2fad36345f/5f819c1647913f104387c46c/704a5e38cd981ba27bbd56fa6e8b9aea/travel53.jpg'
};

const kCategoryDataMapping = {
  'id': 'id',
  'name': 'name',
  'parent': 'parent',
  'count': 'count',
  'image': 'term_image'
};

const kProductDataMapping = {
  'id': 'id',
  'title': 'title.rendered',
  'description': 'listing_data._job_description',
  'link': 'link',
  'distance': 'distance',
  'totalReview': 'listing_data._case27_review_count',
  'rating': 'listing_data._case27_average_rating',
  'type': 'listing_data._type',
  'address': 'listing_data._job_location',
  'lat': 'listing_data.geolocation_lat',
  'lng': 'listing_data.geolocation_long',
  'gallery': 'listing_data._job_gallery',
  'phone': 'listing_data._job_phone',
  'email': 'listing_data._job_email',
  'website': '_links.Website',
  'facebook': '_links.Facebook',
  'twitter': '_links.Twitter',
  'youtube': '_links.YouTube',
  'instagram': '_links.Instagram',
  'tagLine': 'listing_data._job_tagline',
  'eventDate': 'listing_data._event_date',
  'regularPrice': 'listing_data._price-per-day',
  'menu': 'listing_data._menu.menu_elements',
  'pureTaxonomies': 'pure_taxonomies',
  'categoryIds': 'job_listing_category',
  'featured_media': 'listing_data._job_cover',
  'featured': 'listing_data._featured'
};
// this taxonomies are use for display the Listing detail
const kTaxonomies = {
  'category': 'job_listing_category',
  'region': 'region',
  'features': 'case27_job_listing_tags',
};

const kProductPath = 'job_listing';
const kCategoryPath = 'job_listing_category';
const kListingReviewMapping = {'review': 'getReviews', 'item': ''};
