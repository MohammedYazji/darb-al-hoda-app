import 'package:darb_al_hoda_app/core/constants/app_colors.dart';
import 'package:darb_al_hoda_app/core/constants/app_constants.dart';
import 'package:darb_al_hoda_app/core/constants/app_text_styles.dart';
import 'package:darb_al_hoda_app/features/auth/presentation/auth_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RoleSelectionScreen extends ConsumerWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user!;

    return Scaffold(
      // TODO: make it constant
      backgroundColor: const Color(0xFFF9F5EF),
      body: Column(
        children: [
          // === Header ===
          _buildHeader(context, ref, user.name),

          // === Title ===
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Text(
              'لديك أكثر من دور — كيف تريد الدخول؟',
              style: AppTextStyles.bodyMedium.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
          ),

          // === Roles List ===
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: user.roles
                  .map((role) => _buildRoleCard(context, ref, role))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// === Header ===
Widget _buildHeader(BuildContext context, WidgetRef ref, String name) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.fromLTRB(20, 60, 20, 28),
    decoration: const BoxDecoration(color: AppColors.primary),
    child: Row(
      // === Pic of the user ===
      // ToDo: for future make the api store avatar for each user
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              // TODO: make it constant
              colors: [AppColors.gold, Color(0xFFa68832)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
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

        const SizedBox(width: 16),

        // === Welcome Message ===
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'مرحباً بك 👋',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.gold,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              name,
              style: AppTextStyles.h3.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),

        const Spacer(),

        // === Return to login btn ===
        GestureDetector(
          onTap: () => ref.read(authProvider.notifier).logout(),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.1),
            ),
            child: const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white70,
              size: 16,
            ),
          ),
        ),
      ],
    ),
  );
}

// === Role Card ===
Widget _buildRoleCard(BuildContext context, WidgetRef ref, String role) {
  final meta = _getRoleMeta(role);

  return GestureDetector(
    onTap: () => ref.read(authProvider.notifier).selectRole(role),
    child: Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: meta.borderColor, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // == Role Icon ==
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: meta.bgColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: meta.borderColor, width: 2),
            ),
            child: Icon(meta.icon, color: meta.color, size: 26),
          ),

          const SizedBox(width: 16),
          // === ROle name & Description ===
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Role name
                Text(
                  meta.label,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: meta.color,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                // Description
                Text(
                  meta.sublabel,
                  style: AppTextStyles.caption.copyWith(
                    color: Colors.grey.shade400,
                  ),
                ),
              ],
            ),
          ),
          // == Arrow ==
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: meta.bgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.arrow_back_ios_new, color: meta.color, size: 14),
          ),
        ],
      ),
    ),
  );
}

// === Role Meta Data ===
_RoleMeta _getRoleMeta(String role) {
  switch (role) {
    case AppConstants.roleStudent:
      return _RoleMeta(
        label: 'طالب',
        sublabel: 'عرض التقدم والتسميع',
        icon: Icons.person_outline,
        color: const Color(0xFF1565C0),
        bgColor: const Color(0xFFE3F2FD),
        borderColor: const Color(0xFF90CAF9),
      );
    case AppConstants.roleCircleSheikh:
      return _RoleMeta(
        label: 'محفظ حلقة',
        sublabel: 'تسميع الطلاب وإدارة الحلقة',
        icon: Icons.menu_book_outlined,
        color: AppColors.primary,
        bgColor: const Color(0xFFE8F5E9),
        borderColor: const Color(0xFFA5D6A7),
      );
    case AppConstants.roleRecitationSheikh:
      return _RoleMeta(
        label: 'شيخ السرد',
        sublabel: 'سرد الاجزاء المنفردة واعتمادها',
        icon: Icons.record_voice_over_outlined,
        color: const Color(0xFF6A1B9A),
        bgColor: const Color(0xFFF3E5F5),
        borderColor: const Color(0xFFCE93D8),
      );
    case AppConstants.roleIndividualExamSheikh:
      return _RoleMeta(
        label: 'شيخ اختبار المنفردة',
        sublabel: 'إجراء اختبارات الأجزاء المنفردة',
        icon: Icons.assignment_outlined,
        color: const Color(0xFFE65100),
        bgColor: const Color(0xFFFFF3E0),
        borderColor: const Color(0xFFFFCC80),
      );
    case AppConstants.roleCollectiveExamSheikh:
      return _RoleMeta(
        label: 'شيخ اختبار التثبيت',
        sublabel: 'إجراء اختبارات التثبيت المجتمعة',
        icon: Icons.group_outlined,
        color: const Color(0xFF00695C),
        bgColor: const Color(0xFFE0F2F1),
        borderColor: const Color(0xFF80CBC4),
      );
    case AppConstants.roleAdmin:
      return _RoleMeta(
        label: 'مدير المركز',
        sublabel: 'الإشراف الكامل على المركز',
        icon: Icons.shield_outlined,
        color: const Color(0xFF4A148C),
        bgColor: const Color(0xFFEDE7F6),
        borderColor: const Color(0xFFB39DDB),
      );
    default:
      return _RoleMeta(
        label: role,
        sublabel: '',
        icon: Icons.person_outline,
        color: Colors.grey,
        bgColor: Colors.grey.shade100,
        borderColor: Colors.grey.shade300,
      );
  }
}

// === Helper Class ===
class _RoleMeta {
  final String label;
  final String sublabel;
  final IconData icon;
  final Color color;
  final Color bgColor;
  final Color borderColor;

  const _RoleMeta({
    required this.label,
    required this.sublabel,
    required this.icon,
    required this.color,
    required this.bgColor,
    required this.borderColor,
  });
}
