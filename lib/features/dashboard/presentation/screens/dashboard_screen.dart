import 'package:darb_al_hoda_app/core/constants/app_colors.dart';
import 'package:darb_al_hoda_app/core/constants/app_text_styles.dart';
import 'package:darb_al_hoda_app/core/models/dashboard_model.dart';
import 'package:darb_al_hoda_app/features/auth/presentation/auth_provider.dart';
import 'package:darb_al_hoda_app/features/dashboard/presentation/dashboard_provider.dart';
import 'package:darb_al_hoda_app/shared/widgets/bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  // the dashboard mean the home tab
  NavTab _currentTab = NavTab.home;

  @override
  void initState() {
    super.initState();

    // when open the dashboard get it's data immediately
    Future.microtask(
      () => ref.read(dashboardProvider.notifier).fetchDashboard(),
    );
  }

  @override
  Widget build(BuildContext context) {
    // keep watch for any change in auth or dashboard state to update UI auto
    final dashState = ref.watch(dashboardProvider);
    final authState = ref.watch(authProvider);

    return Scaffold(
      // TODO: make it as constant
      backgroundColor: const Color(0xFFF5F5F0),
      body: _buildBody(dashState, authState),
      bottomNavigationBar: BottomNavBar(
        currentTab: _currentTab,
        onTabSelected: (tab) => setState(() => _currentTab = tab),
      ),
    );
  }

  Widget _buildBody(DashboardState dashState, AuthState authState) {
    // if still fetching dashboard data
    if (dashState.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    // if any error happened
    if (dashState.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: AppColors.error, size: 48),

            const SizedBox(height: 16),

            Text(dashState.error!, style: AppTextStyles.bodyMedium),

            const SizedBox(height: 16),

            // btn to try fetch the manually
            ElevatedButton(
              onPressed: () =>
                  ref.read(dashboardProvider.notifier).fetchDashboard(),
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      );
    }

    // if the data fetched
    if (dashState.hasData) {
      return _buildDashboard(dashState, authState);
    }

    return const SizedBox();
  }

  Widget _buildDashboard(DashboardState dashState, AuthState authState) {
    // catch the user and his data in variables
    final data = dashState.data!; // will not be null
    final user = authState.user!; // will not be null - I'm sure

    return SingleChildScrollView(
      child: Column(
        children: [
          // === Header ===
          _buildHeader(user.name, data),

          // === AI coach assistant Message ===
          // TODO fetch from AI endpoint
          _buildAICoachCard(),

          // === Total memorized ===
          _buildMemorizationCard(data),

          // === The current target ===
          _buildCurrentGoalCard(data),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // === Header ===
  Widget _buildHeader(String name, dashboard) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 56, 20, 20),
      decoration: const BoxDecoration(color: AppColors.primary),
      child: Row(
        children: [
          // === The user icon ===
          // TODO: make seperate componenet for the icon to use it here and in role_selection_screen without repeat code
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.gold,
            ),
            child: Center(
              child: Text(
                name.substring(0, 1),
                style: AppTextStyles.h3.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // === Welcoming ===
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'أهلاً $name 👋',
                style: AppTextStyles.h3.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                _getTodayDate(),
                style: AppTextStyles.caption.copyWith(
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // === AI Coach Card ===
  Widget _buildAICoachCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary.withValues(alpha: 0.9), AppColors.primary],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Text('🤖', style: TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'رسالة المحفّز الذكي',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.gold,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                // TODO: hard coded for now
                Text(
                  'يا يوسف, كريم يتقدم عليك ب5 صفحات فقط! واصل الحفظ',
                  style: AppTextStyles.bodySmall.copyWith(color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // === Memorization Card ===
  Widget _buildMemorizationCard(DashboardModel dashboard) {
    final student = dashboard.student;
    final progress = student.progressPercentage;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          Text('إجمالي المحفوظ', style: AppTextStyles.h3),

          const SizedBox(height: 20),

          // === Circular Progress ===
          SizedBox(
            width: 140,
            height: 140,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 10,
                  backgroundColor: Colors.grey.shade100,
                  valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${student.memorized}',
                      style: AppTextStyles.h1.copyWith(
                        color: AppColors.primary,
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text('من 30 جزء', style: AppTextStyles.caption),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // === Stats ===
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStat('${student.confirmed}', 'مثبّت'),
              _buildStat('${student.memorized}', 'أجزاء'),
              _buildStat('${student.memorized * 20}', 'صفحة'),
              _buildStat('${student.memorized * 200}', 'آية'),
            ],
          ),
        ],
      ),
    );
  }

  // === Current Goal Card ===
  Widget _buildCurrentGoalCard(DashboardModel dashboard) {
    final nextJuz = dashboard.student.memorized + 1;
    final progress = 0.7; // TODO: calculate real progress

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.menu_book_outlined, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'الهدف الحالي: الجزء $nextJuz',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey.shade100,
                    valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '${(progress * 100).toInt()}%',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // === Statistics widget for each topic
  Widget _buildStat(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.h3.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w900,
          ),
        ),
        Text(label, style: AppTextStyles.caption),
      ],
    );
  }

  //  === Helper ===
  String _getTodayDate() {
    final now = DateTime.now();
    final days = [
      'الاثنين',
      'الثلاثاء',
      'الأربعاء',
      'الخميس',
      'الجمعة',
      'السبت',
      'الأحد',
    ];
    final months = [
      'يناير',
      'فبراير',
      'مارس',
      'إبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر',
    ];
    return '${days[now.weekday - 1]} ${now.day} ${months[now.month - 1]}';
  }
}
