import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../providers/community_provider.dart';

final _commentsProvider =
    FutureProvider.family<List<CommentModel>, String>((ref, postId) {
  return ref.read(communityProvider.notifier).loadComments(postId);
});

class PostDetailScreen extends ConsumerStatefulWidget {
  final String postId;

  const PostDetailScreen({super.key, required this.postId});

  @override
  ConsumerState<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends ConsumerState<PostDetailScreen> {
  final _commentController = TextEditingController();
  bool _submitting = false;
  List<CommentModel> _comments = [];
  bool _commentsLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadComments() async {
    final comments = await ref
        .read(communityProvider.notifier)
        .loadComments(widget.postId);
    if (mounted) {
      setState(() {
        _comments = comments;
        _commentsLoaded = true;
      });
    }
  }

  Future<void> _submitComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    setState(() => _submitting = true);
    await ref
        .read(communityProvider.notifier)
        .addComment(widget.postId, text);
    _commentController.clear();
    await _loadComments();
    setState(() => _submitting = false);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(communityProvider);
    final post = state.posts.firstWhere(
      (p) => p.id == widget.postId,
      orElse: () => PostModel(
        id: widget.postId,
        authorId: '',
        authorName: '',
        authorAvatar: '',
        title: '게시글',
        content: '',
        category: '',
        tags: [],
        likeCount: 0,
        commentCount: 0,
        isLiked: false,
        createdAt: DateTime.now(),
      ),
    );
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0D1A),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('게시글', style: TextStyle(color: Colors.white)),
        actions: [
          if (uid == post.authorId)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.white70),
              color: const Color(0xFF1A1A2E),
              onSelected: (value) async {
                if (value == 'delete') {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      backgroundColor: const Color(0xFF1A1A2E),
                      title: const Text('삭제 확인', style: TextStyle(color: Colors.white)),
                      content: const Text('게시글을 삭제하시겠습니까?',
                          style: TextStyle(color: Colors.white70)),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('취소'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('삭제', style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    await ref
                        .read(communityProvider.notifier)
                        .deletePost(widget.postId);
                    if (context.mounted) Navigator.pop(context);
                  }
                }
              },
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'delete', child: Text('삭제', style: TextStyle(color: Colors.red))),
              ],
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _PostHeader(post: post),
                  const SizedBox(height: 16),
                  Text(
                    post.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    post.content,
                    style: const TextStyle(color: Colors.white80, fontSize: 15, height: 1.6),
                  ),
                  if (post.tags.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      children: post.tags
                          .map((tag) => Text('#$tag',
                              style: const TextStyle(
                                  color: Color(0xFF7B9CDE), fontSize: 13)))
                          .toList(),
                    ),
                  ],
                  const SizedBox(height: 16),
                  _LikeButton(
                    post: post,
                    onTap: () => ref
                        .read(communityProvider.notifier)
                        .toggleLike(widget.postId),
                  ),
                  const Divider(color: Colors.white12, height: 32),
                  Text(
                    '댓글 ${_comments.length}',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (!_commentsLoaded)
                    const Center(
                      child: CircularProgressIndicator(color: Color(0xFFD4AF37)),
                    )
                  else
                    ..._comments.map((comment) => _CommentCard(
                          comment: comment,
                          isOwner: uid == comment.authorId,
                          onDelete: () async {
                            await ref
                                .read(communityProvider.notifier)
                                .deleteComment(widget.postId, comment.id);
                            _loadComments();
                          },
                        )),
                ],
              ),
            ),
          ),
          _CommentInput(
            controller: _commentController,
            submitting: _submitting,
            onSubmit: _submitComment,
          ),
        ],
      ),
    );
  }
}

class _PostHeader extends StatelessWidget {
  final PostModel post;
  const _PostHeader({required this.post});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: const Color(0xFFD4AF37).withOpacity(0.3),
          backgroundImage: post.authorAvatar.isNotEmpty
              ? NetworkImage(post.authorAvatar)
              : null,
          child: post.authorAvatar.isEmpty
              ? Text(
                  post.authorName.isNotEmpty ? post.authorName[0] : '?',
                  style: const TextStyle(color: Color(0xFFD4AF37)),
                )
              : null,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(post.authorName,
                  style: const TextStyle(color: Colors.white, fontSize: 14)),
              Text(
                timeago.format(post.createdAt, locale: 'ko'),
                style: const TextStyle(color: Colors.white38, fontSize: 12),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFD4AF37).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.4)),
          ),
          child: Text(post.category,
              style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 12)),
        ),
      ],
    );
  }
}

class _LikeButton extends StatelessWidget {
  final PostModel post;
  final VoidCallback onTap;

  const _LikeButton({required this.post, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: post.isLiked
              ? Colors.redAccent.withOpacity(0.15)
              : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: post.isLiked ? Colors.redAccent : Colors.white12,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              post.isLiked ? Icons.favorite : Icons.favorite_border,
              color: post.isLiked ? Colors.redAccent : Colors.white38,
              size: 18,
            ),
            const SizedBox(width: 6),
            Text(
              '${post.likeCount} 좋아요',
              style: TextStyle(
                color: post.isLiked ? Colors.redAccent : Colors.white38,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CommentCard extends StatelessWidget {
  final CommentModel comment;
  final bool isOwner;
  final VoidCallback onDelete;

  const _CommentCard({
    required this.comment,
    required this.isOwner,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: const Color(0xFFD4AF37).withOpacity(0.2),
            backgroundImage: comment.authorAvatar.isNotEmpty
                ? NetworkImage(comment.authorAvatar)
                : null,
            child: comment.authorAvatar.isEmpty
                ? Text(
                    comment.authorName.isNotEmpty ? comment.authorName[0] : '?',
                    style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 11),
                  )
                : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(comment.authorName,
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600)),
                    const SizedBox(width: 8),
                    Text(
                      timeago.format(comment.createdAt, locale: 'ko'),
                      style: const TextStyle(color: Colors.white38, fontSize: 11),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(comment.content,
                    style: const TextStyle(color: Colors.white80, fontSize: 13)),
              ],
            ),
          ),
          if (isOwner)
            GestureDetector(
              onTap: onDelete,
              child: const Icon(Icons.close, color: Colors.white30, size: 16),
            ),
        ],
      ),
    );
  }
}

class _CommentInput extends StatelessWidget {
  final TextEditingController controller;
  final bool submitting;
  final VoidCallback onSubmit;

  const _CommentInput({
    required this.controller,
    required this.submitting,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 8,
        top: 8,
        bottom: MediaQuery.of(context).viewInsets.bottom + 8,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF13132A),
        border: Border(top: BorderSide(color: Colors.white10)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: '댓글을 입력하세요...',
                hintStyle: const TextStyle(color: Colors.white38),
                filled: true,
                fillColor: Colors.white.withOpacity(0.06),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
            ),
          ),
          const SizedBox(width: 8),
          submitting
              ? const SizedBox(
                  width: 36,
                  height: 36,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Color(0xFFD4AF37)),
                )
              : IconButton(
                  onPressed: onSubmit,
                  icon: const Icon(Icons.send_rounded, color: Color(0xFFD4AF37)),
                ),
        ],
      ),
    );
  }
}