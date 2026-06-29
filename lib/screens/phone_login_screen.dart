import 'package:flashchat_app/components/rounded_button.dart';
import 'package:flashchat_app/constants/app_theme.dart';
import 'package:flashchat_app/constants/constants.dart';
import 'package:flashchat_app/providers/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class PhoneLoginScreen extends ConsumerStatefulWidget {
  const PhoneLoginScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends ConsumerState<PhoneLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String _phoneNumber = '';

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState is AsyncLoading;

    ref.listen<AsyncValue<void>>(authControllerProvider, (previous, next) {
      next.whenOrNull(
        error: (error, stackTrace) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                error.toString().replaceAll(RegExp(r'^Exception:\s*'), ''),
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: AppColors.error,
            ),
          );
        },
      );
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded,
              color: AppColors.textSecondary, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                // Icon
                Center(
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.online.withValues(alpha: 0.15),
                      border: Border.all(
                        color: AppColors.online.withValues(alpha: 0.3),
                        width: 1.5,
                      ),
                    ),
                    child: const Icon(
                      Icons.phone_android_rounded,
                      size: 36,
                      color: AppColors.online,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Phone Sign In',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Enter your phone number with country code\n(e.g. +1 555-0100)',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 40),
                TextFormField(
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.5,
                  ),
                  onChanged: (value) => _phoneNumber = value.trim(),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your phone number';
                    }
                    if (!value.trim().startsWith('+')) {
                      return 'Include country code starting with +';
                    }
                    return null;
                  },
                  decoration: kTextFieldDecoration.copyWith(
                    hintText: '+1 555 010 0000',
                    hintStyle: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 18,
                      letterSpacing: 1.5,
                    ),
                    prefixIcon: const Icon(Icons.phone_outlined,
                        color: AppColors.textMuted, size: 20),
                  ),
                ),
                const SizedBox(height: 24),
                RoundedButton(
                  title: 'Send Code',
                  color: AppColors.online.withValues(alpha: 0.8),
                  isLoading: isLoading,
                  icon: Icons.send_rounded,
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      await ref
                          .read(authControllerProvider.notifier)
                          .verifyPhone(
                            phoneNumber: _phoneNumber,
                            onCodeSent: (verificationId) {
                              context.push(
                                '/phone-verify?verificationId=$verificationId&phone=${Uri.encodeComponent(_phoneNumber)}',
                              );
                            },
                            onFailed: (errorMessage) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(errorMessage),
                                  backgroundColor: AppColors.error,
                                ),
                              );
                            },
                          );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
