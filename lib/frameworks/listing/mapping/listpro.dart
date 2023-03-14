const kCategoryImages = {
  '14':
      'https://trello-attachments.s3.amazonaws.com/5d29325d2000ef2fad36345f/5f819c1647913f104387c46c/dfa82e326327aab9d12e073cdd6829fd/travel27.jpg',
  '27':
      'https://trello-attachments.s3.amazonaws.com/5d29325d2000ef2fad36345f/5f819c1647913f104387c46c/49bb344c8a5ea67c99922f396b37ea96/travel13.jpg',
  '29':
      'https://trello-attachments.s3.amazonaws.com/5d29325d2000ef2fad36345f/5f819c1647913f104387c46c/f91acac11d3f590f45bf56e1e6d570e7/travel10.jpg',
  '23':
      'https://trello-attachments.s3.amazonaws.com/5d29325d2000ef2fad36345f/5f819c1647913f104387c46c/829235a54da69fb543f8cad9e76e54b1/travel57.jpg',
  '31':
      'https://trello-attachments.s3.amazonaws.com/5f819c1647913f104387c46c/1200x857/53b0a9b29ab99d61ef33b71615aa1a33/travel60.jpg',
  '32':
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
  'description': 'content.rendered',
  'link': 'link',
  'distance': 'distance',
  'totalReview': 'listing_data.listing_reviewed',
  'rating': 'listing_data.listing_rate',
  'type': 'listing_data._type',
  'address': 'listing_data.lp_listingpro_options.gAddress',
  'lat': 'listing_data.lp_listingpro_options.latitude',
  'lng': 'listing_data.lp_listingpro_options.longitude',
  'gallery': 'gallery_images',
  'phone': 'listing_data.lp_listingpro_options.phone',
  'email': 'listing_data.lp_listingpro_options.email',
  'website': 'listing_data.lp_listingpro_options.website',
  'whatsapp': 'listing_data.lp_listingpro_options.whatsapp',
  'facebook': 'listing_data.lp_listingpro_options.facebook',
  'twitter': 'listing_data.lp_listingpro_options.twitter',
  'youtube': 'listing_data.lp_listingpro_options.youtube',
  'instagram': 'listing_data.lp_listingpro_options.instagram',
  'tagLine': 'listing_data.lp_listingpro_options.tagline_text',
  'eventDate': 'listing_data._event_date',
  'regularPrice': 'listing_data.lp_listingpro_options.list_price',
  'priceRange': 'listing_data.lp_listingpro_options.list_price_to',
  'menu': 'listing_data._menu.menu_elements',
  'pureTaxonomies': 'pure_taxonomies',
  'categoryIds': 'listing-category',
  'verified': 'listing_data.lp_listingpro_options.claimed_section',
  'featured_media': 'featured_image'
};
// this taxonomies are use for display the Listing detail
const kTaxonomies = {
  'category': 'listing-category',
  'region': 'location',
  'features': 'list-tags',
};

const kProductPath = 'listing';
const kCategoryPath = 'listing-category';
const kListingReviewMapping = {
  'review': 'lp-reviews',
  'item': 'lp_listingpro_options.listing_id'
};
const kLocationPath = 'location';
