import 'dart:convert';
import 'package:http/http.dart' as http;

class LikeService {
  static const String _baseUrl = 'https://prakrutitech.xyz/gaurang/';

  // Toggle Like
  static Future<Map<String, dynamic>> toggleLike(int userId, int mediaId) async {
    try {
      print('Toggle Like - userId: $userId, mediaId: $mediaId');

      final response = await http.post(
        Uri.parse('$_baseUrl/like.php'),
        body: {
          'user_id': userId.toString(),
          'media_id': mediaId.toString(),
        },
      );

      print('Like Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return {
        'status': false,
        'message': 'Server error: ${response.statusCode}',
      };
    } catch (e) {
      print('Like Error: $e');
      return {
        'status': false,
        'message': 'Network error: $e',
      };
    }
  }

  // Add Comment
  static Future<Map<String, dynamic>> addComment({
    required int userId,
    required int mediaId,
    required String comment,
  }) async {
    try {
      print('Add Comment - userId: $userId, mediaId: $mediaId, comment: $comment');

      final response = await http.post(
        Uri.parse('$_baseUrl/add_comments.php'),
        body: {
          'user_id': userId.toString(),
          'media_id': mediaId.toString(),
          'comment': comment,
        },
      );

      print('Add Comment Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return {
        'status': false,
        'message': 'Server error: ${response.statusCode}',
      };
    } catch (e) {
      print('Add Comment Error: $e');
      return {
        'status': false,
        'message': 'Network error: $e',
      };
    }
  }

  // Get Comments
  static Future<Map<String, dynamic>> getComments(int mediaId) async {
    try {
      print('Get Comments - mediaId: $mediaId');

      final response = await http.get(
        Uri.parse('$_baseUrl/view_comments.php?media_id=$mediaId'),
      );

      print('Get Comments Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return {
        'status': false,
        'message': 'Server error: ${response.statusCode}',
      };
    } catch (e) {
      print('Get Comments Error: $e');
      return {
        'status': false,
        'message': 'Network error: $e',
      };
    }
  }

  // Delete Comment (Optional - if your API supports it)
  static Future<Map<String, dynamic>> deleteComment({
    required int commentId,
    required int userId,
  }) async {
    try {
      print('Delete Comment - commentId: $commentId, userId: $userId');

      final response = await http.post(
        Uri.parse('$_baseUrl/delete_comment.php'), // Update with your API endpoint
        body: {
          'comment_id': commentId.toString(),
          'user_id': userId.toString(),
        },
      );

      print('Delete Comment Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return {
        'status': false,
        'message': 'Server error: ${response.statusCode}',
      };
    } catch (e) {
      print('Delete Comment Error: $e');
      return {
        'status': false,
        'message': 'Network error: $e',
      };
    }
  }
}