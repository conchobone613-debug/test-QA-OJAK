import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_router.g.dart';

// ---------------------------------------------------------------------------
// Route paths
// ---------------------------------------------------------------------------
abstract class AppRoutes {
  static const splash = '/';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const profileSetup = '/profile-setup';

  // Main shell
  static const main = '/main';
  static const matchFeed = '/main/match-feed';
  static const fortune = '/main/fortune';
  static const chatList = '/main/chat-list';
  static const community = '/main/community';
  static const myPage = '/main/my-page';

  // Detail screens
  static const userDetail = '/user/:userId';
  static const matchSuccess = '/match-success';
  static const compatibilityDetail = '/compatibility/:userId';
  static const chatRoom = '/chat/:roomId';
  static const communityPost = '/community/post/:postId';
  static const notification = '/notifications';
  static const settings = '/settings';
  static const pointShop = '/point-shop';
  static const premiumSubscription = '/premium';
}

// ---------------------------------------------------------------------------
// Auth state (임시 – 과제 2 AuthNotifier 연결 전 placeholder)
// ---------------------------------------------------------------------------
// ignore: avoid_classes_with_only_static_members
class _AuthState {
  static bool isAuthenticated = false;
  static bool hasCompletedOnboarding = false;
  static bool hasCompletedProfile = false;
}

// ---------------------------------------------------------------------------
// Router provider
// ---------------------------------------------------------------------------
@riverpod
GoRouter appRouter(AppRouterRef ref) {
  // TODO: ref.watch(authProvider) 로 실제 인증 상태 구독
  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,
    redirect: _globalRedirect,
    routes: _buildRoutes(),
    errorBuilder: (context, state) => _ErrorScreen(error: state.error),
  );
}

// ---------------------------------------------------------------------------
// Global redirect (auth guard)
// ---------------------------------------------------------------------------
String? _globalRedirect(BuildContext context, GoRouterState state) {
  final location = state.matchedLocation;

  final publicPaths = {
    AppRoutes.splash,
    AppRoutes.onboarding,
    AppRoutes.login,
  };

  final isPublic = publicPaths.contains(location);
  final isAuth = _AuthState.isAuthenticated;
  final hasOnboarding = _AuthState.hasCompletedOnboarding;
  final hasProfile = _AuthState.hasCompletedProfile;

  // Splash 는 항상 허용
  if (location == AppRoutes.splash) return null;

  // 비인증 사용자 → login
  if (!isAuth && !isPublic) return AppRoutes.login;

  // 온보딩 미완료
  if (isAuth && !hasOnboarding && location != AppRoutes.onboarding) {
    return AppRoutes.onboarding;
  }

  // 프로필 미완료
  if (isAuth && hasOnboarding && !hasProfile && location != AppRoutes.profileSetup) {
    return AppRoutes.profileSetup;
  }

  // 이미 인증됐는데 login/onboarding 접근 시 → main
  if (isAuth && hasOnboarding && hasProfile && isPublic) {
    return AppRoutes.matchFeed;
  }

  return null;
}

// ---------------------------------------------------------------------------
// Route definitions
// ---------------------------------------------------------------------------
List<RouteBase> _buildRoutes() {
  return [
    // Splash
    GoRoute(
      path: AppRoutes.splash,
      name: 'splash',
      pageBuilder: (context, state) => _fadeTransition(
        state,
        const _PlaceholderScreen(label: 'Splash'),
      ),
    ),

    // Onboarding
    GoRoute(
      path: AppRoutes.onboarding,
      name: 'onboarding',
      pageBuilder: (context, state) => _slideTransition(
        state,
        const _PlaceholderScreen(label: 'Onboarding'),
      ),
    ),

    // Login
    GoRoute(
      path: AppRoutes.login,
      name: 'login',
      pageBuilder: (context, state) => _slideTransition(
        state,
        const _PlaceholderScreen(label: 'Login'),
      ),
    ),

    // Profile Setup
    GoRoute(
      path: AppRoutes.profileSetup,
      name: 'profileSetup',
      pageBuilder: (context, state) => _slideTransition(
        state,
        const _PlaceholderScreen(label: 'ProfileSetup'),
      ),
    ),

    // -----------------------------------------------------------------------
    // Main Shell (탭 네비게이션)
    // -----------------------------------------------------------------------
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) => _MainShell(
        navigationShell: navigationShell,
      ),
      branches: [
        // 탭 0: MatchFeed
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.matchFeed,
              name: 'matchFeed',
              pageBuilder: (context, state) => _noTransition(
                state,
                const _PlaceholderScreen(label: 'MatchFeed'),
              ),
            ),
          ],
        ),

        // 탭 1: Fortune
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.fortune,
              name: 'fortune',
              pageBuilder: (context, state) => _noTransition(
                state,
                const _PlaceholderScreen(label: 'Fortune'),
              ),
            ),
          ],
        ),

        // 탭 2: ChatList
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.chatList,
              name: 'chatList',
              pageBuilder: (context, state) => _noTransition(
                state,
                const _PlaceholderScreen(label: 'ChatList'),
              ),
            ),
          ],
        ),

        // 탭 3: Community
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.community,
              name: 'community',
              pageBuilder: (context, state) => _noTransition(
                state,
                const _PlaceholderScreen(label: 'Community'),
              ),
            ),
          ],
        ),

        // 탭 4: MyPage
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.myPage,
              name: 'myPage',
              pageBuilder: (context, state) => _noTransition(
                state,
                const _PlaceholderScreen(label: 'MyPage'),
              ),
            ),
          ],
        ),
      ],
    ),

    // -----------------------------------------------------------------------
    // Detail screens (전체 화면 오버레이)
    // -----------------------------------------------------------------------

    // 유저 상세
    GoRoute(
      path: AppRoutes.userDetail,
      name: 'userDetail',
      pageBuilder: (context, state) {
        final userId = state.pathParameters['userId']!;
        return _slideTransition(
          state,
          _PlaceholderScreen(label: 'UserDetail: $userId'),
        );
      },
    ),

    // 매칭 성공
    GoRoute(
      path: AppRoutes.matchSuccess,
      name: 'matchSuccess',
      pageBuilder: (context, state) => _fadeTransition(
        state,
        const _PlaceholderScreen(label: 'MatchSuccess'),
      ),
    ),

    // 궁합 상세
    GoRoute(
      path: AppRoutes.compatibilityDetail,
      name: 'compatibilityDetail',
      pageBuilder: (context, state) {
        final userId = state.pathParameters['userId']!;
        return _slideTransition(
          state,
          _PlaceholderScreen(label: 'CompatibilityDetail: $userId'),
        );
      },
    ),

    // 채팅방
    GoRoute(
      path: AppRoutes.chatRoom,
      name: 'chatRoom',
      pageBuilder: (context, state) {
        final roomId = state.pathParameters['roomId']!;
        return _slideTransition(
          state,
          _PlaceholderScreen(label: 'ChatRoom: $roomId'),
        );
      },
    ),

    // 커뮤니티 게시글
    GoRoute(
      path: AppRoutes.communityPost,
      name: 'communityPost',
      pageBuilder: (context, state) {
        final postId = state.pathParameters['postId']!;
        return _slideTransition(
          state,
          _PlaceholderScreen(label: 'CommunityPost: $postId'),
        );
      },
    ),

    // 알림
    GoRoute(
      path: AppRoutes.notification,
      name: 'notification',
      pageBuilder: (context, state) => _slideTransition(
        state,
        const _PlaceholderScreen(label: 'Notifications'),
      ),
    ),

    // 설정
    GoRoute(
      path: AppRoutes.settings,
      name: 'settings',
      pageBuilder: (context, state) => _slideTransition(
        state,
        const _PlaceholderScreen(label: 'Settings'),
      ),
    ),

    // 포인트샵
    GoRoute(
      path: AppRoutes.pointShop,
      name: 'pointShop',
      pageBuilder: (context, state) => _slideTransition(
        state,
        const _PlaceholderScreen(label: 'PointShop'),
      ),
    ),

    // 프리미엄 구독
    GoRoute(
      path: AppRoutes.premiumSubscription,
      name: 'premiumSubscription',
      pageBuilder: (context, state) => _slideTransition(
        state,
        const _PlaceholderScreen(label: 'PremiumSubscription'),
      ),
    ),
  ];
}

// ---------------------------------------------------------------------------
// Page transition helpers
// ---------------------------------------------------------------------------
CustomTransitionPage<void> _fadeTransition(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 400),
    transitionsBuilder: (context, animation, secondary, child) {
      return FadeTransition(opacity: animation, child: child);
    },
  );
}

CustomTransitionPage<void> _slideTransition(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 300),
    transitionsBuilder: (context, animation, secondary, child) {
      final tween = Tween(
        begin: const Offset(1.0, 0.0),
        end: Offset.zero,
      ).chain(CurveTween(curve: Curves.easeInOut));
      return SlideTransition(position: animation.drive(tween), child: child);
    },
  );
}

NoTransitionPage<void> _noTransition(GoRouterState state, Widget child) {
  return NoTransitionPage<void>(key: state.pageKey, child: child);
}

// ---------------------------------------------------------------------------
// Main Shell Widget (BottomNavigationBar)
// ---------------------------------------------------------------------------
class _MainShell extends StatelessWidget {
  const _MainShell({required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static const _tabs = [
    _TabItem(icon: Icons.favorite_border, activeIcon: Icons.favorite, label: '매칭'),
    _TabItem(icon: Icons.auto_awesome_outlined, activeIcon: Icons.auto_awesome, label: '운세'),
    _TabItem(icon: Icons.chat_bubble_outline, activeIcon: Icons.chat_bubble, label: '채팅'),
    _TabItem(icon: Icons.people_outline, activeIcon: Icons.people, label: '커뮤니티'),
    _TabItem(icon: Icons.person_outline, activeIcon: Icons.person, label: '마이'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: navigationShell.currentIndex,
        onTap: _onTap,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        items: _tabs
            .map(
              (t) => BottomNavigationBarItem(
                icon: Icon(t.icon),
                activeIcon: Icon(t.activeIcon),
                label: t.label,
              ),
            )
            .toList(),
      ),
    );
  }

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }
}

class _TabItem {
  const _TabItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
}

// ---------------------------------------------------------------------------
// Placeholder screens (각 화면 구현 전 임시)
// ---------------------------------------------------------------------------
class _PlaceholderScreen extends StatelessWidget {
  const _PlaceholderScreen({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(label)),
      body: Center(
        child: Text(label, style: Theme.of(context).textTheme.headlineSmall),
      ),
    );
  }
}

class _ErrorScreen extends StatelessWidget {
  const _ErrorScreen({this.error});

  final Exception? error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('오류')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(error?.toString() ?? '알 수 없는 오류가 발생했습니다.'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.splash),
              child: const Text('홈으로'),
            ),
          ],
        ),
      ),
    );
  }
}