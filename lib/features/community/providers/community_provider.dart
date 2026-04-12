import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

enum PostSortType { latest, popular }

class PostModel {
  final String id;
  final String authorId;
  final String authorName;
  final String authorAvatar;
  final String title;
  final String content;
  final String category;
  final List<String> tags;
  final int likeCount;
  final int commentCount;
  final bool isLiked;
  final DateTime createdAt;

  PostModel({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.authorAvatar,
    required this.title,
    required this.content,
    required this.category,
    required this.tags,
    required this.likeCount,
    required this.commentCount,
    required this.isLiked,
    required this.createdAt,
  });

  factory PostModel.fromMap(Map<String, dynamic> map, String id, {bool isLiked = false}) {
    return PostModel(
      id: id,
      authorId: map['authorId'] ?? '',
      authorName: map['authorName'] ?? '익명',
      authorAvatar: map['authorAvatar'] ?? '',
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      category: map['category'] ?? '자유',
      tags: List<String>.from(map['tags'] ?? []),
      likeCount: map['likeCount'] ?? 0,
      commentCount: map['commentCount'] ?? 0,
      isLiked: isLiked,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  PostModel copyWith({
    int? likeCount,
    int? commentCount,
    bool? isLiked,
  }) {
    return PostModel(
      id: id,
      authorId: authorId,
      authorName: authorName,
      authorAvatar: authorAvatar,
      title: title,
      content: content,
      category: category,
      tags: tags,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      isLiked: isLiked ?? this.isLiked,
      createdAt: createdAt,
    );
  }
}

class CommentModel {
  final String id;
  final String authorId;
  final String authorName;
  final String authorAvatar;
  final String content;
  final int likeCount;
  final DateTime createdAt;

  CommentModel({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.authorAvatar,
    required this.content,
    required this.likeCount,
    required this.createdAt,
  });

  factory CommentModel.fromMap(Map<String, dynamic> map, String id) {
    return CommentModel(
      id: id,
      authorId: map['authorId'] ?? '',
      authorName: map['authorName'] ?? '익명',
      authorAvatar: map['authorAvatar'] ?? '',
      content: map['content'] ?? '',
      likeCount: map['likeCount'] ?? 0,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

class GroupMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String content;
  final DateTime createdAt;

  GroupMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.content,
    required this.createdAt,
  });

  factory GroupMessage.fromMap(Map<String, dynamic> map, String id) {
    return GroupMessage(
      id: id,
      senderId: map['senderId'] ?? '',
      senderName: map['senderName'] ?? '',
      content: map['content'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

class CommunityState {
  final List<PostModel> posts;
  final PostSortType sortType;
  final String selectedCategory;
  final bool isLoading;
  final String? error;

  CommunityState({
    this.posts = const [],
    this.sortType = PostSortType.latest,
    this.selectedCategory = '전체',
    this.isLoading = false,
    this.error,
  });

  CommunityState copyWith({
    List<PostModel>? posts,
    PostSortType? sortType,
    String? selectedCategory,
    bool? isLoading,
    String? error,
  }) {
    return CommunityState(
      posts: posts ?? this.posts,
      sortType: sortType ?? this.sortType,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class CommunityNotifier extends StateNotifier<CommunityState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CommunityNotifier() : super(CommunityState()) {
    loadPosts();
  }

  Future<void> loadPosts() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      Query query = _firestore.collection('posts');

      if (state.selectedCategory != '전체') {
        query = query.where('category', isEqualTo: state.selectedCategory);
      }

      if (state.sortType == PostSortType.latest) {
        query = query.orderBy('createdAt', descending: true);
      } else {
        query = query.orderBy('likeCount', descending: true);
      }

      final snapshot = await query.limit(50).get();
      final uid = _auth.currentUser?.uid;

      final posts = await Future.wait(snapshot.docs.map((doc) async {
        bool isLiked = false;
        if (uid != null) {
          final likeDoc = await _firestore
              .collection('posts')
              .doc(doc.id)
              .collection('likes')
              .doc(uid)
              .get();
          isLiked = likeDoc.exists;
        }
        return PostModel.fromMap(doc.data() as Map<String, dynamic>, doc.id, isLiked: isLiked);
      }));

      state = state.copyWith(posts: posts, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void setSortType(PostSortType sortType) {
    state = state.copyWith(sortType: sortType);
    loadPosts();
  }

  void setCategory(String category) {
    state = state.copyWith(selectedCategory: category);
    loadPosts();
  }

  Future<void> createPost({
    required String title,
    required String content,
    required String category,
    required List<String> tags,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      final userData = userDoc.data() ?? {};

      await _firestore.collection('posts').add({
        'authorId': user.uid,
        'authorName': userData['displayName'] ?? user.displayName ?? '익명',
        'authorAvatar': userData['photoURL'] ?? user.photoURL ?? '',
        'title': title,
        'content': content,
        'category': category,
        'tags': tags,
        'likeCount': 0,
        'commentCount': 0,
        'createdAt': FieldValue.serverTimestamp(),
      });

      await loadPosts();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> deletePost(String postId) async {
    try {
      await _firestore.collection('posts').doc(postId).delete();
      state = state.copyWith(
        posts: state.posts.where((p) => p.id != postId).toList(),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> toggleLike(String postId) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final index = state.posts.indexWhere((p) => p.id == postId);
    if (index == -1) return;

    final post = state.posts[index];
    final likeRef = _firestore
        .collection('posts')
        .doc(postId)
        .collection('likes')
        .doc(uid);

    final newLiked = !post.isLiked;
    final newCount = newLiked ? post.likeCount + 1 : post.likeCount - 1;

    final newPosts = List<PostModel>.from(state.posts);
    newPosts[index] = post.copyWith(isLiked: newLiked, likeCount: newCount);
    state = state.copyWith(posts: newPosts);

    try {
      if (newLiked) {
        await likeRef.set({'uid': uid, 'createdAt': FieldValue.serverTimestamp()});
      } else {
        await likeRef.delete();
      }
      await _firestore.collection('posts').doc(postId).update({
        'likeCount': FieldValue.increment(newLiked ? 1 : -1),
      });
    } catch (e) {
      newPosts[index] = post;
      state = state.copyWith(posts: newPosts);
    }
  }

  Future<List<CommentModel>> loadComments(String postId) async {
    final snapshot = await _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .orderBy('createdAt', descending: false)
        .get();
    return snapshot.docs
        .map((doc) => CommentModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<void> addComment(String postId, String content) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    final userData = userDoc.data() ?? {};

    await _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .add({
      'authorId': user.uid,
      'authorName': userData['displayName'] ?? user.displayName ?? '익명',
      'authorAvatar': userData['photoURL'] ?? user.photoURL ?? '',
      'content': content,
      'likeCount': 0,
      'createdAt': FieldValue.serverTimestamp(),
    });

    await _firestore.collection('posts').doc(postId).update({
      'commentCount': FieldValue.increment(1),
    });
  }

  Future<void> deleteComment(String postId, String commentId) async {
    await _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .doc(commentId)
        .delete();
    await _firestore.collection('posts').doc(postId).update({
      'commentCount': FieldValue.increment(-1),
    });
  }

  Stream<List<GroupMessage>> groupMessagesStream(String ohang) {
    return _firestore
        .collection('ohang_groups')
        .doc(ohang)
        .collection('messages')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => GroupMessage.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<void> sendGroupMessage(String ohang, String content) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    final userData = userDoc.data() ?? {};

    await _firestore
        .collection('ohang_groups')
        .doc(ohang)
        .collection('messages')
        .add({
      'senderId': user.uid,
      'senderName': userData['displayName'] ?? user.displayName ?? '익명',
      'content': content,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}

final communityProvider =
    StateNotifierProvider<CommunityNotifier, CommunityState>(
  (ref) => CommunityNotifier(),
);