import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:artist_hub/models/comment_model.dart';
import 'package:artist_hub/core/services/url_helper.dart';
import 'package:artist_hub/providers/auth_provider.dart';
import 'package:artist_hub/core/constants/app_colors.dart';
import 'package:artist_hub/core/services/like_services.dart';

class PostDetailsBottomSheet extends StatefulWidget {
  final dynamic post;
  final bool isLiked; // If CURRENT USER liked it
  final int likesCount; // Total like count
  final int mediaId;
  final VoidCallback onLikeTapped;

  const PostDetailsBottomSheet({
    Key? key,
    required this.post,
    required this.isLiked,
    required this.likesCount,
    required this.mediaId,
    required this.onLikeTapped,
  }) : super(key: key);

  @override
  State<PostDetailsBottomSheet> createState() => _PostDetailsBottomSheetState();
}

class _PostDetailsBottomSheetState extends State<PostDetailsBottomSheet> {
  late bool _isLiked; // Current user's like status
  late int _likesCount; // Total like count
  List<CommentModel> _comments = [];
  bool _loadingComments = false;
  bool _addingComment = false;
  final TextEditingController _commentController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _commentFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _isLiked = widget.isLiked;
    _likesCount = widget.likesCount;
    _loadComments();
  }

  @override
  void dispose() {
    _commentController.dispose();
    _scrollController.dispose();
    _commentFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadComments() async {
    if (!mounted) return;

    setState(() => _loadingComments = true);

    try {
      final result = await LikeService.getComments(widget.mediaId);

      if (!mounted) return;

      if (result['status'] == true) {
        final currentUserId = context.read<AuthProvider>().user?.id ?? 0;

        if (result['data'] is Map) {
          final data = result['data'] as Map<String, dynamic>;
          final commentsData = data['comments'] ?? [];

          if (commentsData is List) {
            final List<CommentModel> loadedComments = [];

            for (var commentData in commentsData) {
              try {
                final comment = CommentModel.fromJson(
                  commentData is Map<String, dynamic>
                      ? commentData
                      : Map<String, dynamic>.from(commentData as Map),
                  currentUserId,
                );
                loadedComments.add(comment);
              } catch (e) {
                print('Error parsing comment: $e');
              }
            }

            setState(() => _comments = loadedComments);
          }
        }
      }
    } catch (e) {
      print('Error loading comments: $e');
    } finally {
      if (mounted) {
        setState(() => _loadingComments = false);
      }
    }
  }

  Future<void> _addComment() async {
    if (_commentController.text.trim().isEmpty) return;

    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user == null) return;

    setState(() => _addingComment = true);

    final commentText = _commentController.text.trim();
    _commentController.clear();

    try {
      final result = await LikeService.addComment(
        userId: user.id!,
        mediaId: widget.mediaId,
        comment: commentText,
      );

      if (!mounted) return;

      if (result['status'] == true) {
        // Create new comment object
        final newComment = CommentModel(
          id: 0,
          userId: user.id!,
          mediaId: widget.mediaId,
          comment: commentText,
          userName: user.name ?? 'User',
          userAvatar: null,
          createdAt: DateTime.now(),
          isCurrentUserComment: true,
        );

        // Add to list immediately
        setState(() {
          _comments = [..._comments, newComment];
        });

        // Scroll to bottom
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });

        // Refresh comments from server
        await Future.delayed(Duration(milliseconds: 500));
        await _loadComments();
      }
    } catch (e) {
      print('Error adding comment: $e');
    } finally {
      if (mounted) {
        setState(() => _addingComment = false);
      }
    }
  }

  void _handleLike() {
    // Update local state optimistically
    setState(() {
      _isLiked = !_isLiked;
      _likesCount = _isLiked ? _likesCount + 1 : _likesCount - 1;
    });

    // Call the parent handler (which will update server)
    widget.onLikeTapped();

    // Show feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isLiked ? 'Liked!' : 'Like removed'),
        backgroundColor: _isLiked ? Colors.pink : Colors.grey,
        duration: Duration(seconds: 1),
      ),
    );
  }

  String _formatTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaUrl = widget.post['media_url']?.toString() ?? '';
    final caption = widget.post['caption']?.toString() ?? '';
    final mediaType = widget.post['media_type']?.toString() ?? 'image';
    final fullImageUrl = UrlHelper.getMediaUrl(mediaUrl);
    final user = context.watch<AuthProvider>().user;

    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.accentColor)),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.close_rounded,
                      size: 20,
                      color: AppColors.textColor.withOpacity(0.6),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  'Post',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textColor,
                  ),
                ),
                const Spacer(),
                if (mediaType == 'video')
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.play_arrow_rounded, size: 14, color: AppColors.primaryColor),
                        const SizedBox(width: 4),
                        Text(
                          'Video',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: Column(
              children: [
                // Media Preview with like button
                Container(
                  height: 300,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    image: fullImageUrl.isNotEmpty
                        ? DecorationImage(
                      image: NetworkImage(fullImageUrl),
                      fit: BoxFit.cover,
                    )
                        : null,
                  ),
                  child: Stack(
                    children: [
                      if (fullImageUrl.isEmpty)
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: AppColors.accentColor,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  mediaType == 'video'
                                      ? Icons.videocam_rounded
                                      : Icons.photo_rounded,
                                  size: 40,
                                  color: AppColors.textColor.withOpacity(0.3),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Media not available',
                                style: TextStyle(
                                  color: AppColors.textColor.withOpacity(0.6),
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Like button overlay
                      Positioned(
                        bottom: 20,
                        right: 20,
                        child: GestureDetector(
                          onTap: _handleLike,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _isLiked
                                  ? Icons.favorite_rounded
                                  : Icons.favorite_outline_rounded,
                              size: 28,
                              color: _isLiked ? Colors.red : Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Action buttons and like count
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Like button with count
                      Row(
                        children: [
                          IconButton(
                            onPressed: _handleLike,
                            icon: Icon(
                              _isLiked
                                  ? Icons.favorite_rounded
                                  : Icons.favorite_outline_rounded,
                              size: 28,
                              color: _isLiked ? Colors.red : AppColors.textColor.withOpacity(0.6),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '$_likesCount likes',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textColor,
                            ),
                          ),
                        ],
                      ),

                      // Comment button
                      Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              _commentFocusNode.requestFocus();
                            },
                            icon: Icon(
                              Icons.comment_rounded,
                              size: 28,
                              color: AppColors.textColor.withOpacity(0.6),
                            ),
                          ),
                          Text(
                            '${_comments.length}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const Divider(height: 1),

                // Comments Section
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // Caption (if any)
                        if (caption.isNotEmpty) ...[
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              caption,
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textColor,
                                height: 1.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Comments Header
                        Row(
                          children: [
                            Text(
                              'Comments',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textColor,
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (_comments.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  _comments.length.toString(),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primaryColor,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Comments List
                        Expanded(
                          child: _loadingComments
                              ? Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primaryColor,
                            ),
                          )
                              : _comments.isEmpty
                              ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.comment_outlined,
                                  size: 64,
                                  color: AppColors.textColor.withOpacity(0.3),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No comments yet',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: AppColors.textColor.withOpacity(0.6),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Be the first to comment!',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.textColor.withOpacity(0.4),
                                  ),
                                ),
                              ],
                            ),
                          )
                              : ListView.builder(
                            controller: _scrollController,
                            itemCount: _comments.length,
                            itemBuilder: (context, index) {
                              final comment = _comments[index];
                              return _buildCommentItem(comment);
                            },
                          ),
                        ),

                        // Add Comment Input
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              // User Avatar
                              if (user != null)
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryColor.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.person,
                                    size: 20,
                                    color: AppColors.primaryColor,
                                  ),
                                ),

                              const SizedBox(width: 12),

                              // Comment Input
                              Expanded(
                                child: TextField(
                                  controller: _commentController,
                                  focusNode: _commentFocusNode,
                                  decoration: InputDecoration(
                                    hintText: user != null
                                        ? 'Add a comment...'
                                        : 'Login to comment',
                                    hintStyle: TextStyle(
                                      color: AppColors.textColor.withOpacity(0.5),
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                                    enabled: user != null,
                                  ),
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.textColor,
                                  ),
                                  maxLines: null,
                                  onSubmitted: (value) => _addComment(),
                                ),
                              ),

                              // Send Button
                              if (user != null)
                                IconButton(
                                  onPressed: _addingComment ? null : _addComment,
                                  icon: _addingComment
                                      ? SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.primaryColor,
                                    ),
                                  )
                                      : Icon(
                                    Icons.send_rounded,
                                    color: AppColors.primaryColor,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentItem(CommentModel comment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User Avatar
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: comment.isCurrentUserComment
                  ? AppColors.primaryColor.withOpacity(0.1)
                  : AppColors.accentColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person,
              size: 20,
              color: comment.isCurrentUserComment
                  ? AppColors.primaryColor
                  : AppColors.textColor.withOpacity(0.6),
            ),
          ),

          const SizedBox(width: 12),

          // Comment Content
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User Info and Time
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        comment.userName,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textColor,
                        ),
                      ),
                      Text(
                        _formatTimeAgo(comment.createdAt),
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textColor.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  // Comment Text
                  Text(
                    comment.comment,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textColor.withOpacity(0.8),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}