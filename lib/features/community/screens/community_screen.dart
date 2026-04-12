import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../providers/community_provider.dart';

const List<String> _categories = ['전체', '자유', '사주', '운세', '연애', '직업', '건강'];

class CommunityScreen extends ConsumerWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(communityProvider);
    final notifier = ref.read(communityProvider.notifier);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            backgroundColor: const Color(0xFF0D0D1A),
            title: const Text(
              '커뮤니티',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.group, color: Colors.white70),
                onPressed: () => context.push('/community/ohang-group'),
                tooltip: '오행 소그룹',
              ),
            ],
            floating: true,
            snap: true,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(96),
              child: Column(
                children: [
                  _SortTabBar(
                    sortType: state.sortType,
                    onChanged: notifier.setSortType,
                  ),
                  _CategoryFilter(
                    selected: state.selectedCategory,
                    onChanged: notifier.setCategory,
                  ),
                ],
              ),
            ),
          ),
        ],
        body: state.isLoading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFFD4AF37)))
            : state.error != null
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(state.error!, style: const TextStyle(color: Colors.red)),
                        TextButton(
                          onPressed: notifier.loadPosts,
                          child: const Text('다시 시도'),
                        ),
                      ],
                    ),
                  )
                : state.posts.isEmpty
                    ? const Center(
                        child: Text(
                          '첫 번째 글을 작성해보세요!',
                          style: TextStyle(color: Colors.white54),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: notifier.loadPosts,
                        color: const Color(0xFFD4AF37),
                        child: ListView.builder(
                          padding: const EdgeInsets.only(bottom: 80),
                          itemCount: state.posts.length,
                          itemBuilder: (context, index) {
                            return _PostCard(
                              post: state.posts[index],
                              onTap: () => context.push(
                                '/community/post/${state.posts[index].id}',
                              ),
                              onLike: () => notifier.toggleLike(state.posts[index].id),
                            );
                          },
                        ),
                      ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/community/create'),
        backgroundColor: const Color(0xFFD4AF37),
        icon: const Icon(Icons.edit, color: Colors.black),
        label: const Text('글쓰기', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

class _SortTabBar extends StatelessWidget {
  final PostSortType sortType;
  final ValueChanged<PostSortType> onChanged;

  const _SortTabBar({required this.sortType, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          _SortChip(
            label: '최신순',
            selected: sortType == PostSortType.latest,
            onTap: () => onChanged(PostSortType.latest),
          ),
          const SizedBox(width: 8),
          _SortChip(
            label: '인기순',
            selected: sortType == PostSortType.popular,
            onTap: () => onChanged(PostSortType.popular),
          ),
        ],
      ),
    );
  }
}

class _SortChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SortChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFD4AF37) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? const Color(0xFFD4AF37) : Colors.white30,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.black : Colors.white54,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _CategoryFilter extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;

  const _CategoryFilter({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final cat = _categories[index];
          final isSelected = selected == cat;
          return GestureDetector(
            onTap: () => onChanged(cat),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFFD4AF37).withOpacity(0.15)
                    : Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? const Color(0xFFD4AF37) : Colors.white12,
                ),
              ),
              child: Text(
                cat,
                style: TextStyle(
                  color: isSelected ? const Color(0xFFD4AF37) : Colors.white54,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PostCard extends StatelessWidget {
  final PostModel post;
  final VoidCallback onTap;
  final VoidCallback onLike;

  const _PostCard({required this.post, required this.onTap, required this.onLike});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: const Color(0xFFD4AF37).withOpacity(0.3),
                  backgroundImage: post.authorAvatar.isNotEmpty
                      ? NetworkImage(post.authorAvatar)
                      : null,
                  child: post.authorAvatar.isEmpty
                      ? Text(
                          post.authorName.isNotEmpty ? post.authorName[0] : '?',
                          style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 12),
                        )
                      : null,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.authorName,
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                      Text(
                        timeago.format(post.createdAt, locale: 'ko'),
                        style: const TextStyle(color: Colors.white38, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4AF37).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.3)),
                  ),
                  child: Text(
                    post.category,
                    style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 11),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              post.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Text(
              post.content,
              style: const TextStyle(color: Colors.white54, fontSize: 13),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (post.tags.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                children: post.tags
                    .map((tag) => Text(
                          '#$tag',
                          style: const TextStyle(
                            color: Color(0xFF7B9CDE),
                            fontSize: 12,
                          ),
                        ))
                    .toList(),
              ),
            ],
            const SizedBox(height: 10),
            Row(
              children: [
                GestureDetector(
                  onTap: onLike,
                  child: Row(
                    children: [
                      Icon(
                        post.isLiked ? Icons.favorite : Icons.favorite_border,
                        color: post.isLiked ? Colors.redAccent : Colors.white38,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${post.likeCount}',
                        style: const TextStyle(color: Colors.white38, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                const Icon(Icons.chat_bubble_outline, color: Colors.white38, size: 16),
                const SizedBox(width: 4),
                Text(
                  '${post.commentCount}',
                  style: const TextStyle(color: Colors.white38, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}