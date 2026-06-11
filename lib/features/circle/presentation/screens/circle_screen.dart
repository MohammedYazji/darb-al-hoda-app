import 'package:darb_al_hoda_app/core/utils/arabic_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/models/circle_model.dart';
import '../../../../features/auth/presentation/auth_provider.dart';
import '../../../../features/auth/presentation/screens/settings_screen.dart';
import '../../../../shared/widgets/bottom_nav_bar.dart';
import '../circle_provider.dart';

// === Nomination Type ===
enum NominationType { recitation, collective }

// === Local Nomination Model===
// save the data locally before send to api - to control ui
class LocalNomination {
  final int studentId;
  final String studentName;
  final NominationType type;
  final String juz;

  const LocalNomination({
    required this.studentId,
    required this.studentName,
    required this.type,
    required this.juz,
  });
}

class CircleScreen extends ConsumerStatefulWidget {
  const CircleScreen({super.key});

  @override
  ConsumerState<CircleScreen> createState() => _CircleScreenState();
}

class _CircleScreenState extends ConsumerState<CircleScreen> {
  NavTab _currentTab = NavTab.circles;

  final _searchController = TextEditingController();
  String _searchQuery = '';

  // List of nominations locally before send to the api
  final List<LocalNomination> _nominations = [];

  // Bottom Sheet state
  bool _sheetOpen = false;
  NominationType? _sheetType = null;
  CircleStudentModel? _sheetStudent = null;
  int? _selectedJuz = null;
  int? _selectedGroup = null;

  // Toast
  String? _toast;

  // Collective Juz
  List<Map<String, dynamic>> _getCollectiveGroups(CircleStudentModel student) {
    final memorized = student.memorized;
    final isKhatim = memorized == 30;
    final groups = <Map<String, dynamic>>[];

    if (isKhatim) {
      // تراكمي من جزء 30
      final sizes = [3, 5, 8, 10, 13, 15, 18, 20, 23, 25, 28, 30];
      for (final size in sizes) {
        final from = ArabicUtils.fromInt(30);
        final to = ArabicUtils.fromInt(30 - size + 1);
        groups.add({
          'label': ArabicUtils.toArabic('الأجزاء $to – $from'),
          'sub': ArabicUtils.toArabic('$size أجزاء تراكمية'),
          'juznumbers': List.generate(size, (i) => ArabicUtils.fromInt(30 - i)),
        });
      }
    } else {
      // separate groups 3 then 5 Juz
      // block 1: 30-26, block 2: 25-21, block 3: 20-16 ...
      int blockStart = 30;

      while (blockStart > 0) {
        final blockEnd = blockStart - 4; // 5 juz in each block

        // 3-juz test: First 3 Juz's from the block
        final threeEnd = blockStart - 2;
        final threeNeeded = 30 - threeEnd + 1; // How much Juz we need

        // The student must memorized them before collective exam
        if (memorized >= threeNeeded) {
          groups.add({
            'label': ArabicUtils.toArabic('الأجزاء $threeEnd – $blockStart'),
            'sub': ArabicUtils.toArabic('3 أجزاء'),
            'juznumbers': [blockStart, blockStart - 1, blockStart - 2],
          });
        }

        // 5-juz test: as a complete blocks
        final fiveNeeded = 30 - blockEnd + 1;
        if (blockEnd >= 1 && memorized >= fiveNeeded) {
          groups.add({
            'label': ArabicUtils.toArabic('الأجزاء $blockEnd – $blockStart'),
            'sub': '٥ أجزاء',
            'juznumbers': List.generate(5, (i) => blockStart - i),
          });
        }

        blockStart -= 5;
        if (blockStart <= 0) break;
      }
    }

    return groups;
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      // Get the auth user
      final user = ref.read(authProvider).user;
      // Then fetch his own circle
      if (user != null) {
        ref.read(circleProvider.notifier).fetchMyCircle(user.id);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // === Helpers ===
  bool _isNominated(int studentId, NominationType type) {
    return _nominations.any((n) => n.studentId == studentId && n.type == type);
  }

  void _openSheet(CircleStudentModel student, NominationType type) {
    if (_isNominated(student.id, type)) return;

    setState(() {
      _sheetOpen = true;
      _sheetType = type;
      _sheetStudent = student;
      // current juz will be (30 - count of memorized Juz's)
      // if the student memorized 3 Juz's so (30 - 3) = so the next will be the 27 Juz
      _selectedJuz = type == NominationType.recitation
          ? (student.memorized < 30 ? 30 - student.memorized : 1)
          : null;
      _selectedGroup = null;
    });
  }

  void _closeSheet() {
    setState(() {
      _sheetOpen = false;
      _sheetType = null;
      _sheetStudent = null;
    });
  }

  void _confirmNomination() {
    if (_sheetStudent == null || _sheetType == null) return;

    final juzLabel = _sheetType == NominationType.recitation
        ? ArabicUtils.toArabic('الجزء $_selectedJuz')
        : ArabicUtils.toArabic(
            _getCollectiveGroups(_sheetStudent!)[_selectedGroup!]['label']!,
          );

    final typeLabel = _sheetType == NominationType.recitation
        ? 'للسرد والاختبار'
        : 'لاختبار التثبيت';

    setState(() {
      _nominations.add(
        LocalNomination(
          studentId: _sheetStudent!.id,
          studentName: _sheetStudent!.name,
          type: _sheetType!,
          juz: juzLabel,
        ),
      );
      _toast = '✓ تم ترشيح ${_sheetStudent!.name} $typeLabel';
    });

    Future.delayed(const Duration(milliseconds: 2800), () {
      if (mounted) setState(() => _toast = null);
    });

    _closeSheet();

    // TODO: send to API
  }

  bool get _canConfirm {
    if (_sheetType == NominationType.recitation) return _selectedJuz != null;
    return _selectedGroup != null;
  }

  @override
  Widget build(BuildContext context) {
    // keep watch the circle data for any changes
    final circleState = ref.watch(circleProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F0),
      body: Stack(
        children: [
          // === Main Content ===
          _buildBody(circleState),

          // === Toast ===
          if (_toast != null) _buildToast(),

          // === Bottom Sheet ===
          if (_sheetOpen) ...[
            // Backdrop
            GestureDetector(
              onTap: _closeSheet,
              child: Container(color: Colors.black.withValues(alpha: 0.4)),
            ),
            // Sheet
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildBottomSheet(),
            ),
          ],
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        currentTab: _currentTab,
        onTabSelected: (tab) => setState(() => _currentTab = tab),
      ),
    );
  }

  // === Body ===
  Widget _buildBody(CircleState circleState) {
    if (_currentTab == NavTab.settings) {
      return const SettingsScreen();
    }

    if (circleState.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (circleState.error != null) {
      // TODO: make it global fn to use in every screen
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: AppColors.error, size: 48),
            const SizedBox(height: 16),
            Text(circleState.error!, style: AppTextStyles.bodyMedium),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                final user = ref.read(authProvider).user;
                if (user != null) {
                  ref.read(circleProvider.notifier).fetchMyCircle(user.id);
                }
              },
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      );
    }

    if (!circleState.hasData) return const SizedBox();

    final circle = circleState.circle!;
    final filtered = circle.students
        .where((s) => _searchQuery.isEmpty || s.name.contains(_searchQuery))
        .toList();

    return CustomScrollView(
      slivers: [
        // Header
        SliverToBoxAdapter(child: _buildHeader(circle)),

        // Nominations
        if (_nominations.isNotEmpty)
          SliverToBoxAdapter(child: _buildNominationsCard()),

        // Search
        SliverToBoxAdapter(child: _buildSearchBar()),

        // Students
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => _buildStudentCard(filtered[index], index + 1),
              childCount: filtered.length,
            ),
          ),
        ),
      ],
    );
  }

  // === Header ===
  Widget _buildHeader(CircleModel circle) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative circle
          Positioned(
            top: -32,
            right: -32,
            child: Container(
              width: 128,
              height: 128,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                circle.name,
                style: AppTextStyles.h2.copyWith(
                  color: AppColors.gold,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'المحفظ: ${circle.mainSheikh.name}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      ArabicUtils.toArabic('${circle.students.length} طالباً'),
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
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

  // === Nominations Card ===
  Widget _buildNominationsCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.list_alt_outlined,
                color: AppColors.gold,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                ArabicUtils.toArabic(
                  'الترشيحات الحالية (${_nominations.length})',
                ),
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ..._nominations.map((n) => _buildNominationItem(n)),
        ],
      ),
    );
  }

  Widget _buildNominationItem(LocalNomination n) {
    final isRecitation = n.type == NominationType.recitation;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isRecitation
                  ? const Color(0xFF2196F3)
                  : const Color(0xFF9C27B0),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              ArabicUtils.toArabic('${n.studentName} — ${n.juz}'),
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: isRecitation
                  ? const Color(0xFFE3F2FD)
                  : const Color(0xFFF3E5F5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              isRecitation ? 'سرد' : 'تثبيت',
              style: AppTextStyles.caption.copyWith(
                color: isRecitation
                    ? const Color(0xFF1565C0)
                    : const Color(0xFF6A1B9A),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // === Search Bar ===
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: TextField(
        controller: _searchController,
        onChanged: (v) => setState(() => _searchQuery = v),
        decoration: InputDecoration(
          hintText: 'ابحث عن طالب...',
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  // === Student Card ===
  Widget _buildStudentCard(CircleStudentModel student, int rank) {
    final nomRec = _isNominated(student.id, NominationType.recitation);
    final nomCol = _isNominated(student.id, NominationType.collective);
    final progress = student.memorized / 30;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8),
        ],
      ),
      child: Column(
        children: [
          // Student info row
          Row(
            children: [
              // Avatar
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.gold.withValues(alpha: 0.2),
                  border: Border.all(
                    color: AppColors.gold.withValues(alpha: 0.4),
                  ),
                ),
                child: Center(
                  child: Text(
                    student.name.substring(0, 1),
                    style: AppTextStyles.h3.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          student.name,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        // Badge for the first 3 students
                        if (rank <= 3)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.gold.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.emoji_events,
                                  color: AppColors.gold,
                                  size: 12,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  ArabicUtils.toArabic('#$rank'),
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppColors.gold,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          'ممتاز',
                          style: AppTextStyles.caption.copyWith(
                            color: Colors.grey.shade400,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          ArabicUtils.toArabic('${student.memorized} جزء'),
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          ArabicUtils.toArabic(
                            '· الجزء ${student.memorized + 1}',
                          ),
                          style: AppTextStyles.caption.copyWith(
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Progress bar — gradient
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Container(
              height: 6,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(4),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerRight,
                widthFactor: progress,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.gold],
                      begin: Alignment.centerRight,
                      end: Alignment.centerLeft,
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(4)),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Nomination buttons
          Row(
            children: [
              // recitation nomination
              Expanded(
                child: GestureDetector(
                  onTap: () => _openSheet(student, NominationType.recitation),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: nomRec ? const Color(0xFFE3F2FD) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF90CAF9),
                        width: 2,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.menu_book_outlined,
                          color: Color(0xFF1565C0),
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          nomRec ? 'مُرشَّح للسرد ✓' : 'رشّح للسرد',
                          style: AppTextStyles.caption.copyWith(
                            color: const Color(0xFF1565C0),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // confirmed nomination
              Expanded(
                child: GestureDetector(
                  onTap: () => _openSheet(student, NominationType.collective),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: nomCol ? const Color(0xFFF3E5F5) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFCE93D8),
                        width: 2,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.group_outlined,
                          color: Color(0xFF6A1B9A),
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          nomCol ? 'مُرشَّح للتثبيت ✓' : 'رشّح لتثبيت',
                          style: AppTextStyles.caption.copyWith(
                            color: const Color(0xFF6A1B9A),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // === Bottom Sheet ===
  Widget _buildBottomSheet() {
    final isRecitation = _sheetType == NominationType.recitation;
    final groups = _getCollectiveGroups(_sheetStudent!);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 4),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isRecitation
                          ? 'ترشيح للسرد والاختبار'
                          : 'ترشيح لاختبار التثبيت',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      'الطالب: ${_sheetStudent?.name}',
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: _closeSheet,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey.shade100,
                    ),
                    child: const Icon(
                      Icons.close,
                      size: 16,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Divider(color: Colors.grey.shade100, height: 1),

          // Content
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isRecitation
                      ? 'اختر الجزء المراد سرده واختباره'
                      : 'اختر مجموعة الأجزاء للاختبار المجتمع',
                  style: AppTextStyles.bodySmall.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Colors.grey.shade700,
                  ),
                ),

                const SizedBox(height: 12),

                // ── Recitation — Juz List ──
                if (isRecitation)
                  Container(
                    constraints: const BoxConstraints(maxHeight: 260),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade100, width: 2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: ListView.separated(
                        shrinkWrap: true,
                        // Number of memorized juz's + the current one they are working on
                        itemCount: ((_sheetStudent?.memorized ?? 0) < 30)
                            ? (_sheetStudent?.memorized ?? 0) + 1
                            : 30,
                        separatorBuilder: (_, __) =>
                            Divider(color: Colors.grey.shade50, height: 1),
                        itemBuilder: (context, index) {
                          // Start from 30 then go down
                          // index 0 = 30 Juz
                          // index 1 = 29 Juz
                          // and like this....
                          final juzNum = 30 - index;
                          final isSelected = _selectedJuz == juzNum;

                          return GestureDetector(
                            onTap: () => setState(() => _selectedJuz = juzNum),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFFE3F2FD)
                                    : Colors.white,
                                border: isSelected
                                    ? const Border(
                                        right: BorderSide(
                                          color: Color(0xFF2196F3),
                                          width: 4,
                                        ),
                                      )
                                    : null,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    ArabicUtils.toArabic('الجزء $juzNum'),
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: isSelected
                                          ? const Color(0xFF1565C0)
                                          : Colors.grey.shade700,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  if (isSelected)
                                    const Icon(
                                      Icons.check_circle,
                                      color: Color(0xFF2196F3),
                                      size: 20,
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                // ── Collective — Groups ──
                if (!isRecitation)
                  // TODO make the colors constants
                  Column(
                    children: groups.asMap().entries.map((entry) {
                      final index = entry.key;
                      final group = entry.value;
                      final isSelected = _selectedGroup == index;

                      return GestureDetector(
                        onTap: () => setState(() => _selectedGroup = index),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFFF3E5F5)
                                : Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFFCE93D8)
                                  : Colors.grey.shade100,
                              width: 2,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    group['label']!,
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: isSelected
                                          ? const Color(0xFF6A1B9A)
                                          : Colors.grey.shade700,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    group['sub']!,
                                    style: AppTextStyles.caption.copyWith(
                                      color: isSelected
                                          ? const Color(0xFF9C27B0)
                                          : Colors.grey.shade400,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isSelected
                                      ? const Color(0xFF9C27B0)
                                      : Colors.transparent,
                                  border: Border.all(
                                    color: isSelected
                                        ? const Color(0xFF9C27B0)
                                        : Colors.grey.shade300,
                                    width: 2,
                                  ),
                                ),
                                child: isSelected
                                    ? const Center(
                                        child: CircleAvatar(
                                          radius: 4,
                                          backgroundColor: Colors.white,
                                        ),
                                      )
                                    : null,
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                const SizedBox(height: 16),

                // Confirm Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _canConfirm ? _confirmNomination : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isRecitation
                          ? const Color(0xFF1565C0)
                          : const Color(0xFF6A1B9A),
                      disabledBackgroundColor: Colors.grey.shade100,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    icon: Icon(
                      isRecitation
                          ? Icons.menu_book_outlined
                          : Icons.group_outlined,
                      color: Colors.white,
                      size: 20,
                    ),
                    label: Text(
                      isRecitation
                          ? 'تأكيد ترشيح السرد'
                          : 'تأكيد ترشيح التثبيت',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
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

  // === Toast ===
  Widget _buildToast() {
    return Positioned(
      top: 80,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.gold.withValues(alpha: 0.4)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 12,
              ),
            ],
          ),
          child: Text(
            _toast!,
            style: AppTextStyles.bodySmall.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
