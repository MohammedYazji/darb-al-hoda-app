import 'package:darb_al_hoda_app/core/constants/app_colors.dart';
import 'package:darb_al_hoda_app/core/constants/app_constants.dart';
import 'package:darb_al_hoda_app/core/constants/app_text_styles.dart';
import 'package:darb_al_hoda_app/core/models/user_model.dart';
import 'package:darb_al_hoda_app/features/auth/presentation/auth_provider.dart';
import 'package:darb_al_hoda_app/features/circle/presentation/circle_provider.dart';
import 'package:darb_al_hoda_app/features/dashboard/presentation/dashboard_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// === Role Metadata ===
class RoleMeta {
  final String label;
  final Color color;
  final Color bg;
  final Color dot;

  const RoleMeta({
    required this.label,
    required this.color,
    required this.bg,
    required this.dot,
  });
}

const Map<String, RoleMeta> _roleMetaMap = {
  AppConstants.roleStudent: RoleMeta(
    label: "طالب",
    color: Color(0xFF1D4ED8),
    bg: Color(0xFFEFF6FF),
    dot: Color(0xFF3B82F6),
  ),
  AppConstants.roleCircleSheikh: RoleMeta(
    label: "محفظ حلقة",
    color: AppColors.primary,
    bg: Color(0xFFECFDF5),
    dot: Color(0xFF10B981),
  ),
  AppConstants.roleAdmin: RoleMeta(
    label: "مدير المركز",
    color: Colors.purple,
    bg: Color(0xFFF5F3FF),
    dot: Colors.purpleAccent,
  ),
  'other': RoleMeta(
    label: "مستخدم",
    color: Colors.grey,
    bg: Color(0xFFF3F4F6),
    dot: Colors.grey,
  ),
};

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _isRoleOpen = false;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final circleState = ref.watch(circleProvider);
    final user = authState.user;
    final activeRole = authState.activeRole ?? 'other';
    final rm = _roleMetaMap[activeRole] ?? _roleMetaMap['other']!;

    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('الإعدادات', style: AppTextStyles.h3),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Profile Card ──
              _buildProfileCard(user, activeRole, rm, circleState),

              const SizedBox(height: 30),

              // ── Logout Section ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.red.shade100),
                  ),
                  child: _buildSettingRow(
                    icon: Icons.logout,
                    label: "تسجيل الخروج",
                    sublabel: "الجلسة الحالية: ${rm.label}",
                    danger: true,
                    onTap: () => _showLogoutConfirmation(context),
                  ),
                ),
              ),

              const SizedBox(height: 40),
              Center(
                child: Text(
                  "درب الهدى © ٢٠٢٦ · جميع الحقوق محفوظة",
                  style: AppTextStyles.caption.copyWith(
                    fontSize: 10,
                    color: Colors.grey.shade400,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // === UI Components ===

  Widget _buildProfileCard(
    UserModel user,
    String activeRole,
    RoleMeta rm,
    CircleState circleState,
  ) {
    final roles = user.roles;
    final sublabel = _getSublabel(user, activeRole, circleState);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Avatar
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.gold, AppColors.goldLight],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    user.name.isNotEmpty ? user.name.substring(0, 1) : '',
                    style: AppTextStyles.h1.copyWith(
                      color: AppColors.primary,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      style: AppTextStyles.h3.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    if (user.phone != null)
                      Text(
                        user.phone!,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                    Text(
                      user.email,
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.white54,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Role Switcher
          Column(
            children: [
              GestureDetector(
                onTap: () {
                  if (roles.length > 1) {
                    setState(() => _isRoleOpen = !_isRoleOpen);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: rm.bg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: rm.dot,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        rm.label,
                        style: AppTextStyles.label.copyWith(
                          color: rm.color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (sublabel.isNotEmpty) ...[
                        const SizedBox(width: 4),
                        Text(
                          "— $sublabel",
                          style: AppTextStyles.caption.copyWith(
                            color: Colors.grey.shade500,
                            fontSize: 10,
                          ),
                        ),
                      ],
                      const Spacer(),
                      if (roles.length > 1) ...[
                        Text(
                          "تبديل",
                          style: AppTextStyles.caption.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade500,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          _isRoleOpen
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          size: 16,
                          color: Colors.grey,
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // Role Dropdown
              if (_isRoleOpen) ...[
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: roles.map<Widget>((role) {
                      final m = _roleMetaMap[role] ?? _roleMetaMap['other']!;
                      final isSelected = activeRole == role;
                      final roleSublabel = _getSublabel(user, role, circleState);

                      return InkWell(
                        onTap: () {
                          ref.read(authProvider.notifier).selectRole(role);

                          // If switched to student, refresh dashboard data
                          if (role == AppConstants.roleStudent) {
                            ref
                                .read(dashboardProvider.notifier)
                                .fetchDashboard();
                          }
                          
                          // If switched to sheikh, fetch their circle context
                          if (role == AppConstants.roleCircleSheikh) {
                            ref.read(circleProvider.notifier).fetchMyCircle(user.id);
                          }

                          setState(() => _isRoleOpen = false);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          color: isSelected ? m.bg : Colors.transparent,
                          child: Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: m.dot,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      m.label,
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        color: m.color,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    if (roleSublabel.isNotEmpty)
                                      Text(
                                        roleSublabel,
                                        style: AppTextStyles.caption.copyWith(
                                          fontSize: 10,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              if (isSelected)
                                const Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                  size: 18,
                                ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  String _getSublabel(UserModel user, String role, CircleState circleState) {
    if (role == AppConstants.roleStudent && user.student != null) {
      return user.student!.circle;
    }
    
    if (role == AppConstants.roleCircleSheikh && circleState.hasData) {
      return circleState.circle!.name;
    }
    
    return "مركز درب الهدى";
  }

  Widget _buildSettingRow({
    required IconData icon,
    required String label,
    String? sublabel,
    Widget? right,
    VoidCallback? onTap,
    bool danger = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: danger
                    ? Colors.red.shade50
                    : AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 18,
                color: danger ? Colors.red : AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: danger ? Colors.red.shade700 : AppColors.textPrimary,
                    ),
                  ),
                  if (sublabel != null)
                    Text(
                      sublabel,
                      style: AppTextStyles.caption.copyWith(
                        fontSize: 10,
                        color: Colors.grey.shade400,
                      ),
                    ),
                ],
              ),
            ),
            right ??
                Icon(
                  Icons.chevron_right,
                  size: 16,
                  color: danger ? Colors.red.shade200 : Colors.grey.shade300,
                ),
          ],
        ),
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.logout, color: Colors.red, size: 28),
            ),
            const SizedBox(height: 16),
            Text("تسجيل الخروج", style: AppTextStyles.h3),
            const SizedBox(height: 8),
            Text(
              "هل أنت متأكد أنك تريد الخروج من حسابك؟",
              style: AppTextStyles.bodySmall,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ref.read(authProvider.notifier).logout();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  "نعم، سجّل خروجي",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.grey,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  "إلغاء",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
