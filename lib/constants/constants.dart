import 'package:flutter/material.dart';
import 'app_theme.dart';

// ── Chat Screen Decorations ──────────────────────────────────────────

const kSendButtonTextStyle = TextStyle(
  color: AppColors.accentPrimary,
  fontWeight: FontWeight.w700,
  fontSize: 16.0,
);

const kMessageTextFieldDecoration = InputDecoration(
  contentPadding: EdgeInsets.symmetric(
    vertical: 12.0,
    horizontal: 20.0,
  ),
  hintText: 'Type a message...',
  hintStyle: TextStyle(
    color: AppColors.textMuted,
    fontSize: 14,
  ),
  border: InputBorder.none,
  enabledBorder: InputBorder.none,
  focusedBorder: InputBorder.none,
);

const kMessageContainerDecoration = BoxDecoration(
  color: AppColors.surface,
  border: Border(
    top: BorderSide(
      color: AppColors.divider,
      width: 0.5,
    ),
  ),
);

// ── Auth Screen Decorations ──────────────────────────────────────────

final kTextFieldDecoration = InputDecoration(
  hintText: 'Enter a value',
  hintStyle: const TextStyle(
    color: AppColors.textMuted,
    fontSize: 14,
  ),
  filled: true,
  fillColor: AppColors.inputBackground,
  contentPadding: const EdgeInsets.symmetric(
    vertical: 14,
    horizontal: 20.0,
  ),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(AppRadius.full),
    borderSide: const BorderSide(color: AppColors.inputBorder),
  ),
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(AppRadius.full),
    borderSide: const BorderSide(color: AppColors.inputBorder),
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(AppRadius.full),
    borderSide: const BorderSide(
      color: AppColors.accentPrimary,
      width: 1.5,
    ),
  ),
  errorBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(AppRadius.full),
    borderSide: const BorderSide(color: AppColors.error),
  ),
  focusedErrorBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(AppRadius.full),
    borderSide: const BorderSide(color: AppColors.error, width: 1.5),
  ),
  errorStyle: const TextStyle(color: AppColors.error, fontSize: 12),
);
