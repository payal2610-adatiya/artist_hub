class ApiEndpoints {
  static const baseUrl = 'https://prakrutitech.xyz/gaurang/';
  static const String mediaBaseUrl = '$baseUrl/uploads/'; // For media files


  // Auth
  static const login = 'login.php';
  static const register = 'register.php';

  // User
  static const viewUser = 'view_user.php';
  static const updateUser = 'update_user.php';
  static const deleteUser = 'delete_user.php';

  // Artist
  static const viewArtist = 'view_artist.php';
  static const artistDetails = 'artist_details.php';
  static const customerViewArtist = 'customer_view_artist.php';
  static const artistPendingRequest = 'artist_pending_request.php';
  static const artistApproval = 'artist_aproval.php';

  // Artist Profile
  static const addArtistProfile = 'add_artist_profile.php';
  static const viewArtistProfile = 'view_artist_profile.php';
  static const updateArtistProfile = 'update_artist_profile.php';
  static const deleteArtistProfile = 'delete_artist_profile.php';

  // Artist Media
  static const addArtistMedia = 'add_artist_media.php';
  static const getMedia = 'get_media.php';
  static const viewArtistMedia = 'view_artist_media.php';
  static const viewArtistMediaById = 'view_artist_media_by_id.php';
  static const updateArtistMedia = 'update_artist_media.php';
  static const deleteArtistMedia = 'delete_artist_media.php';

  // Bookings
  static const addBooking = 'add_bookings.php';
  static const viewBooking = 'view_booking.php';
  static const viewBookingById = 'view_boking_by_id.php';
  static const updateBooking = 'update_bookings.php';
  static const artistBookingCancel = 'artist_booking_cancel.php';
  static const customerBookingCancel = 'customer_booking_cancel.php';

  // Reviews
  static const addReview = 'add_review.php';
  static const viewReview = 'view_review.php';
  static const updateReview = 'update_review.php';
  static const deleteReview = 'delete_review.php';

  // Comments
  static const addComment = 'add_comments.php';
  static const viewComments = 'view_comments.php';
  static const updateComment = 'update_comments.php';
  static const deleteComment = 'delete_comments.php';

  // Feedback
  static const addFeedback = 'add_feedback.php';
  static const viewFeedback = 'view_feedback.php';
  static const viewFeedbackArtist = 'view_feedback_artist.php';
  static const updateFeedback = 'update_feedback.php';
  static const deleteFeedback = 'delete_feedback.php';

  // Payments
  static const addPayment = 'add_payments.php';
  static const viewPayments = 'view_payments.php';

  // Likes & Shares
  static const like = 'like.php';
  static const viewLike = 'view_like.php';
  static const share = 'share.php';

  // Full URL getters
  static String getLoginUrl() => baseUrl + login;
  static String getRegisterUrl() => baseUrl + register;
  static String getArtistDetailsUrl(int artistId) => baseUrl + artistDetails + '?artist_id=$artistId';
  static String getArtistMediaUrl(int artistId) => baseUrl + viewArtistMedia + '?artist_id=$artistId';
  static String getBookingsUrl({int? customerId, int? artistId}) {
    String url = baseUrl + viewBooking;
    if (customerId != null) {
      url += '?customer_id=$customerId';
    } else if (artistId != null) {
      url += '?artist_id=$artistId';
    }
    return url;
  }
}