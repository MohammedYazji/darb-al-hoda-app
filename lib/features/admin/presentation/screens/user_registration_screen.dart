import 'package:darb_al_hoda_app/core/constants/app_colors.dart';
import 'package:darb_al_hoda_app/core/constants/app_text_styles.dart';
import 'package:darb_al_hoda_app/features/admin/presentation/user_management_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// === Role mapping to match backend Spatie roles ===

// all the available roles in the system - maps to backend Spatie roles
enum UserRoleType {
  student,
  circleSheikh,
  assistantCircleSheikh,
  recitationSheikh,
  individualExamSheikh,
  collectiveExamSheikh,
  courseInstructor,
  admin,
}

// map each role enum to its backend string
const _roleToApi = <UserRoleType, String>{
  UserRoleType.student: 'student',
  UserRoleType.circleSheikh: 'circle_sheikh',
  UserRoleType.assistantCircleSheikh: 'assistant_circle_sheikh',
  UserRoleType.recitationSheikh: 'recitation_sheikh',
  UserRoleType.individualExamSheikh: 'individual_exam_sheikh',
  UserRoleType.collectiveExamSheikh: 'collective_exam_sheikh',
  UserRoleType.courseInstructor: 'course_instructor',
  UserRoleType.admin: 'admin',
};

// convert a role enum to the api string
String _apiRole(UserRoleType k) => _roleToApi[k]!;
// convert an api role string back to the enum
UserRoleType _fromApiRole(String r) {
  return _roleToApi.entries
      .firstWhere(
        (e) => e.value == r,
        orElse: () => MapEntry(UserRoleType.student, ''),
      )
      .key;
}

// visual definition for each role - label, icon, colors
class RoleDef {
  final UserRoleType key;
  final String label;
  final String sublabel;
  final IconData icon;
  final Color color;
  final Color bg;
  final Color border;
  const RoleDef({
    required this.key,
    required this.label,
    required this.sublabel,
    required this.icon,
    required this.color,
    required this.bg,
    required this.border,
  });
}

// visual definitions for each role card in the ui
const _roleDefs = [
  RoleDef(
    key: UserRoleType.student,
    label: 'طالب',
    sublabel: 'يحضر حلقة الحفظ أو الدورة',
    icon: Icons.person_outline,
    color: Color(0xFF1D4ED8),
    bg: Color(0xFFEFF6FF),
    border: Color(0xFF93C5FD),
  ),
  RoleDef(
    key: UserRoleType.circleSheikh,
    label: 'محفظ حلقة',
    sublabel: 'يدرّس الطلاب في الحلقة',
    icon: Icons.menu_book_outlined,
    color: Color(0xFF1a5c38),
    bg: Color(0xFFECFDF5),
    border: Color(0xFF6EE7B7),
  ),
  RoleDef(
    key: UserRoleType.assistantCircleSheikh,
    label: 'محفظ حلقة مساعد',
    sublabel: 'يساعد في تدريس الحلقة',
    icon: Icons.assistant_navigation,
    color: Color(0xFF05834d),
    bg: Color(0xFFE8F5E9),
    border: Color(0xFF81C784),
  ),
  RoleDef(
    key: UserRoleType.recitationSheikh,
    label: 'شيخ سرد',
    sublabel: 'يتسمع الطلاب قبل الاختبار الفردي',
    icon: Icons.hearing_outlined,
    color: Color(0xFF0D9488),
    bg: Color(0xFFF0FDFA),
    border: Color(0xFF5EEAD4),
  ),
  RoleDef(
    key: UserRoleType.individualExamSheikh,
    label: 'شيخ اختبار منفرد',
    sublabel: 'يختبر الطالب بشكل فردي',
    icon: Icons.record_voice_over_outlined,
    color: Color(0xFF7C3AED),
    bg: Color(0xFFF5F3FF),
    border: Color(0xFFC4B5FD),
  ),
  RoleDef(
    key: UserRoleType.collectiveExamSheikh,
    label: 'شيخ اختبار مجتمعة',
    sublabel: 'يختبر مجموعة من الطلاب معاً',
    icon: Icons.groups_outlined,
    color: Color(0xFFDC2626),
    bg: Color(0xFFFEF2F2),
    border: Color(0xFFFECACA),
  ),
  RoleDef(
    key: UserRoleType.courseInstructor,
    label: 'مدرّس دورة',
    sublabel: 'يدرّس دورة التجويد أو الأحكام',
    icon: Icons.school_outlined,
    color: Color(0xFFa68832),
    bg: Color(0xFFFFFBEB),
    border: Color(0xFFFDE68A),
  ),
  RoleDef(
    key: UserRoleType.admin,
    label: 'مدير المركز',
    sublabel: 'صلاحية كاملة على إدارة المركز',
    icon: Icons.admin_panel_settings,
    color: Color(0xFF374151),
    bg: Color(0xFFF9FAFB),
    border: Color(0xFFD1D5DB),
  ),
];

// badge styles for displaying selected roles in chips
const _roleBadge =
    <UserRoleType, ({String label, Color bg, Color text, Color border})>{
      UserRoleType.student: (
        label: 'طالب',
        bg: Color(0xFFEFF6FF),
        text: Color(0xFF1D4ED8),
        border: Color(0xFF93C5FD),
      ),
      UserRoleType.circleSheikh: (
        label: 'محفظ حلقة',
        bg: Color(0xFFECFDF5),
        text: Color(0xFF1a5c38),
        border: Color(0xFF6EE7B7),
      ),
      UserRoleType.assistantCircleSheikh: (
        label: 'محفظ مساعد',
        bg: Color(0xFFE8F5E9),
        text: Color(0xFF05834d),
        border: Color(0xFF81C784),
      ),
      UserRoleType.recitationSheikh: (
        label: 'شيخ سرد',
        bg: Color(0xFFF0FDFA),
        text: Color(0xFF0D9488),
        border: Color(0xFF5EEAD4),
      ),
      UserRoleType.individualExamSheikh: (
        label: 'شيخ فحص منفرد',
        bg: Color(0xFFF5F3FF),
        text: Color(0xFF7C3AED),
        border: Color(0xFFC4B5FD),
      ),
      UserRoleType.collectiveExamSheikh: (
        label: 'شيخ فحص مجتمعة',
        bg: Color(0xFFFEF2F2),
        text: Color(0xFFDC2626),
        border: Color(0xFFFECACA),
      ),
      UserRoleType.courseInstructor: (
        label: 'مدرّس دورة',
        bg: Color(0xFFFFFBEB),
        text: Color(0xFFa68832),
        border: Color(0xFFFDE68A),
      ),
      UserRoleType.admin: (
        label: 'مدير',
        bg: Color(0xFFF9FAFB),
        text: Color(0xFF374151),
        border: Color(0xFFD1D5DB),
      ),
    };

// === Root Screen ===
// the root screen - wraps new-user form and edit-roles tab in a scaffold
class UserRegistrationScreen extends ConsumerStatefulWidget {
  const UserRegistrationScreen({super.key});

  @override
  ConsumerState<UserRegistrationScreen> createState() =>
      _UserRegistrationScreenState();
}

class _UserRegistrationScreenState
    extends ConsumerState<UserRegistrationScreen> {
  var _isNewUserTab = true;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(userManagementProvider.notifier).fetchUsers();
      ref.read(userManagementProvider.notifier).fetchCirclesAndCourses();
    });
  }

  // delegating create-user call to the provider
  Future<Map<String, String>?> _createUser({
    required String name,
    required String phone,
    required List<String> roles,
    int? circleId,
    int? sheikhCircleId,
    int? courseId,
    String? fatherPhone,
  }) {
    return ref
        .read(userManagementProvider.notifier)
        .createUser(
          name: name,
          phone: phone,
          roles: roles,
          circleId: circleId,
          sheikhCircleId: sheikhCircleId,
          courseId: courseId,
          fatherPhone: fatherPhone,
        );
  }

  // delegating update-roles call to the provider
  Future<bool> _updateUserRoles({
    required int userId,
    required List<String> roles,
    int? circleId,
    int? sheikhCircleId,
    int? courseId,
    String? fatherPhone,
  }) {
    return ref
        .read(userManagementProvider.notifier)
        .updateUserRoles(
          userId: userId,
          roles: roles,
          circleId: circleId,
          sheikhCircleId: sheikhCircleId,
          courseId: courseId,
          fatherPhone: fatherPhone,
        );
  }

  @override
  Widget build(BuildContext context) {
    final um = ref.watch(userManagementProvider);

    // scaffold with tab bar, error banner, and tab content
    return Scaffold(
      backgroundColor: const Color(0xFFF9F5EF),
      body: SafeArea(
        child: Column(
          children: [
            _buildTabBar(),
            if (um.error != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                color: const Color(0xFFFEF2F2),
                child: Text(
                  um.error!,
                  style: AppTextStyles.caption.copyWith(
                    color: const Color(0xFFDC2626),
                  ),
                ),
              ),
            Expanded(
              child: _isNewUserTab
                  ? _NewUserForm(
                      circles: um.circles,
                      courses: um.courses,
                      isSaving: um.isSaving,
                      onCreateUser: _createUser,
                    )
                  : _EditRolesTab(
                      users: um.users,
                      circles: um.circles,
                      courses: um.courses,
                      isSaving: um.isSaving,
                      onUpdateRoles: _updateUserRoles,
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // tab bar with create / edit tabs
  Widget _buildTabBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: const BoxDecoration(
        color: Color(0xFFF9F5EF),
        border: Border(bottom: BorderSide(color: Color(0xFFF3F4F6))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'إدارة المستخدمين',
            style: AppTextStyles.h2.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade100),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _tabBtn(
                    'مستخدم جديد',
                    Icons.person_add,
                    _isNewUserTab,
                    () => setState(() => _isNewUserTab = true),
                  ),
                ),
                Expanded(
                  child: _tabBtn(
                    'تعديل أدوار',
                    Icons.manage_accounts,
                    !_isNewUserTab,
                    () => setState(() => _isNewUserTab = false),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // individual tab button with active/inactive styling
  Widget _tabBtn(String label, IconData icon, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: active ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(11),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: active ? Colors.white : Colors.grey.shade500,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: active ? Colors.white : Colors.grey.shade500,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// === New User Form ===

typedef _CreateUserCallback =
    Future<Map<String, String>?> Function({
      required String name,
      required String phone,
      required List<String> roles,
      int? circleId,
      int? sheikhCircleId,
      int? courseId,
      String? fatherPhone,
    });

typedef _UpdateRolesCallback =
    Future<bool> Function({
      required int userId,
      required List<String> roles,
      int? circleId,
      int? sheikhCircleId,
      int? courseId,
      String? fatherPhone,
    });

// the form widget - handles creating a new user with role selection
class _NewUserForm extends StatefulWidget {
  final List<Map<String, dynamic>> circles;
  final List<Map<String, dynamic>> courses;
  final bool isSaving;
  final _CreateUserCallback onCreateUser;

  const _NewUserForm({
    required this.circles,
    required this.courses,
    required this.isSaving,
    required this.onCreateUser,
  });

  @override
  State<_NewUserForm> createState() => _NewUserFormState();
}

class _NewUserFormState extends State<_NewUserForm> {
  // controllers for the form fields
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _fatherPhoneCtrl = TextEditingController();
  // selected roles and their settings
  final _selectedRoles = <UserRoleType>{};
  int? _circleId;
  int? _sheikhCircleId;
  int? _courseId;
  var _canExam = false;
  // success state
  var _saved = false;
  var _generatedPassword = '';
  var _generatedUniqueNumber = '';

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _fatherPhoneCtrl.dispose();
    super.dispose();
  }

  // check if the form is ready to submit
  bool get _canSave =>
      _nameCtrl.text.trim().isNotEmpty &&
      _selectedRoles.isNotEmpty &&
      (!_needsCircle || _circleId != null) &&
      (!_needsSheikhCircle || _sheikhCircleId != null);
  // show the appropriate validation error
  String? get _saveError {
    if (_needsCircle && _circleId == null) return 'يرجى اختيار حلقة الطالب';
    if (_needsSheikhCircle && _sheikhCircleId == null)
      return 'يرجى اختيار الحلقة التي سيشرف عليها';
    return null;
  }

  // toggle a role on/off when the user taps a role card
  void _toggleRole(UserRoleType k) {
    setState(() {
      _selectedRoles.contains(k)
          ? _selectedRoles.remove(k)
          : _selectedRoles.add(k);
    });
  }

  // whether the user needs a student circle
  bool get _needsCircle => _selectedRoles.any(
    (r) =>
        r == UserRoleType.student ||
        r == UserRoleType.circleSheikh ||
        r == UserRoleType.assistantCircleSheikh ||
        r == UserRoleType.recitationSheikh,
  );

  // whether the user needs a sheikh circle (circle_sheikh only)
  bool get _needsSheikhCircle =>
      _selectedRoles.contains(UserRoleType.circleSheikh);

  // roles that have exam permissions
  bool get _needsExam => _selectedRoles.any(
    (r) =>
        r == UserRoleType.recitationSheikh ||
        r == UserRoleType.individualExamSheikh ||
        r == UserRoleType.collectiveExamSheikh,
  );

  // submit the form: so will collate roles + settings, call provider, show result
  Future<void> _submit() async {
    if (!_canSave) return;
    final roles = _selectedRoles.map(_apiRole).toList();
    final result = await widget.onCreateUser(
      name: _nameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      roles: roles,
      circleId: (_selectedRoles.contains(UserRoleType.student) || _needsCircle)
          ? _circleId
          : null,
      sheikhCircleId: _needsSheikhCircle ? _sheikhCircleId : null,
      courseId: _selectedRoles.contains(UserRoleType.courseInstructor)
          ? _courseId
          : null,
      fatherPhone: _selectedRoles.contains(UserRoleType.student)
          ? _fatherPhoneCtrl.text.trim()
          : null,
    );
    if (result != null && mounted)
      setState(() {
        _saved = true;
        _generatedPassword = result['password'] ?? '';
        _generatedUniqueNumber = result['uniqueNumber'] ?? '';
      });
  }

  @override
  Widget build(BuildContext context) {
    // success state - show green checkmark + generated password / unique_number
    if (_saved) {
      final roleLabels = _selectedRoles
          .map((k) => _roleDefs.firstWhere((r) => r.key == k).label)
          .toList();
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: Color(0xFFECFDF5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Color(0xFF059669),
                  size: 40,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'تم تسجيل المستخدم',
                style: AppTextStyles.h2.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _nameCtrl.text.trim(),
                style: AppTextStyles.bodySmall.copyWith(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: roleLabels
                    .map(
                      (l) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          l,
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7ED),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFED7AA)),
                ),
                child: Column(
                  children: [
                    Text(
                      'بيانات تسجيل الدخول',
                      style: AppTextStyles.caption.copyWith(
                        color: const Color(0xFF92400E),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _generatedPassword,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w900,
                            fontFamily: 'monospace',
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          ':كلمة المرور',
                          style: AppTextStyles.caption.copyWith(
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _generatedUniqueNumber,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w900,
                            fontFamily: 'monospace',
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          ':الرقم الفريد',
                          style: AppTextStyles.caption.copyWith(
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _saved = false;
                    _nameCtrl.clear();
                    _phoneCtrl.clear();
                    _fatherPhoneCtrl.clear();
                    _selectedRoles.clear();
                    _canExam = false;
                    _generatedPassword = '';
                    _generatedUniqueNumber = '';
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 48,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 4,
                ),
                child: const Text(
                  'تسجيل مستخدم آخر',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // form view - basic data, roles, settings cards
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _section('البيانات الأساسية', AppColors.primary, [
                  _label(Icons.person_outline, 'الاسم الكامل'),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _nameCtrl,
                    textAlign: TextAlign.right,
                    style: AppTextStyles.bodyMedium,
                    decoration: _inputDeco('مثال: محمد عبدالرحمن'),
                  ),
                  const SizedBox(height: 16),
                  _label(Icons.phone_outlined, 'رقم الهاتف'),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _phoneCtrl,
                    textDirection: TextDirection.ltr,
                    textAlign: TextAlign.left,
                    keyboardType: TextInputType.phone,
                    decoration: _inputDeco('05xxxxxxxx (اختياري)'),
                  ),
                ]),
                const SizedBox(height: 16),
                _buildRolesSection(),
                if (_selectedRoles.contains(UserRoleType.student)) ...[
                  const SizedBox(height: 16),
                  _buildSettingsCard(
                    'إعدادات الطالب',
                    AppColors.primary,
                    const Color(0xFFECFDF5),
                    const Color(0xFF6EE7B7),
                    [
                      _label(null, 'حلقة الطالب'),
                      const SizedBox(height: 6),
                      _dropdown(
                        _circleId,
                        widget.circles,
                        (v) => setState(() => _circleId = v),
                        const Color(0xFF6EE7B7),
                      ),
                      const SizedBox(height: 12),
                      _label(null, 'هاتف ولي الأمر'),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _fatherPhoneCtrl,
                        textDirection: TextDirection.ltr,
                        textAlign: TextAlign.left,
                        keyboardType: TextInputType.phone,
                        decoration: _inputDeco('05xxxxxxxx (اختياري)'),
                      ),
                    ],
                  ),
                ],
                if (_needsSheikhCircle) ...[
                  const SizedBox(height: 16),
                  _buildSettingsCard(
                    'إعدادات شيخ الحلقة',
                    const Color(0xFFD97706),
                    const Color(0xFFFFF7ED),
                    const Color(0xFFFED7AA),
                    [
                      _label(null, 'الحلقة التي سيشرف عليها'),
                      const SizedBox(height: 6),
                      _dropdown(
                        _sheikhCircleId,
                        widget.circles,
                        (v) => setState(() => _sheikhCircleId = v),
                        const Color(0xFFFED7AA),
                      ),
                    ],
                  ),
                ],
                if (_needsExam) ...[
                  const SizedBox(height: 16),
                  _buildSettingsCard(
                    'إعدادات الاختبار',
                    const Color(0xFF7C3AED),
                    const Color(0xFFF5F3FF),
                    const Color(0xFFC4B5FD),
                    [
                      _toggleRow(
                        'صلاحية اختبار الطلاب',
                        _canExam,
                        (v) => setState(() => _canExam = v),
                        const Color(0xFF7C3AED),
                      ),
                    ],
                  ),
                ],
                if (_selectedRoles.contains(UserRoleType.courseInstructor)) ...[
                  const SizedBox(height: 16),
                  _buildSettingsCard(
                    'إعدادات المدرّس',
                    const Color(0xFFa68832),
                    const Color(0xFFFFFBEB),
                    const Color(0xFFFDE68A),
                    [
                      _label(null, 'الدورة المكلَّف بها'),
                      const SizedBox(height: 6),
                      _dropdown(
                        _courseId,
                        widget.courses,
                        (v) => setState(() => _courseId = v),
                        const Color(0xFFFDE68A),
                      ),
                    ],
                  ),
                ],
                if (_selectedRoles.length > 1) ...[
                  const SizedBox(height: 16),
                  _roleSummary(),
                ],
              ],
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Colors.grey.shade200)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 20,
                offset: const Offset(0, -10),
              ),
            ],
          ),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: (_canSave && !widget.isSaving) ? _submit : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: (_canSave && !widget.isSaving)
                    ? AppColors.primary
                    : Colors.grey.shade100,
                foregroundColor: (_canSave && !widget.isSaving)
                    ? const Color(0xFFc9a84c)
                    : Colors.grey.shade300,
                disabledBackgroundColor: Colors.grey.shade100,
                disabledForegroundColor: Colors.grey.shade300,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: (_canSave && !widget.isSaving) ? 4 : 0,
              ),
              child: Text(
                widget.isSaving
                    ? 'جارٍ الحفظ...'
                    : (_canSave
                          ? 'تسجيل المستخدم'
                          : (_saveError ?? 'أدخل الاسم واختر دوراً للمتابعة')),
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // reusable section container with title + children
  Widget _section(String title, Color color, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.bodyMedium.copyWith(
              color: color,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  // label row with optional icon - used within section cards
  Widget _label(IconData? icon, String text) {
    return Row(
      children: [
        if (icon != null) ...[
          Icon(icon, size: 14, color: Colors.grey.shade500),
          const SizedBox(width: 6),
        ],
        Text(
          text,
          style: AppTextStyles.label.copyWith(
            fontWeight: FontWeight.w700,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  // standard input decoration for text form fields
  InputDecoration _inputDeco(String hint) {
    return InputDecoration(
      hintText: hint,
      hintTextDirection: TextDirection.rtl,
      filled: true,
      fillColor: Colors.grey.shade50,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade100, width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade100, width: 2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: AppColors.primary.withValues(alpha: 0.4),
          width: 2,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  // build the role-selection grid with all available roles
  Widget _buildRolesSection() {
    return _section('الأدوار المخصصة', AppColors.primary, [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(),
          Text(
            'يمكن اختيار أكثر من دور',
            style: AppTextStyles.caption.copyWith(color: Colors.grey.shade400),
          ),
        ],
      ),
      // bottom save bar
      Container(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF7ED),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFFED7AA)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.info_outline, size: 16, color: Color(0xFFD97706)),
            const SizedBox(width: 8),
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: AppTextStyles.caption.copyWith(
                    color: const Color(0xFF92400E),
                    fontWeight: FontWeight.w500,
                  ),
                  children: [
                    const TextSpan(text: 'يمكن تعديل الأدوار لاحقاً من تبويب '),
                    TextSpan(
                      text: 'تعديل أدوار',
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 12),
      ..._roleDefs.map((r) {
        final active = _selectedRoles.contains(r.key);
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: GestureDetector(
            onTap: () => _toggleRole(r.key),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: active ? r.bg : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: active ? r.border : Colors.grey.shade100,
                  width: 2,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: active ? r.bg : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: active ? r.border : Colors.grey.shade200,
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            r.icon,
                            size: 20,
                            color: active ? r.color : Colors.grey.shade300,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              r.label,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: active ? r.color : Colors.grey.shade600,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              r.sublabel,
                              style: AppTextStyles.caption.copyWith(
                                color: Colors.grey.shade400,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: active ? r.border : Colors.grey.shade300,
                        width: 2,
                      ),
                      color: active ? r.color : null,
                    ),
                    child: active
                        ? const Center(
                            child: Icon(
                              Icons.circle,
                              size: 8,
                              color: Colors.white,
                            ),
                          )
                        : null,
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    ]);
  }

  // reusable settings card - used for circle, sheikh-circle, course, exam cards
  Widget _buildSettingsCard(
    String title,
    Color titleColor,
    Color bg,
    Color border,
    List<Widget> children,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.bodyMedium.copyWith(
              color: titleColor,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  // dropdown using bottom sheet - avoids RTL+scroll clipping issues with native DropdownButton
  Widget _dropdown(
    int? value,
    List<Map<String, dynamic>> items,
    ValueChanged<int?> onChanged,
    Color borderColor,
  ) {
    final selected = items.where((e) => e['id'] == value).firstOrNull;
    return GestureDetector(
      onTap: () async {
        if (items.isEmpty) {
          if (context.mounted)
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('لا توجد حلقات متاحة حالياً')),
            );
          return;
        }
        final picked = await showModalBottomSheet<int>(
          context: context,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (_) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 10),
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'اختر من القائمة',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: Colors.grey.shade500,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Icon(
                          Icons.close,
                          size: 20,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    children: items
                        .map(
                          (e) => ListTile(
                            title: Text(
                              e['name'] as String,
                              textAlign: TextAlign.right,
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: e['id'] == value
                                    ? FontWeight.w900
                                    : FontWeight.w500,
                              ),
                            ),
                            trailing: e['id'] == value
                                ? const Icon(
                                    Icons.check,
                                    color: AppColors.primary,
                                    size: 20,
                                  )
                                : null,
                            onTap: () => Navigator.pop(context, e['id'] as int),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
        );
        if (picked != null) onChanged(picked);
      },
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: 2),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                selected != null ? selected['name'] as String : 'اختر...',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: selected != null
                      ? Colors.grey.shade800
                      : Colors.grey.shade400,
                ),
                textAlign: TextAlign.right,
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down,
              color: Colors.grey.shade400,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  // toggle switch row - used for exam permission / course instructor settings
  Widget _toggleRow(
    String label,
    bool value,
    ValueChanged<bool> onChanged,
    Color activeColor,
  ) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: value ? activeColor : Colors.grey.shade200,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                fontWeight: FontWeight.w700,
                color: value ? activeColor : Colors.grey.shade500,
              ),
            ),
            Container(
              width: 44,
              height: 24,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: value ? activeColor : Colors.grey.shade200,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 200),
                alignment: value ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _roleSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ملخص الأدوار:',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: _selectedRoles.map((k) {
              final b = _roleBadge[k]!;
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: b.bg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: b.border),
                ),
                child: Text(
                  b.label,
                  style: AppTextStyles.caption.copyWith(
                    color: b.text,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// === Edit Roles Tab ===─

class _EditRolesTab extends StatefulWidget {
  final List<ManagedUser> users;
  final List<Map<String, dynamic>> circles;
  final List<Map<String, dynamic>> courses;
  final bool isSaving;
  final _UpdateRolesCallback onUpdateRoles;

  const _EditRolesTab({
    required this.users,
    required this.circles,
    required this.courses,
    required this.isSaving,
    required this.onUpdateRoles,
  });

  @override
  State<_EditRolesTab> createState() => _EditRolesTabState();
}

class _EditRolesTabState extends State<_EditRolesTab> {
  // the selected user and their current roles
  int? _selectedId;
  late Set<UserRoleType> _editRoles;
  int? _circleId;
  int? _sheikhCircleId;
  int? _courseId;
  final _fatherPhoneCtrl = TextEditingController();
  var _canExam = false;
  var _saved = false;

  @override
  void initState() {
    super.initState();
    _editRoles = <UserRoleType>{};
  }

  @override
  void dispose() {
    _fatherPhoneCtrl.dispose();
    super.dispose();
  }

  ManagedUser? get _selectedUser =>
      widget.users.where((u) => u.id == _selectedId).firstOrNull;

  // populate the form with an existing user's data for editing
  void _openEdit(ManagedUser u) {
    setState(() {
      _selectedId = u.id;
      _editRoles = u.roles.map(_fromApiRole).toSet();
      _circleId = u.circle?['id'] as int?;
      _sheikhCircleId = null;
      _courseId = u.course?['id'] as int?;
      _fatherPhoneCtrl.text = u.circle?['father_phone'] as String? ?? '';
      _canExam = false;
      _saved = false;
    });
  }

  // toggle a role on/off when editing
  void _toggleRole(UserRoleType k) {
    setState(() {
      _editRoles.contains(k) ? _editRoles.remove(k) : _editRoles.add(k);
    });
  }

  bool get _needsCircle => _editRoles.contains(UserRoleType.student);
  bool get _needsSheikhCircle => _editRoles.contains(UserRoleType.circleSheikh);

  bool get _needsExam => _editRoles.any(
    (r) =>
        r == UserRoleType.recitationSheikh ||
        r == UserRoleType.individualExamSheikh ||
        r == UserRoleType.collectiveExamSheikh,
  );

  // whether the edit form is ready to submit
  bool get _canSaveEdit =>
      _editRoles.isNotEmpty &&
      (!_needsCircle || _circleId != null) &&
      (!_needsSheikhCircle || _sheikhCircleId != null);
  String? get _editSaveError {
    if (_needsCircle && _circleId == null) return 'يرجى اختيار حلقة الطالب';
    if (_needsSheikhCircle && _sheikhCircleId == null)
      return 'يرجى اختيار الحلقة التي سيشرف عليها';
    return null;
  }

  // save the edited roles back to the api
  Future<void> _saveEdit() async {
    final user = _selectedUser;
    if (user == null || _editRoles.isEmpty) return;
    final roles = _editRoles.map(_apiRole).toList();
    final ok = await widget.onUpdateRoles(
      userId: user.id,
      roles: roles,
      circleId: _needsCircle ? _circleId : null,
      sheikhCircleId: _needsSheikhCircle ? _sheikhCircleId : null,
      courseId: _editRoles.contains(UserRoleType.courseInstructor)
          ? _courseId
          : null,
      fatherPhone: _editRoles.contains(UserRoleType.student)
          ? _fatherPhoneCtrl.text.trim()
          : null,
    );
    if (ok && mounted) setState(() => _saved = true);
  }

  // whether a role is newly added relative to the user's current roles
  bool _isNewRole(UserRoleType k) {
    final user = _selectedUser;
    return user != null &&
        _editRoles.contains(k) &&
        !user.roles.map(_fromApiRole).contains(k);
  }

  // whether a role is removed relative to the user's current roles
  bool _isRemovedRole(UserRoleType k) {
    final user = _selectedUser;
    return user != null &&
        !_editRoles.contains(k) &&
        user.roles.map(_fromApiRole).contains(k);
  }

  @override
  Widget build(BuildContext context) {
    // show the edit panel if a user is selected, otherwise user list
    if (_selectedId != null && _selectedUser != null) return _buildEditPanel();

    if (widget.users.isEmpty) {
      return Center(
        child: Text(
          'لا يوجد مستخدمون بعد',
          style: AppTextStyles.bodySmall.copyWith(color: Colors.grey.shade400),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 4, bottom: 12),
            child: Text(
              'اختر مستخدماً لتعديل أدواره:',
              style: AppTextStyles.bodySmall.copyWith(
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ...widget.users.map(
            (u) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GestureDetector(
                onTap: () => _openEdit(u),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade100),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            u.name.characters.first,
                            style: AppTextStyles.bodyLarge.copyWith(
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
                            Text(
                              u.name,
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            if (u.circle != null) ...[
                              const SizedBox(height: 2),
                              Text(
                                u.circle!['name'] as String,
                                style: AppTextStyles.caption.copyWith(
                                  color: Colors.grey.shade400,
                                ),
                              ),
                            ],
                            const SizedBox(height: 4),
                            Wrap(
                              spacing: 4,
                              runSpacing: 2,
                              children: u.roles.map((r) {
                                final k = _fromApiRole(r);
                                final b =
                                    _roleBadge[k] ??
                                    _roleBadge[UserRoleType.student]!;
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: b.bg,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: b.border),
                                  ),
                                  child: Text(
                                    b.label,
                                    style: AppTextStyles.caption.copyWith(
                                      color: b.text,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 9,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.manage_accounts,
                        size: 20,
                        color: Color(0xFFc9a84c),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // edit panel - shows form for editing a selected user's roles
  Widget _buildEditPanel() {
    final user = _selectedUser!;

    if (_saved) {
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: Color(0xFFECFDF5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Color(0xFF059669),
                  size: 40,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'تم تحديث الأدوار',
                style: AppTextStyles.h2.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                user.name,
                style: AppTextStyles.bodySmall.copyWith(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: _editRoles.map((k) {
                  final b = _roleBadge[k]!;
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: b.bg,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: b.border),
                    ),
                    child: Text(
                      b.label,
                      style: AppTextStyles.caption.copyWith(
                        color: b.text,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => setState(() {
                  _selectedId = null;
                  _saved = false;
                }),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 48,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 4,
                ),
                child: const Text(
                  'العودة للقائمة',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // edit form - basic info, roles, settings, change summary
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _editHeader(user),
                const SizedBox(height: 16),
                _editRolesSection(user),
                if (_editRoles.contains(UserRoleType.student)) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF6EE7B7)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'إعدادات الطالب',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _editLabel('حلقة الطالب'),
                        const SizedBox(height: 6),
                        _editDropdown(
                          _circleId,
                          widget.circles,
                          (v) => setState(() => _circleId = v),
                          const Color(0xFF6EE7B7),
                        ),
                        const SizedBox(height: 12),
                        _editLabel('هاتف ولي الأمر'),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _fatherPhoneCtrl,
                          textDirection: TextDirection.ltr,
                          textAlign: TextAlign.left,
                          keyboardType: TextInputType.phone,
                          decoration: _editInputDeco('05xxxxxxxx (اختياري)'),
                        ),
                      ],
                    ),
                  ),
                ],
                if (_needsSheikhCircle) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF7ED),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFFED7AA)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'إعدادات شيخ الحلقة',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: const Color(0xFFD97706),
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _editLabel('الحلقة التي سيشرف عليها'),
                        const SizedBox(height: 6),
                        _editDropdown(
                          _sheikhCircleId,
                          widget.circles,
                          (v) => setState(() => _sheikhCircleId = v),
                          const Color(0xFFFED7AA),
                        ),
                      ],
                    ),
                  ),
                ],
                if (_needsExam) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F3FF),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFC4B5FD)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'إعدادات الاختبار',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: const Color(0xFF7C3AED),
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _editToggleRow(
                          'صلاحية اختبار الطلاب',
                          _canExam,
                          (v) => setState(() => _canExam = v),
                          const Color(0xFF7C3AED),
                        ),
                      ],
                    ),
                  ),
                ],
                if (_editRoles.any((k) => _isNewRole(k)) ||
                    _roleDefs.any((r) => _isRemovedRole(r.key))) ...[
                  const SizedBox(height: 16),
                  _editChangeSummary(user),
                ],
              ],
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Colors.grey.shade200)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 20,
                offset: const Offset(0, -10),
              ),
            ],
          ),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: (_canSaveEdit && !widget.isSaving) ? _saveEdit : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: (_canSaveEdit && !widget.isSaving)
                    ? AppColors.primary
                    : Colors.grey.shade100,
                foregroundColor: (_canSaveEdit && !widget.isSaving)
                    ? const Color(0xFFc9a84c)
                    : Colors.grey.shade300,
                disabledBackgroundColor: Colors.grey.shade100,
                disabledForegroundColor: Colors.grey.shade300,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: (_canSaveEdit && !widget.isSaving) ? 4 : 0,
              ),
              child: Text(
                widget.isSaving
                    ? 'جارٍ الحفظ...'
                    : (_canSaveEdit
                          ? 'حفظ التعديلات'
                          : (_editSaveError ?? 'حفظ التعديلات')),
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _editHeader(ManagedUser u) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => setState(() => _selectedId = null),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                size: 14,
                color: Colors.grey,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                u.name.characters.first,
                style: AppTextStyles.bodyLarge.copyWith(
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
                Text(
                  u.name,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                if (u.circle != null) ...[
                  Text(
                    u.circle!['name'] as String,
                    style: AppTextStyles.caption.copyWith(
                      color: Colors.grey.shade400,
                    ),
                  ),
                ],
                const SizedBox(height: 4),
                Wrap(
                  spacing: 4,
                  runSpacing: 2,
                  children: u.roles.map((r) {
                    final k = _fromApiRole(r);
                    final b =
                        _roleBadge[k] ?? _roleBadge[UserRoleType.student]!;
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: b.bg,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: b.border),
                      ),
                      child: Text(
                        b.label,
                        style: AppTextStyles.caption.copyWith(
                          color: b.text,
                          fontWeight: FontWeight.w700,
                          fontSize: 9,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _editRolesSection(ManagedUser original) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'تعديل الأدوار',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                'أضف أو احذف دوراً',
                style: AppTextStyles.caption.copyWith(
                  color: Colors.grey.shade400,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ..._roleDefs.map((r) {
            final active = _editRoles.contains(r.key);
            final isNew = _isNewRole(r.key);
            final isGone = _isRemovedRole(r.key);

            Color cardBg, cardBorder;
            if (active) {
              cardBg = r.bg;
              cardBorder = r.border;
            } else if (isGone) {
              cardBg = const Color(0xFFFEF2F2);
              cardBorder = const Color(0xFFFECACA);
            } else {
              cardBg = Colors.grey.shade50;
              cardBorder = Colors.grey.shade100;
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: GestureDetector(
                onTap: () => _toggleRole(r.key),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: cardBorder, width: 2),
                  ),
                  child: Row(
                    children: [
                      Stack(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: active ? r.bg : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: active ? r.border : Colors.grey.shade200,
                                width: 2,
                              ),
                            ),
                            child: Icon(
                              r.icon,
                              size: 20,
                              color: active ? r.color : Colors.grey.shade300,
                            ),
                          ),
                          if (isNew)
                            Positioned(
                              top: -4,
                              left: -4,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 1,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF10B981),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.add,
                                      size: 8,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 1),
                                    Text(
                                      'جديد',
                                      style: AppTextStyles.caption.copyWith(
                                        color: Colors.white,
                                        fontSize: 7,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          if (isGone)
                            Positioned(
                              top: -4,
                              left: -4,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 1,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF87171),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.remove,
                                      size: 8,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 1),
                                    Text(
                                      'سيُحذف',
                                      style: AppTextStyles.caption.copyWith(
                                        color: Colors.white,
                                        fontSize: 7,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              r.label,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: active
                                    ? r.color
                                    : (isGone
                                          ? const Color(0xFFF87171)
                                          : Colors.grey.shade600),
                                fontWeight: FontWeight.w900,
                                decoration: isGone
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              r.sublabel,
                              style: AppTextStyles.caption.copyWith(
                                color: Colors.grey.shade400,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: active ? r.border : Colors.grey.shade300,
                            width: 2,
                          ),
                          color: active ? r.color : null,
                        ),
                        child: active
                            ? const Center(
                                child: Icon(
                                  Icons.circle,
                                  size: 8,
                                  color: Colors.white,
                                ),
                              )
                            : null,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // summary card showing added / removed roles compared to original
  Widget _editChangeSummary(ManagedUser original) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ملخص التغييرات:',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          ..._roleDefs.where((r) => _isNewRole(r.key)).map((r) {
            final b = _roleBadge[r.key]!;
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  const Icon(Icons.add, size: 14, color: Color(0xFF10B981)),
                  const SizedBox(width: 6),
                  Text(
                    'إضافة دور ',
                    style: AppTextStyles.caption.copyWith(
                      color: const Color(0xFF047857),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: b.bg,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: b.border),
                    ),
                    child: Text(
                      b.label,
                      style: AppTextStyles.caption.copyWith(
                        color: b.text,
                        fontWeight: FontWeight.w700,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
          ..._roleDefs.where((r) => _isRemovedRole(r.key)).map((r) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  const Icon(Icons.remove, size: 14, color: Color(0xFFF87171)),
                  const SizedBox(width: 6),
                  Text(
                    'إزالة دور ',
                    style: AppTextStyles.caption.copyWith(
                      color: const Color(0xFFDC2626),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFFECACA)),
                    ),
                    child: Text(
                      r.label,
                      style: AppTextStyles.caption.copyWith(
                        color: const Color(0xFFDC2626),
                        fontWeight: FontWeight.w700,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _editLabel(String text) {
    return Text(
      text,
      style: AppTextStyles.label.copyWith(
        fontWeight: FontWeight.w700,
        color: Colors.grey.shade600,
      ),
    );
  }

  // dropdown with bottom-sheet for the edit tab
  Widget _editDropdown(
    int? value,
    List<Map<String, dynamic>> items,
    ValueChanged<int?> onChanged,
    Color borderColor,
  ) {
    final selected = items.where((e) => e['id'] == value).firstOrNull;
    return GestureDetector(
      onTap: () async {
        if (items.isEmpty) {
          if (context.mounted)
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('لا توجد حلقات متاحة حالياً')),
            );
          return;
        }
        final picked = await showModalBottomSheet<int>(
          context: context,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (_) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 10),
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'اختر من القائمة',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: Colors.grey.shade500,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Icon(
                          Icons.close,
                          size: 20,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    children: items
                        .map(
                          (e) => ListTile(
                            title: Text(
                              e['name'] as String,
                              textAlign: TextAlign.right,
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: e['id'] == value
                                    ? FontWeight.w900
                                    : FontWeight.w500,
                              ),
                            ),
                            trailing: e['id'] == value
                                ? const Icon(
                                    Icons.check,
                                    color: AppColors.primary,
                                    size: 20,
                                  )
                                : null,
                            onTap: () => Navigator.pop(context, e['id'] as int),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
        );
        if (picked != null) onChanged(picked);
      },
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: 2),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                selected != null ? selected['name'] as String : 'اختر...',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: selected != null
                      ? Colors.grey.shade800
                      : Colors.grey.shade400,
                ),
                textAlign: TextAlign.right,
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down,
              color: Colors.grey.shade400,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  // toggle row for the edit tab
  Widget _editToggleRow(
    String label,
    bool value,
    ValueChanged<bool> onChanged,
    Color activeColor,
  ) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: value ? activeColor : Colors.grey.shade200,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                fontWeight: FontWeight.w700,
                color: value ? activeColor : Colors.grey.shade500,
              ),
            ),
            Container(
              width: 44,
              height: 24,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: value ? activeColor : Colors.grey.shade200,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 200),
                alignment: value ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _editInputDeco(String hint) {
    return InputDecoration(
      hintText: hint,
      hintTextDirection: TextDirection.rtl,
      filled: true,
      fillColor: Colors.grey.shade50,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade100, width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade100, width: 2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: AppColors.primary.withValues(alpha: 0.4),
          width: 2,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}
