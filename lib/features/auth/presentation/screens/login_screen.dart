import 'package:darb_al_hoda_app/features/auth/presentation/screens/role_selection_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  // Control the inputs values
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // to validate from the form key
  final _formKey = GlobalKey<FormState>();

  // to track password if visible or not
  bool _obscurePassword = true;

  @override
  void dispose() {
    // When leave the page clean the fields
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // call it when press the btn
  Future<void> _handleLogin() async {
    // 1. validate the form fields
    if (!_formKey.currentState!.validate()) return;

    // 2. call the login from the auth provider
    await ref
        .read(authProvider.notifier)
        .login(
          _emailController.text.trim(), // remove the spaces
          _passwordController.text,
        );

    // 3. after login process read the state
    final authState = ref.read(authProvider);
  }

  @override
  Widget build(BuildContext context) {
    // ref.watch => to see if the state change after build the UI
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Stack(
        // Stack => use stack of widgets

        // === The circles styles at right top of the screen ===
        children: [
          Positioned(
            top: -80,
            right: -80,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                // withOpacity = rgba في CSS
                color: AppColors.gold.withValues(alpha: 0.08),
              ),
            ),
          ),
          Positioned(
            bottom: -60,
            left: -40,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.gold.withValues(alpha: 0.08),
              ),
            ),
          ),

          // === Main Content  ===
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // The Header - will take the remaining space
                    _buildHeader(),

                    const SizedBox(height: 40),

                    // Form
                    _buildForm(authState),

                    // Forget Password
                    const SizedBox(height: 24),

                    TextButton(
                      onPressed: () {},
                      child: Text(
                        'نسيت كلمة المرور؟',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.gold,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // === Header Widget ===
  Widget _buildHeader() {
    return Column(
      // center the content
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Logo Circle Background
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [AppColors.gold, Color(0xFFa68832)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: AppColors.primary.withOpacity(0.5),
              width: 4,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.gold.withOpacity(0.3),
                blurRadius: 40,
                spreadRadius: 5,
              ),
            ],
          ),
          child: const Center(
            child: Text(
              '☽', // TODO: change the icon with the real icon of darb-al-hoda
              style: TextStyle(fontSize: 48, color: AppColors.primary),
            ),
          ),
        ),

        // some margin between lines
        const SizedBox(height: 20),

        // App Name
        Text(
          'درب الهدى',
          style: AppTextStyles.h1.copyWith(
            color: AppColors.gold,
            fontSize: 40,
            fontWeight: FontWeight.w900,
            shadows: [
              const Shadow(
                color: Colors.black26,
                offset: Offset(0, 2),
                blurRadius: 4,
              ),
            ],
          ),
        ),

        // some margin between lines
        const SizedBox(height: 6),

        //
        Text(
          'مركز تحفيظ القرآن الكريم',
          style: AppTextStyles.bodyMedium.copyWith(
            color: Colors.white.withValues(alpha: 0.8),
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  // === Form Widget ===
  Widget _buildForm(AuthState authState) {
    // The main white box of the form
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(32)),
      ),
      padding: const EdgeInsets.fromLTRB(28, 32, 28, 24),
      child: Form(
        // GlobalKey => to control validation out of the form based on its keys
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // === Email field ===
            _buildLabel('اسم المستخدم'),
            const SizedBox(height: 6),
            TextFormField(
              controller:
                  _emailController, // link field with controller to track the value
              keyboardType: TextInputType
                  .emailAddress, // show the keyboard to easy typing of the email
              style: AppTextStyles.bodyMedium,
              decoration: InputDecoration(
                hintText: 'أدخل البريد الإلكتروني',
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: Colors.grey.shade100, width: 2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: Colors.grey.shade100, width: 2),
                ),
                // Gold outline when focus
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.gold, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
              // validat fields
              validator: (value) {
                if (value == null || value.isEmpty) return 'مطلوب';
                if (!value.contains('@')) return 'بريد غير صحيح';
                return null; // no errors
              },
            ),

            // some margin under email field
            const SizedBox(height: 16),

            // === Password Field ===
            _buildLabel('كلمة المرور'),
            const SizedBox(height: 6),
            TextFormField(
              controller: _passwordController,
              // to hide the password
              obscureText: _obscurePassword,
              style: AppTextStyles.bodyMedium,
              decoration: InputDecoration(
                hintText: '••••••••',
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: Colors.grey.shade100, width: 2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: Colors.grey.shade100, width: 2),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.gold, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                // hide/unhide the password btn
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons
                              .visibility_outlined // open-eye
                        : Icons.visibility_off_outlined, // closing-eye
                    color: Colors.grey,
                  ),
                  // setState will rebuild the UI after handle the login and update the state
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) return 'مطلوب';
                return null;
              },
            ),

            // === Error Msg if exist ==
            // conditional rendering for the error
            if (authState.error != null) ...[
              const SizedBox(height: 8),
              Text(
                authState.error!,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.error,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],

            const SizedBox(height: 24),

            // === Login btn ===
            ElevatedButton(
              // if isLoading so disable the btn
              onPressed: authState.isLoading ? null : _handleLogin,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.gold,
                foregroundColor: AppColors.primary,
                minimumSize: const Size(double.infinity, 64),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 8,
                shadowColor: AppColors.gold.withValues(alpha: 0.3),
              ),
              child: authState.isLoading
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      // show loading spinner
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                        strokeWidth: 2.5,
                      ),
                    )
                  : Text(
                      'دخول ←',
                      style: AppTextStyles.button.copyWith(
                        color: AppColors.primary,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // === Label Widget ===
  // instead of repeating the label styles i make widget for reuse it
  Widget _buildLabel(String text) {
    return Text(
      text,
      style: AppTextStyles.bodyMedium.copyWith(
        fontWeight: FontWeight.w700,
        color: Colors.grey.shade700,
      ),
    );
  }
}
