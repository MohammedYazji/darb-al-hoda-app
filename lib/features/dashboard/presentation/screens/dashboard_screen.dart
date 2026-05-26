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

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          children: [
            // === Header ===
            _buildWelcomeHeader(user.name),
            const SizedBox(height: 20),

            // === AI coach assistant Message ===
            // TODO fetch from AI endpoint
            _buildAICoachCard(),
            const SizedBox(height: 20),

            // === Total memorized ===
            _buildMemorizationCard(data),
            const SizedBox(height: 16),

            // === Current Target ===
            _buildCurrentGoalCard(data),
            const SizedBox(height: 16),

            // === The Ranking Cards ===
            _buildRankingCards(data),
            const SizedBox(height: 16),

            // === Attendance Card ===
            _buildAttendanceCard(data),
          ],
        ),
      ),
    );
  }

  // === Header ===
  Widget _buildWelcomeHeader(String name) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'أهلاً $name 👋',
              style: AppTextStyles.h2.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _getTodayDate(),
              style: AppTextStyles.bodySmall.copyWith(
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),

        // === AVATAR ===
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary,
            border: Border.all(color: AppColors.gold, width: 2),
          ),
          child: Center(
            child: Text(
              name.substring(0, 1),
              style: AppTextStyles.h3.copyWith(
                color: AppColors.gold,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // === AI Coach Card ===
  Widget _buildAICoachCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
      ),
      child: Stack(
        children: [
          // Decorative circle
          // TODO: make it as separate componenet
          Positioned(
            left: -16,
            top: -16,
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.gold.withValues(alpha: 0.15),
              ),
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // == Title ==
              Row(
                children: [
                  const Icon(
                    Icons.psychology_outlined,
                    color: AppColors.gold,
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'رسالة المحفّز الذكي 🤖',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.gold,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // == Message ==
              // TODO: hard coded for now
              RichText(
                text: TextSpan(
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                    height: 1.6,
                  ),
                  children: [
                    const TextSpan(text: '🌟 يا يوسف، '),
                    TextSpan(
                      text: 'كريم يتقدم عليك بـ١٥ صفحة فقط!',
                      style: TextStyle(
                        color: AppColors.gold,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const TextSpan(
                      text:
                          ' لو راجعت صفحة واحدة كل يوم لمدة أسبوعين، ستتجاوزه إن شاء الله. أنت قادر! 💚',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // === Memorization Card ===
  Widget _buildMemorizationCard(DashboardModel data) {
    final student = data.student;
    final progress = student.progressPercentage;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative corner
          Positioned(
            top: 0,
            left: 0,
            child: Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.05),
                borderRadius: const BorderRadius.only(
                  bottomRight: Radius.circular(96),
                ),
              ),
            ),
          ),

          Column(
            children: [
              Text(
                'إجمالي المحفوظ',
                style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.w700),
              ),

              const SizedBox(height: 24),

              // === Circular progress ===
              SizedBox(
                width: 190,
                height: 190,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: progress),
                      duration: const Duration(milliseconds: 1000),
                      curve: Curves.easeOut,
                      builder: (context, value, _) {
                        return CustomPaint(
                          size: const Size(220, 220),
                          painter: CircularProgressPainter(
                            progress: value,
                            progressColor: AppColors.primary,
                            backgroundColor: Colors.grey.shade100,
                            strokeWidth: 14,
                          ),
                        );
                      },
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${student.memorized}',
                          style: AppTextStyles.h1.copyWith(
                            color: AppColors.primary,
                            fontSize: 48,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          'من 30 جزء',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: Colors.grey.shade500,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // === Stats Row ===
              // TODO: page and ayah not accurate cause not each juz equal 20 page
              Container(
                padding: const EdgeInsets.only(top: 16),
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: Colors.grey.shade100)),
                ),
                child: Row(
                  children: [
                    _buildStat(
                      '${student.memorized * 200}',
                      'آية',
                      AppColors.gold,
                    ),
                    _buildDivider(),
                    _buildStat(
                      '${student.memorized * 20}',
                      'صفحة',
                      AppColors.gold,
                    ),
                    _buildDivider(),
                    _buildStat('${student.memorized}', 'أجزاء', AppColors.gold),
                    _buildDivider(),
                    _buildStat(
                      '${student.confirmed}',
                      'مثبّت',
                      AppColors.primary,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // === Current Goal ===
  Widget _buildCurrentGoalCard(DashboardModel data) {
    final nextJuz = data.student.memorized + 1;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.menu_book_outlined,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'الهدف الحالي: الجزء $nextJuz',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              Text(
                '70%',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.gold,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 0.7),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOut,
              builder: (context, value, _) {
                return LinearProgressIndicator(
                  value: value,
                  backgroundColor: Colors.grey.shade100,
                  valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                  minHeight: 10,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // === Ranking Cards ===
  Widget _buildRankingCards(DashboardModel data) {
    return Row(
      children: [
        Expanded(
          child: _buildRankCard(
            icon: Icons.emoji_events_outlined,
            iconColor: AppColors.gold,
            label: 'المرتبة في المركز',
            value: '${data.ranking.center}',
            gradientColor: AppColors.gold,
            borderColor: AppColors.gold.withValues(alpha: 0.3),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildRankCard(
            icon: Icons.star,
            iconColor: AppColors.primary,
            label: 'المرتبة في الحلقة',
            value: '${data.ranking.circle}',
            gradientColor: AppColors.primary,
            borderColor: AppColors.primary.withValues(alpha: 0.15),
          ),
        ),
      ],
    );
  }

  Widget _buildRankCard({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required Color gradientColor,
    required Color borderColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [gradientColor.withValues(alpha: 0.12), Colors.white],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          Icon(Icons.star, color: AppColors.primary, size: 32),
          const SizedBox(height: 6),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.h2.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  // === Attendance Card ===
  Widget _buildAttendanceCard(DashboardModel data) {
    final attendance = data.attendanceThisMonth;
    final percentage = attendance.percentage;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'الحضور هذا الشهر',
            style: AppTextStyles.bodySmall.copyWith(
              fontWeight: FontWeight.w700,
              color: Colors.grey.shade700,
            ),
          ),

          const SizedBox(height: 10),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '${attendance.present} ',
                      style: AppTextStyles.h3.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    TextSpan(
                      text: '/ ${attendance.total} يوم',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${(percentage * 100).toInt()}%',
                  style: AppTextStyles.bodySmall.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: percentage),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOut,
              builder: (context, value, _) {
                return LinearProgressIndicator(
                  value: value,
                  backgroundColor: Colors.grey.shade100,
                  valueColor: const AlwaysStoppedAnimation(Colors.grey),
                  minHeight: 8,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // === Statistics widget for each topic ===
  Widget _buildStat(String value, String label, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: AppTextStyles.bodyLarge.copyWith(
              color: color,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w700,
              fontSize: 10,
            ),
          ),
        ],
      ),
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

  Widget _buildDivider() {
    return Container(width: 1, height: 32, color: Colors.grey.shade100);
  }
}

// === Circular Progress Painter ===
// TODO move into separate file
class CircularProgressPainter extends CustomPainter {
  final double progress;
  final Color progressColor;
  final Color backgroundColor;
  final double strokeWidth;

  CircularProgressPainter({
    required this.progress,
    required this.progressColor,
    required this.backgroundColor,
    this.strokeWidth = 10,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    //== Circle Background ===
    final bgPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, radius, bgPaint);

    // === Progress-Bar ===
    final progressPaint = Paint()
      ..color = progressColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -3.14159 / 2, // Start from top
      2 * 3.14159 * progress, // angel of progress
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(CircularProgressPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
