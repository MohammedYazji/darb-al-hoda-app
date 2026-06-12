import 'package:darb_al_hoda_app/core/utils/arabic_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../features/auth/presentation/screens/settings_screen.dart';
import '../../../../shared/widgets/bottom_nav_bar.dart';
import '../admin_provider.dart';

// === Admin Panel - main dashboard for center managers ===
class AdminScreen extends ConsumerStatefulWidget {
  const AdminScreen({super.key});

  @override
  ConsumerState<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends ConsumerState<AdminScreen> {
  NavTab _currentTab = NavTab.admin;
  bool _reportRequested =
      false; // tracks if the monthly report request was sent

  @override
  void initState() {
    super.initState();
    // fetch dashboard data immediately when the screen opens
    Future.microtask(() => ref.read(adminProvider.notifier).fetchDashboard());
  }

  @override
  Widget build(BuildContext context) {
    // if the user switched to settings tab show settings screen instead
    if (_currentTab == NavTab.settings) {
      return const SettingsScreen();
    }

    // keep watch the admin data to listen for any update
    final adminState = ref.watch(adminProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF9F5EF),
      body: SafeArea(
        child: adminState.isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
                // main column of the dashboard - each section stacked vertically
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'لوحة المدير',
                      style: AppTextStyles.h2.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildStatsRow(adminState),
                    const SizedBox(height: 16),
                    _buildMonthlyReportCard(),
                    const SizedBox(height: 20),
                    _buildQuickActions(adminState),
                    const SizedBox(height: 20),
                    _buildLeaderboard(adminState),
                    const SizedBox(height: 20),
                    _buildRecentActivity(adminState),
                  ],
                ),
              ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentTab: _currentTab,
        onTabSelected: (tab) => setState(() => _currentTab = tab),
      ),
    );
  }

  // convert an integer to Arabic numeral string (using ArabicUtils)
  String _intToArabic(int n) => ArabicUtils.fromInt(n);

  // === Stats Row - 4 cards in a row showing center-wide numbers ===
  // each card gets equal width via Expanded, with FittedBox to prevent overflow
  Widget _buildStatsRow(AdminState state) {
    // create the list of (value, label) pairs for each stat card
    final stats = [
      (_intToArabic(state.studentsCount), 'طالب'),
      (_intToArabic(state.circlesCount), 'حلقة'),
      (_intToArabic(state.sheikhsCount), 'محفظين'),
      ('${_intToArabic(state.attendancePercentage)}٪', 'حضور'),
    ];
    return Row(
      children: stats.map((s) {
        return Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 2),
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade100),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                ),
              ],
            ),
            // FittedBox scales the text down if it's wider than the card
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Column(
                children: [
                  Text(
                    s.$1,
                    style: AppTextStyles.h3.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    s.$2,
                    style: AppTextStyles.caption.copyWith(
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // === Monthly Report Card - request sheikhs to submit their monthly notes ===
  // two states: before request (golden) and after request (green with confirmation)
  Widget _buildMonthlyReportCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _reportRequested
            ? const Color(0xFFECFDF5)
            : const Color(0xFFFEFCE8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _reportRequested
              ? const Color(0xFFA7F3D0)
              : const Color(0xFFFDE68A),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _reportRequested
                      ? const Color(0xFF10B981)
                      : AppColors.gold,
                  borderRadius: BorderRadius.circular(12),
                ),
                // icon changes from notification bell to checkmark after request
                child: Icon(
                  _reportRequested
                      ? Icons.check_circle
                      : Icons.notifications_outlined,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'طلب التقرير الشهري',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'متاح أول ٥ أيام من الشهر',
                            style: AppTextStyles.caption.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 9,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _reportRequested
                          ? '✓ تم إرسال الطلب للمحفظين. سيصلك التقرير بعد إدخال ملاحظاتهم.'
                          : 'اضغط لإرسال إشعار للمحفظين بإدخال ملاحظاتهم الشهرية على الطلاب.',
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // if not requested show the request button, otherwise show waiting status
          if (!_reportRequested)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => setState(() => _reportRequested = true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.notifications_outlined, size: 18),
                label: Text(
                  'طلب تقرير مايو ٢٠٢٦',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'بانتظار ردود المحفظين (٠/٣)',
                  style: AppTextStyles.caption.copyWith(
                    color: const Color(0xFF047857),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 12,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'آخر موعد: ٥ يونيو',
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
        ],
      ),
    );
  }

  // === Quick Actions - shortcuts for common admin tasks ===
  // first row: new user + exam | second row: monthly report + certification
  // the certification card includes a badge showing unprinted certificates count
  Widget _buildQuickActions(AdminState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'إجراءات سريعة',
          style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                'تسجيل مستخدم جديد',
                Icons.people_outline,
                AppColors.primary,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildActionCard(
                'تسجيل اختبار 📝',
                Icons.assignment_outlined,
                const Color(0xFF2563EB),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                'تقرير شهري 📊',
                Icons.bar_chart_outlined,
                AppColors.gold,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildActionCard(
                'إصدار شهادات 🏅',
                Icons.emoji_events_outlined,
                const Color(0xFFF59E0B),
                // badge shows how many certificates are ready to print
                badge: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF59E0B),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${_intToArabic(state.certificationCount)} جاهزة',
                    style: AppTextStyles.caption.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 9,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: _buildActionCard(
            'إدارة الحلقات ⚙️',
            Icons.settings_outlined,
            Colors.grey.shade700,
          ),
        ),
      ],
    );
  }

  // === Action Card - reusable card for quick actions ===
  // each card has an icon container at top-left and a label below
  // optional badge widget can be passed to show a notification count etc
  Widget _buildActionCard(
    String label,
    IconData icon,
    Color color, {
    Widget? badge,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              // if a badge was provided show it at the top-right corner
              if (badge != null) badge,
            ],
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  // === Metric Badge - small colored tag used in the leaderboard ===
  // shows a number with Arabic numeral and a suffix like '٪' or just a label
  Widget _buildMetricBadge(
    int value,
    String label,
    Color color, {
    String suffix = '',
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '${_intToArabic(value)}$suffix',
        style: AppTextStyles.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 10,
        ),
      ),
    );
  }

  // === Leaderboard - top 5 students of the week ===
  // ranked by memo pages (first), then revision pages, then attendance rate
  // each row shows rank medal, student name, and three metric badges
  Widget _buildLeaderboard(AdminState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'أوائل المركز',
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: Text(
                'عرض الكل',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.gold,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // if there are no students yet show an empty state message
        if (state.leaderboard.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade100),
            ),
            child: Center(
              child: Text(
                'لا يوجد طلاب بعد',
                style: AppTextStyles.bodySmall.copyWith(
                  color: Colors.grey.shade400,
                ),
              ),
            ),
          )
        else
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade100),
            ),
            child: Column(
              children: List.generate(state.leaderboard.length, (i) {
                final s = state.leaderboard[i];
                final name = s['name'] as String? ?? '';
                // convert the float pages to int for badge display
                final memo = (s['memo'] as num?)?.toInt() ?? 0;
                final revision = (s['revision'] as num?)?.toInt() ?? 0;
                final attendance = s['attendance'] as int? ?? 0;
                final isLast = i == state.leaderboard.length - 1;
                // first three get gold/silver/bronze medals
                final medals = ['🥇', '🥈', '🥉'];
                final medal = i < 3 ? medals[i] : '';
                // subtle background colors for the top 3
                final bgColors = [
                  const Color(0xFFFFFBE6),
                  const Color(0xFFF5F5F5),
                  const Color(0xFFFFF3E0),
                ];
                final bg = i < 3 ? bgColors[i] : Colors.transparent;

                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: bg,
                    border: isLast
                        ? null
                        : Border(
                            bottom: BorderSide(color: Colors.grey.shade50),
                          ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            // rank badge - medal emoji for top 3, Arabic number for others
                            SizedBox(
                              width: 32,
                              height: 32,
                              child: Center(
                                child: medal.isNotEmpty
                                    ? Text(
                                        medal,
                                        style: const TextStyle(fontSize: 18),
                                      )
                                    : Text(
                                        _intToArabic(i + 1),
                                        style: AppTextStyles.caption.copyWith(
                                          color: Colors.grey.shade400,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // student name - flexible so it shrinks if needed
                            Flexible(
                              child: Text(
                                name,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // three metric badges: memo pages (green), revision (blue), attendance (amber)
                      _buildMetricBadge(memo, 'حفظ', const Color(0xFF10B981)),
                      const SizedBox(width: 4),
                      _buildMetricBadge(
                        revision,
                        'مراجعة',
                        const Color(0xFF3B82F6),
                      ),
                      const SizedBox(width: 4),
                      _buildMetricBadge(
                        attendance,
                        'حضور',
                        const Color(0xFFF59E0B),
                        suffix: '٪',
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
      ],
    );
  }

  // === Recent Activity - merged feed of latest events ===
  // combines recitation logs, nomination updates, and new user registrations
  // each event type gets a different icon and color based on keywords in the text
  Widget _buildRecentActivity(AdminState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'النشاط الأخير',
          style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 12),
        if (state.recentActivity.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade100),
            ),
            child: Center(
              child: Text(
                'لا يوجد نشاط حديث',
                style: AppTextStyles.bodySmall.copyWith(
                  color: Colors.grey.shade400,
                ),
              ),
            ),
          )
        else
          // map each activity item to a row with icon + text + timestamp
          ...state.recentActivity.map((a) {
            final text = a['text'] as String? ?? '';
            final time = a['time'] as String? ?? '';

            // determine icon and colors based on the event type keywords
            IconData icon;
            Color iconColor;
            Color bgColor;
            if (text.contains('اجتياز')) {
              // exam passed - green trophy
              icon = Icons.emoji_events;
              iconColor = const Color(0xFF10B981);
              bgColor = const Color(0xFFECFDF5);
            } else if (text.contains('رسوب')) {
              // exam failed - red cancel
              icon = Icons.cancel_outlined;
              iconColor = const Color(0xFFEF4444);
              bgColor = const Color(0xFFFEF2F2);
            } else if (text.contains('ترشيح') || text.contains('اعتماد')) {
              // nomination or approval - amber vote icon
              icon = Icons.how_to_vote_outlined;
              iconColor = const Color(0xFFF59E0B);
              bgColor = const Color(0xFFFFF8E1);
            } else if (text.contains('إضافة مستخدم')) {
              // new user - purple person-add
              icon = Icons.person_add_outlined;
              iconColor = const Color(0xFF8B5CF6);
              bgColor = const Color(0xFFF5F3FF);
            } else if (text.contains('غائب')) {
              // absent - grey person-off
              icon = Icons.person_off_outlined;
              iconColor = Colors.grey.shade500;
              bgColor = const Color(0xFFF5F5F5);
            } else {
              // default recitation - green book icon
              icon = Icons.menu_book_outlined;
              iconColor = const Color(0xFF10B981);
              bgColor = const Color(0xFFECFDF5);
            }

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade100),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // colored circle icon representing the event type
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: bgColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, size: 16, color: iconColor),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          text,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: Colors.grey.shade800,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          time,
                          style: AppTextStyles.caption.copyWith(
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }
}
