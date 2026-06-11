import 'dart:async';
import 'package:darb_al_hoda_app/core/local/connectivity_service.dart';
import 'package:darb_al_hoda_app/features/quran/presentation/quran_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/arabic_utils.dart';
import '../../../../core/utils/recitation_validator.dart';
import '../../../../features/auth/presentation/auth_provider.dart';
import '../../../../features/auth/presentation/screens/settings_screen.dart';
import '../../../../shared/widgets/bottom_nav_bar.dart';
import '../../../../core/models/recitation_session_model.dart';
import '../circle_provider.dart';
import '../recitation_provider.dart';

// === The main screen ===
class RecitationScreen extends ConsumerStatefulWidget {
  const RecitationScreen({super.key});

  @override
  ConsumerState<RecitationScreen> createState() => _RecitationScreenState();
}

class _RecitationScreenState extends ConsumerState<RecitationScreen> {
  // set the seikh circle to be the active one
  NavTab _currentTab = NavTab.recitation;

  // current day index 0=Sat … 4=Wed
  int _dayIndex = RecitationNotifier.todayDayIndex();

  // all data for all students in specific date, fetch once when the screen loading
  List<StudentRecord> _studentRecords = [];

  // track if the bottom sheet open, the current student id, and the form data temp
  bool _sheetOpen = false;
  int? _sheetStudentId = null;
  SessionRecord _form = const SessionRecord();

  // to show toast message after save the recitation data
  String? _toast;

  // Connectivity subscription for auto-sync
  StreamSubscription<bool>? _connectivitySub;

  // controllers for ayah inputs with arabic numeral support
  TextEditingController? _newFromAyahCtrl;
  TextEditingController? _newToAyahCtrl;
  TextEditingController? _revFromAyahCtrl;
  TextEditingController? _revToAyahCtrl;

  @override
  void dispose() {
    _connectivitySub?.cancel();
    _disposeAyahControllers();
    super.dispose();
  }

  void _disposeAyahControllers() {
    _newFromAyahCtrl?.dispose();
    _newToAyahCtrl?.dispose();
    _revFromAyahCtrl?.dispose();
    _revToAyahCtrl?.dispose();
    _newFromAyahCtrl = null;
    _newToAyahCtrl = null;
    _revFromAyahCtrl = null;
    _revToAyahCtrl = null;
  }

  void _initAyahControllers(SessionRecord form) {
    _disposeAyahControllers();
    _newFromAyahCtrl = TextEditingController(
      text: form.newFromAyah == null
          ? ''
          : ArabicUtils.fromInt(form.newFromAyah!),
    );
    _newToAyahCtrl = TextEditingController(
      text: form.newToAyah == null ? '' : ArabicUtils.fromInt(form.newToAyah!),
    );
    _revFromAyahCtrl = TextEditingController(
      text: form.revFromAyah == null
          ? ''
          : ArabicUtils.fromInt(form.revFromAyah!),
    );
    _revToAyahCtrl = TextEditingController(
      text: form.revToAyah == null ? '' : ArabicUtils.fromInt(form.revToAyah!),
    );
  }

  void _showToast(String message) {
    setState(() => _toast = message);
    Future.delayed(const Duration(milliseconds: 2800), () {
      if (mounted) setState(() => _toast = null);
    });
  }

  @override
  void initState() {
    super.initState();
    // microtask: to ensure ref is ready after initState
    Future.microtask(() async {
      final user = ref.read(authProvider).user;
      if (user != null) {
        await ref.read(circleProvider.notifier).fetchMyCircle(user.id);
      }
      ref.read(quranProvider.notifier).fetchSurahs();
      if (ref.read(circleProvider).hasData) {
        _loadDayLogs();
      }
    });

    // Auto-sync pending records when connectivity returns
    _connectivitySub = ConnectivityService.onlineStream.listen((isOnline) {
      if (isOnline) {
        ref.read(recitationProvider.notifier).syncPendingLogs();
      }
    });
  }

  // fetch logs for the selected day from api
  Future<void> _loadDayLogs() async {
    final circle = ref.read(circleProvider).circle;
    if (circle == null) return;

    final date = RecitationNotifier.dateForDayIndex(_dayIndex);

    try {
      final logs = await ref
          .read(recitationProvider.notifier)
          .fetchLogs(circleId: circle.id, date: date);

      final merged = RecitationNotifier.mergeStudentsWithLogs(
        circle.students,
        logs,
      );
      final withSuggestions = await ref
          .read(recitationProvider.notifier)
          .applyNextAyahSuggestions(merged);

      if (!mounted) return;
      setState(() => _studentRecords = withSuggestions);
    } catch (_) {
      if (!mounted) return;
      _showToast(ref.read(recitationProvider).error ?? 'فشل تحميل السجل');
    }
  }

  // save logs for the selected day to api
  Future<void> _saveDayLogs() async {
    final circle = ref.read(circleProvider).circle;
    if (circle == null) return;

    final date = RecitationNotifier.dateForDayIndex(_dayIndex);

    try {
      final message = await ref
          .read(recitationProvider.notifier)
          .saveLogs(
            circleId: circle.id,
            date: date,
            records: _studentRecords,
            ayahCountForSurah: (n) =>
                ref.read(quranProvider.notifier).getAyahCount(n),
          );

      if (!mounted) return;
      _showToast('✓ $message');
    } catch (e) {
      if (!mounted) return;
      final msg = e is Exception && e.toString().startsWith('Exception: ')
          ? e.toString().replaceFirst('Exception: ', '')
          : ref.read(recitationProvider).error ?? 'فشل حفظ السجل';
      _showToast(msg);
    }
  }

  // open sheet for specific student recitation form
  void _openSheet(int studentId) {
    final record = _studentRecords.firstWhere((r) => r.student.id == studentId);
    if (record.presentNotRecited) {
      _showToast('اختر «تسجيل التسميع» بعد إلغاء «لم يسمع الاثنين»');
      return;
    }

    var form = record.session ?? const SessionRecord();
    if (record.skipNewMemo) form = form.withoutNewMemo();
    if (record.skipRevision) form = form.withoutRevision();

    _initAyahControllers(form);
    setState(() {
      _sheetOpen = true;
      _sheetStudentId = studentId;
      _form = form;
    });
  }

  // close bottom sheet and dispose controllers
  void _closeSheet() {
    _disposeAyahControllers();
    setState(() {
      _sheetOpen = false;
      _sheetStudentId = null;
    });
  }

  void _markPresentNotRecited(int studentId) {
    setState(() {
      final record = _studentRecords.firstWhere(
        (r) => r.student.id == studentId,
      );
      record.presentNotRecited = true;
      record.skipNewMemo = true;
      record.skipRevision = true;
      record.isSuggestion = false;
      record.session = null;
      record.absence = AbsenceType.none;
    });
    _showToast('تم: حضر ولم يسمع الحفظ ولا المراجعة');
  }

  void _markSkipNewMemo(int studentId) {
    setState(() {
      final record = _studentRecords.firstWhere(
        (r) => r.student.id == studentId,
      );
      record.presentNotRecited = false;
      record.skipNewMemo = true;
      record.isSuggestion = false;
      record.session = (record.session ?? const SessionRecord())
          .withoutNewMemo();
    });
    _showToast('تم: لم يسمع حفظاً جديداً');
  }

  void _markSkipRevision(int studentId) {
    setState(() {
      final record = _studentRecords.firstWhere(
        (r) => r.student.id == studentId,
      );
      record.presentNotRecited = false;
      record.skipRevision = true;
      record.isSuggestion = false;
      record.session = (record.session ?? const SessionRecord())
          .withoutRevision();
    });
    _showToast('تم: لم يسمع مراجعة');
  }

  void _clearHearingFlags(int studentId) {
    setState(() {
      final record = _studentRecords.firstWhere(
        (r) => r.student.id == studentId,
      );
      record.presentNotRecited = false;
      record.skipNewMemo = false;
      record.skipRevision = false;
    });
  }

  // copy _form to student record, clear absence, show toast, close sheet
  void _saveSession() {
    final record = _studentRecords.firstWhere(
      (r) => r.student.id == _sheetStudentId,
    );

    final validationError = RecitationValidator.validatePresentSession(
      _form,
      (n) => ref.read(quranProvider.notifier).getAyahCount(n),
      skipNewMemo: record.skipNewMemo,
      skipRevision: record.skipRevision,
    );
    if (validationError != null) {
      _showToast(validationError);
      return;
    }

    setState(() {
      record.session = _form;
      record.absence = AbsenceType.none;
      record.isSuggestion = false;
      record.presentNotRecited = false;
    });

    _showToast('✓ تم حفظ تسميع ${record.student.name}');
    _closeSheet();
  }

  // set student absence: absent / excused / none — clears session when absent
  void _setAbsence(int studentId, AbsenceType type) {
    setState(() {
      final record = _studentRecords.firstWhere(
        (r) => r.student.id == studentId,
      );
      record.absence = type;
      if (type != AbsenceType.none) {
        record.session = null;
        record.isSuggestion = false;
        record.presentNotRecited = false;
        record.skipNewMemo = false;
        record.skipRevision = false;
      }
    });
  }

  int get _recorded => _studentRecords
      .where((r) => r.hasRecitation || r.presentNotRecited)
      .length;
  int get _absent =>
      _studentRecords.where((r) => r.absence == AbsenceType.absent).length;
  int get _excused =>
      _studentRecords.where((r) => r.absence == AbsenceType.excused).length;
  int get _pending => _studentRecords
      .where(
        (r) =>
            !r.hasRecitation &&
            !r.presentNotRecited &&
            r.absence == AbsenceType.none,
      )
      .length;

  // header stats counters
  static const _monthNames = [
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

  String _selectedDateLabel() {
    final date = RecitationNotifier.dateTimeForDayIndex(_dayIndex);
    return '${AppConstants.recitationDays[_dayIndex]} · '
        '${ArabicUtils.fromInt(date.day)} ${_monthNames[date.month - 1]} '
        '${ArabicUtils.fromInt(date.year)}';
  }

  String _shortDateLabel(int dayIndex) {
    final date = RecitationNotifier.dateTimeForDayIndex(dayIndex);
    return '${ArabicUtils.fromInt(date.day)}/${ArabicUtils.fromInt(date.month)}';
  }

  String _surahName(int? surahNumber) {
    if (surahNumber == null) return '';
    return ref.read(quranProvider.notifier).getSurah(surahNumber)?.name ?? '';
  }

  String _formatMemorizationRange({
    int? fromSurah,
    int? fromAyah,
    int? toSurah,
    int? toAyah,
  }) {
    final fromName = _surahName(fromSurah);
    final toName = _surahName(toSurah);
    final fromAyahStr = fromAyah != null ? ArabicUtils.fromInt(fromAyah) : '';
    final toAyahStr = toAyah != null ? ArabicUtils.fromInt(toAyah) : '';

    if (fromSurah != null && fromSurah == toSurah) {
      return '$fromName $fromAyahStr–$toAyahStr'.trim();
    }
    return '$fromName $fromAyahStr — $toName $toAyahStr'.trim();
  }

  // === Build ===
  @override
  Widget build(BuildContext context) {
    final circleState = ref.watch(circleProvider);
    final recitationState = ref.watch(recitationProvider);
    ref.watch(quranProvider);

    ref.listen<CircleState>(circleProvider, (previous, next) {
      if (next.hasData && previous?.circle?.id != next.circle?.id) {
        _loadDayLogs();
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF9F5EF),
      body: Stack(
        children: [
          _buildBody(circleState, recitationState),
          if (_sheetOpen) ...[
            GestureDetector(
              onTap: _closeSheet,
              child: Container(color: Colors.black.withValues(alpha: 0.4)),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildBottomSheet(),
            ),
          ],
          if (_toast != null) _buildToast(),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        currentTab: _currentTab,
        onTabSelected: (tab) => setState(() => _currentTab = tab),
      ),
    );
  }

  Widget _buildBody(CircleState circleState, RecitationState recitationState) {
    if (_currentTab == NavTab.settings) {
      return const SettingsScreen();
    }

    if (circleState.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (circleState.error != null) {
      return Center(
        child: Text(circleState.error!, style: AppTextStyles.bodyMedium),
      );
    }

    if (!circleState.hasData) return const SizedBox();

    // main content: circle info, student list, save bar
    final circle = circleState.circle!;

    return Column(
      children: [
        _buildStickyHeader(circle),

        // ── Pending-sync banner ──
        if (recitationState.pendingSyncCount > 0)
          _buildPendingSyncBanner(recitationState.pendingSyncCount),

        Expanded(
          child: recitationState.isLoading && _studentRecords.isEmpty
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                  itemCount: _studentRecords.length,
                  itemBuilder: (context, index) =>
                      _buildStudentCard(_studentRecords[index]),
                ),
        ),
        _buildSaveBar(recitationState.isSaving),
      ],
    );
  }

  // sticky header: circle info, day picker, stats row
  Widget _buildStickyHeader(circle) {
    return Container(
      color: const Color(0xFFF9F5EF),
      padding: const EdgeInsets.fromLTRB(16, 48, 16, 12),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'حلقتك',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.gold,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      circle.name,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'المحفظ',
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
                    ),
                    Text(
                      circle.mainSheikh.name,
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            _selectedDateLabel(),
            textAlign: TextAlign.center,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              for (var i = 0; i < AppConstants.recitationDays.length; i++) ...[
                if (i > 0) const SizedBox(width: 4),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      if (_dayIndex == i) return;
                      setState(() => _dayIndex = i);
                      _loadDayLogs();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: _dayIndex == i
                            ? AppColors.primary
                            : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _dayIndex == i
                              ? AppColors.primary
                              : Colors.grey.shade200,
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            AppConstants.recitationDays[i],
                            textAlign: TextAlign.center,
                            style: AppTextStyles.caption.copyWith(
                              color: _dayIndex == i
                                  ? Colors.white
                                  : Colors.grey.shade600,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _shortDateLabel(i),
                            textAlign: TextAlign.center,
                            style: AppTextStyles.caption.copyWith(
                              fontSize: 10,
                              color: _dayIndex == i
                                  ? Colors.white.withValues(alpha: 0.85)
                                  : Colors.grey.shade400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStat(
                'سُجّل: ${ArabicUtils.fromInt(_recorded)}/${ArabicUtils.fromInt(_studentRecords.length)}',
                AppColors.primary,
              ),
              _buildStat(
                'غائب: ${ArabicUtils.fromInt(_absent)}',
                const Color(0xFFEF5350),
              ),
              _buildStat(
                'معذور: ${ArabicUtils.fromInt(_excused)}',
                const Color(0xFFF59E0B),
              ),
              _buildStat(
                'لم يسمع: ${ArabicUtils.fromInt(_pending)}',
                Colors.grey.shade400,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String text, Color color) {
    return Text(
      text,
      style: AppTextStyles.caption.copyWith(
        color: color,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  /// Amber banner shown when there are locally saved but unsynced days.
  Widget _buildPendingSyncBanner(int count) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFDE68A), width: 1.5),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.cloud_upload_outlined,
            color: Color(0xFFF59E0B),
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              ArabicUtils.toArabic(
                'يوجد ${count == 1 ? 'يوم' : '$count أيام'} غير مزامنة · سيُرسل تلقائياً عند الاتصال',
              ),
              style: AppTextStyles.caption.copyWith(
                color: const Color(0xFF92400E),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          GestureDetector(
            onTap: () =>
                ref.read(recitationProvider.notifier).syncPendingLogs(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'مزامنة',
                style: AppTextStyles.caption.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // student card
  Widget _buildStudentCard(StudentRecord record) {
    final student = record.student;
    final isAbsent = record.absence == AbsenceType.absent;
    final isExcused = record.absence == AbsenceType.excused;
    final hasSession = record.hasRecitation;

    Color borderColor = Colors.grey.shade100;
    if (isAbsent) borderColor = const Color(0xFFFFCDD2);
    if (isExcused) borderColor = const Color(0xFFFFF3E0);
    if (hasSession) borderColor = const Color(0xFFC8E6C9);

    Color avatarBg = AppColors.gold.withValues(alpha: 0.2);
    Color avatarText = AppColors.primary;
    if (isAbsent) {
      avatarBg = const Color(0xFFFFCDD2);
      avatarText = const Color(0xFFEF5350);
    }
    if (isExcused) {
      avatarBg = const Color(0xFFFFF3E0);
      avatarText = const Color(0xFFF59E0B);
    }
    if (hasSession) {
      avatarBg = const Color(0xFFC8E6C9);
      avatarText = const Color(0xFF2E7D32);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 2),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: avatarBg,
                  ),
                  child: Center(
                    child: Text(
                      student.name.substring(0, 1),
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: avatarText,
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
                      Text(
                        student.name,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (hasSession)
                        Text(
                          record.session!.grade.isNotEmpty
                              ? record.session!.grade
                              : 'تم التسجيل',
                          style: AppTextStyles.caption.copyWith(
                            color: const Color(0xFF2E7D32),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      if (isAbsent)
                        Text(
                          'غائب بدون عذر',
                          style: AppTextStyles.caption.copyWith(
                            color: const Color(0xFFEF5350),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      if (isExcused)
                        Text(
                          'غائب معذور',
                          style: AppTextStyles.caption.copyWith(
                            color: const Color(0xFFF59E0B),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      if (record.presentNotRecited)
                        Text(
                          'حضر · لم يسمع حفظاً ولا مراجعة',
                          style: AppTextStyles.caption.copyWith(
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      if (!record.presentNotRecited &&
                          record.skipNewMemo &&
                          !record.skipRevision)
                        Text(
                          'لم يسمع حفظاً جديداً',
                          style: AppTextStyles.caption.copyWith(
                            color: const Color(0xFF1565C0),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      if (!record.presentNotRecited &&
                          record.skipRevision &&
                          !record.skipNewMemo)
                        Text(
                          'لم يسمع مراجعة',
                          style: AppTextStyles.caption.copyWith(
                            color: const Color(0xFF2E7D32),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      if (record.hasSuggestion)
                        Text(
                          'مقترح من آخر تسميع — أكّد أو عدّل',
                          style: AppTextStyles.caption.copyWith(
                            color: const Color(0xFF1565C0),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      if (!hasSession &&
                          !record.presentNotRecited &&
                          !record.hasSuggestion &&
                          !record.skipNewMemo &&
                          !record.skipRevision &&
                          !isAbsent &&
                          !isExcused)
                        Text(
                          'لم يسمع بعد',
                          style: AppTextStyles.caption.copyWith(
                            color: Colors.grey.shade400,
                          ),
                        ),
                    ],
                  ),
                ),
                if (hasSession)
                  const Icon(
                    Icons.check_circle,
                    color: Color(0xFF4CAF50),
                    size: 22,
                  ),
                if (isAbsent)
                  const Text(
                    '✗',
                    style: TextStyle(color: Color(0xFFEF5350), fontSize: 20),
                  ),
                if (isExcused)
                  const Text(
                    '⚠',
                    style: TextStyle(color: Color(0xFFF59E0B), fontSize: 18),
                  ),
              ],
            ),
            if (hasSession) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  if (RecitationValidator.hasCompleteNewMemo(record.session!))
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE3F2FD),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'حفظ جديد',
                              style: AppTextStyles.caption.copyWith(
                                color: const Color(0xFF1565C0),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              _formatMemorizationRange(
                                fromSurah: record.session!.newFromSurah,
                                fromAyah: record.session!.newFromAyah,
                                toSurah: record.session!.newToSurah,
                                toAyah: record.session!.newToAyah,
                              ),
                              style: AppTextStyles.caption.copyWith(
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (RecitationValidator.hasCompleteNewMemo(record.session!) &&
                      RecitationValidator.hasCompleteRevision(record.session!))
                    const SizedBox(width: 8),
                  if (RecitationValidator.hasCompleteRevision(record.session!))
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'مراجعة',
                              style: AppTextStyles.caption.copyWith(
                                color: const Color(0xFF2E7D32),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              _formatMemorizationRange(
                                fromSurah: record.session!.revFromSurah,
                                fromAyah: record.session!.revFromAyah,
                                toSurah: record.session!.revToSurah,
                                toAyah: record.session!.revToAyah,
                              ),
                              style: AppTextStyles.caption.copyWith(
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ],
            const SizedBox(height: 10),
            if (!isAbsent && !isExcused) ...[
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  _buildHearingChip(
                    label: 'لم يسمع حفظ',
                    selected: record.skipNewMemo && !record.presentNotRecited,
                    onTap: () => _markSkipNewMemo(student.id),
                  ),
                  _buildHearingChip(
                    label: 'لم يسمع مراجعة',
                    selected: record.skipRevision && !record.presentNotRecited,
                    onTap: () => _markSkipRevision(student.id),
                  ),
                  _buildHearingChip(
                    label: 'لم يسمع الاثنين',
                    selected: record.presentNotRecited,
                    onTap: () => _markPresentNotRecited(student.id),
                  ),
                  if (record.skipNewMemo ||
                      record.skipRevision ||
                      record.presentNotRecited)
                    _buildHearingChip(
                      label: 'إلغاء',
                      selected: false,
                      onTap: () => _clearHearingFlags(student.id),
                    ),
                ],
              ),
              const SizedBox(height: 10),
            ],
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: (isAbsent || isExcused || record.presentNotRecited)
                        ? null
                        : () => _openSheet(student.id),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: (isAbsent || isExcused)
                            ? Colors.grey.shade50
                            : hasSession
                            ? const Color(0xFFE8F5E9)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: (isAbsent || isExcused)
                              ? Colors.grey.shade100
                              : hasSession
                              ? const Color(0xFFA5D6A7)
                              : AppColors.primary.withValues(alpha: 0.3),
                          width: 2,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.edit_outlined,
                            size: 14,
                            color: (isAbsent || isExcused)
                                ? Colors.grey.shade300
                                : hasSession
                                ? const Color(0xFF2E7D32)
                                : AppColors.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            hasSession ? 'تعديل التسميع' : 'تسجيل التسميع',
                            style: AppTextStyles.caption.copyWith(
                              color: (isAbsent || isExcused)
                                  ? Colors.grey.shade300
                                  : hasSession
                                  ? const Color(0xFF2E7D32)
                                  : AppColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _buildAbsenceDropdown(student.id, record.absence),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHearingChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.12)
              : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? AppColors.primary : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: selected ? AppColors.primary : Colors.grey.shade600,
            fontWeight: FontWeight.w700,
            fontSize: 11,
          ),
        ),
      ),
    );
  }

  Widget _buildAbsenceDropdown(int studentId, AbsenceType current) {
    String label = 'الحضور';
    Color color = Colors.grey.shade400;
    Color bg = Colors.white;
    Color border = Colors.grey.shade200;

    if (current == AbsenceType.absent) {
      label = 'غائب';
      color = const Color(0xFFEF5350);
      bg = const Color(0xFFFFEBEE);
      border = const Color(0xFFFFCDD2);
    } else if (current == AbsenceType.excused) {
      label = 'معذور';
      color = const Color(0xFFF59E0B);
      bg = const Color(0xFFFFFBEB);
      border = const Color(0xFFFDE68A);
    }

    return PopupMenuButton<AbsenceType>(
      onSelected: (value) => _setAbsence(studentId, value),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      itemBuilder: (_) => [
        PopupMenuItem(
          value: AbsenceType.absent,
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFEF5350),
                ),
              ),
              const SizedBox(width: 8),
              const Text('غائب بدون عذر'),
            ],
          ),
        ),
        PopupMenuItem(
          value: AbsenceType.excused,
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFF59E0B),
                ),
              ),
              const SizedBox(width: 8),
              const Text('غائب معذور'),
            ],
          ),
        ),
        if (current != AbsenceType.none)
          PopupMenuItem(
            value: AbsenceType.none,
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey.shade300,
                  ),
                ),
                const SizedBox(width: 8),
                const Text('إلغاء'),
              ],
            ),
          ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: border, width: 2),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.keyboard_arrow_down, color: color, size: 14),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSheet() {
    final record = _studentRecords.firstWhere(
      (r) => r.student.id == _sheetStudentId,
    );

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
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 4),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'تسجيل التسميع',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      '${record.student.name} · ${_selectedDateLabel()}',
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
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.72,
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!record.skipNewMemo) ...[
                    _buildSectionHeader(
                      'حفظ جديد',
                      const Color(0xFF1565C0),
                      const Color(0xFF2196F3),
                    ),
                    const SizedBox(height: 8),
                    _buildMemorizationSection(isNew: true),
                    const SizedBox(height: 16),
                  ] else
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        'لم يسمع حفظاً جديداً (محّدد من البطاقة)',
                        style: AppTextStyles.caption.copyWith(
                          color: const Color(0xFF1565C0),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  if (!record.skipRevision) ...[
                    _buildSectionHeader(
                      'مراجعة',
                      const Color(0xFF2E7D32),
                      const Color(0xFF4CAF50),
                    ),
                    const SizedBox(height: 8),
                    _buildMemorizationSection(isNew: false),
                  ] else
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        'لم يسمع مراجعة (محّدد من البطاقة)',
                        style: AppTextStyles.caption.copyWith(
                          color: const Color(0xFF2E7D32),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  Text(
                    'التقدير العام للجلسة',
                    style: AppTextStyles.caption.copyWith(
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: AppConstants.recitationGrades.map((g) {
                      final selected = _form.grade == g;
                      return GestureDetector(
                        onTap: () =>
                            setState(() => _form = _form.copyWith(grade: g)),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: selected ? AppColors.primary : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: selected
                                  ? AppColors.primary
                                  : Colors.grey.shade200,
                              width: 2,
                            ),
                          ),
                          child: Text(
                            g,
                            style: AppTextStyles.caption.copyWith(
                              color: selected
                                  ? Colors.white
                                  : Colors.grey.shade600,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _saveSession,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      icon: const Icon(
                        Icons.check_circle_outline,
                        color: Colors.white,
                      ),
                      label: Text(
                        'حفظ التسميع',
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
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color dark, Color light) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(shape: BoxShape.circle, color: light),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: AppTextStyles.bodySmall.copyWith(
            color: dark,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildMemorizationSection({required bool isNew}) {
    final bgColor = isNew ? const Color(0xFFE3F2FD) : const Color(0xFFE8F5E9);
    final focusColor = isNew
        ? const Color(0xFF2196F3)
        : const Color(0xFF4CAF50);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'من سورة',
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    _buildSurahDropdown(
                      value: isNew ? _form.newFromSurah : _form.revFromSurah,
                      onChanged: (v) => setState(() {
                        _form = isNew
                            ? _form.copyWith(newFromSurah: v)
                            : _form.copyWith(revFromSurah: v);
                      }),
                      focusColor: focusColor,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'آية',
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    _buildAyahField(
                      controller: isNew ? _newFromAyahCtrl! : _revFromAyahCtrl!,
                      onChanged: (v) => setState(() {
                        _form = isNew
                            ? _form.copyWith(newFromAyah: v)
                            : _form.copyWith(revFromAyah: v);
                      }),
                      focusColor: focusColor,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'إلى سورة',
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    _buildSurahDropdown(
                      value: isNew ? _form.newToSurah : _form.revToSurah,
                      onChanged: (v) => setState(() {
                        _form = isNew
                            ? _form.copyWith(newToSurah: v)
                            : _form.copyWith(revToSurah: v);
                      }),
                      focusColor: focusColor,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'آية',
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    _buildAyahField(
                      controller: isNew ? _newToAyahCtrl! : _revToAyahCtrl!,
                      onChanged: (v) => setState(() {
                        _form = isNew
                            ? _form.copyWith(newToAyah: v)
                            : _form.copyWith(revToAyah: v);
                      }),
                      focusColor: focusColor,
                    ),
                  ],
                ),
              ),
            ],
          ),
          _buildRangeHint(isNew: isNew),
        ],
      ),
    );
  }

  Widget _buildRangeHint({required bool isNew}) {
    final fromSurah = isNew ? _form.newFromSurah : _form.revFromSurah;
    final fromAyah = isNew ? _form.newFromAyah : _form.revFromAyah;
    final toSurah = isNew ? _form.newToSurah : _form.revToSurah;
    final toAyah = isNew ? _form.newToAyah : _form.revToAyah;

    final allFilled =
        fromSurah != null &&
        fromAyah != null &&
        toSurah != null &&
        toAyah != null;
    if (!allFilled) return const SizedBox.shrink();

    final error = RecitationValidator.liveValidateRange(
      fromSurah: fromSurah,
      fromAyah: fromAyah,
      toSurah: toSurah,
      toAyah: toAyah,
    );

    final isValid = error == null;

    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isValid ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isValid ? const Color(0xFFA5D6A7) : const Color(0xFFEF9A9A),
          ),
        ),
        child: Row(
          children: [
            Icon(
              isValid
                  ? Icons.check_circle_outline
                  : Icons.warning_amber_rounded,
              size: 16,
              color: isValid
                  ? const Color(0xFF2E7D32)
                  : const Color(0xFFD32F2F),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                isValid ? 'النطاق صحيح ✓' : error,
                style: AppTextStyles.caption.copyWith(
                  color: isValid
                      ? const Color(0xFF2E7D32)
                      : const Color(0xFFD32F2F),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSurahDropdown({
    required int? value,
    required Function(int) onChanged,
    required Color focusColor,
  }) {
    final quranState = ref.watch(quranProvider);
    final surahs = quranState.surahs;

    if (quranState.isLoading || surahs.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: const Center(
          child: SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    final selected = value ?? surahs.first.number;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: DropdownButton<int>(
        value: selected,
        isExpanded: true,
        underline: const SizedBox(),
        style: AppTextStyles.caption.copyWith(color: Colors.grey.shade800),
        onChanged: (v) => v != null ? onChanged(v) : null,
        items: surahs
            .map(
              (s) => DropdownMenuItem(
                value: s.number,
                child: Text(s.name, style: AppTextStyles.caption),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildAyahField({
    required TextEditingController controller,
    required Function(int?) onChanged,
    required Color focusColor,
  }) {
    return TextField(
      controller: controller,
      onChanged: (v) => onChanged(ArabicUtils.parseInt(v)),
      textAlign: TextAlign.center,
      keyboardType: TextInputType.number,
      style: AppTextStyles.caption,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: focusColor, width: 2),
        ),
      ),
    );
  }

  // bottom save bar to submit all records for the selected day
  Widget _buildSaveBar(bool isSaving) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: isSaving ? null : _saveDayLogs,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.gold,
          foregroundColor: AppColors.primary,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        icon: isSaving
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primary,
                ),
              )
            : const Icon(Icons.menu_book_outlined),
        label: Text(
          'حفظ ${_selectedDateLabel()} (${ArabicUtils.fromInt(_recorded)} طالب)',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }

  // floating toast for feedback messages
  Widget _buildToast() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 12,
      left: 16,
      right: 16,
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(16),
        color: AppColors.primary,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Text(
            _toast!,
            textAlign: TextAlign.center,
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
