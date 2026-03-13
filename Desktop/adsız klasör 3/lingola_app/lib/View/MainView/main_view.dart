import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:lingola_app/Services/notification_activity_service.dart';
import 'package:lingola_app/src/navigation/app_routes.dart';
import 'package:lingola_app/View/HomeView/home_view.dart';
import 'package:lingola_app/View/LearnTabView/learn_tab_view.dart';
import 'package:lingola_app/View/LibraryView/library_view.dart';
import 'package:lingola_app/View/ProfileView/profile_view.dart';
import 'package:lingola_app/Riverpod/Providers/all_providers.dart';
import 'package:lingola_app/src/widgets/app_bottom_nav_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Ana kabuk: ortak alt navigasyon bar + seçilen sekme.
/// Kayıtlı kelime sayısı [savedWordsProvider] ile reaktif okunur.
class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({
    super.key,
    this.initialIndex = 0,
    this.isPremium = false,
  });

  final int initialIndex;
  final bool isPremium;

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> with WidgetsBindingObserver {
  late int _currentIndex;
  String _userName = 'Jhon Doe';
  String? _pendingLearnRoute;
  int? _pendingLibraryTabIndex;
  int _avatarVersion = 0;

  static const List<AppNavItem> _navItems = [
    AppNavItem(iconAsset: 'assets/icons/nav_home.svg', label: 'nav.home'),
    AppNavItem(iconAsset: 'assets/icons/nav_learn.svg', label: 'nav.learn'),
    AppNavItem(iconAsset: 'assets/icons/nav_library.svg', label: 'nav.library'),
    AppNavItem(iconAsset: 'assets/icons/nav_profil.svg', label: 'nav.profile'),
  ];

  static const String _keyProfileName = 'profile_name';

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _loadSavedProfileName();
    WidgetsBinding.instance.addObserver(this);
    NotificationActivityService.pingActivity();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      NotificationActivityService.pingActivity();
    }
  }

  int get _savedWordsCount => ref.watch(savedWordsProvider).length;
  int get _totalXp => ref.watch(xpProvider);

  Future<void> _loadSavedProfileName() async {
    final prefs = await SharedPreferences.getInstance();
    final savedName = prefs.getString(_keyProfileName);
    if (savedName != null && savedName.isNotEmpty && mounted) {
      setState(() => _userName = savedName);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPremium = ref.watch(premiumProvider).valueOrNull ?? widget.isPremium;
    return Scaffold(
      backgroundColor: const Color(0xFFF2F5FC),
      body: Stack(
        children: [
          // Sayfa tam ekran; içerik barın arkasına kadar uzanır, beyaz boşluk yok
          Positioned.fill(
            child: IndexedStack(
              index: _currentIndex,
              children: [
                HomeScreen(
                  userName: _userName,
                  isPremium: isPremium,
                  savedWordsCount: _savedWordsCount,
                  totalXp: _totalXp,
                  avatarVersion: _avatarVersion,
                  onLearnNewWordsTap: () => setState(() {
                    _currentIndex = 1;
                    _pendingLearnRoute = '/word_practice';
                  }),
                  onSavedWordsTap: () => setState(() {
                    _currentIndex = 1;
                    _pendingLearnRoute = '/saved_word';
                  }),
                  onDictionaryTap: () => setState(() {
                    _currentIndex = 2;
                    _pendingLibraryTabIndex = 1;
                  }),
                ),
                LearnTab(
                  userName: _userName,
                  savedWordsCount: _savedWordsCount,
                  totalXp: _totalXp,
                  avatarVersion: _avatarVersion,
                  onBackTap: () => setState(() => _currentIndex = 0),
                  pendingRoute: _pendingLearnRoute,
                  onPendingRouteHandled: () => setState(() => _pendingLearnRoute = null),
                ),
                LibraryScreen(
                  onBackTap: () => setState(() => _currentIndex = 0),
                  initialTabIndex: _pendingLibraryTabIndex,
                  onInitialTabHandled: () => setState(() => _pendingLibraryTabIndex = null),
                ),
                ProfileScreen(
                  userName: _userName,
                  totalXp: _totalXp,
                  isPremium: isPremium,
                  onUserNameChanged: (name) => setState(() => _userName = name),
                  onAvatarChanged: () => setState(() => _avatarVersion++),
                  onBackTap: () => setState(() => _currentIndex = 0),
                  onNotificationsTap: () {
                    context.push(
                      AppPaths.notifications,
                      extra: NotificationsRouteArgs(isPremium: isPremium),
                    );
                  },
                ),
              ],
            ),
          ),
          // Pill bar altta, sayfanın üzerinde
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: AppBottomNavBar(
              items: _navItems,
              currentIndex: _currentIndex,
              onTap: (index) => setState(() => _currentIndex = index),
            ),
          ),
        ],
      ),
    );
  }
}
