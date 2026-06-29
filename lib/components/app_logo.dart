import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flashchat_app/constants/app_theme.dart';

class AppLogo extends StatelessWidget {
  final double size;
  const AppLogo({Key? key, this.size = 80}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double iconSize = size * 0.55;

    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 1. Soft Double Outer Glow
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.accentPrimary.withValues(alpha: 0.35),
                  blurRadius: size * 0.4,
                  spreadRadius: size * 0.05,
                ),
                BoxShadow(
                  color: AppColors.accentSecondary.withValues(alpha: 0.2),
                  blurRadius: size * 0.6,
                  spreadRadius: -size * 0.02,
                ),
              ],
            ),
          ),

          // 2. Gradient Border Ring
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  AppColors.accentPrimary,
                  AppColors.accentSecondary.withValues(alpha: 0.8),
                  AppColors.accentPrimary.withValues(alpha: 0.5),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            padding: const EdgeInsets.all(2.5), // border width
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.surface,
              ),
              child: ClipOval(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: Container(
                    color: Colors.white.withValues(alpha: 0.02),
                  ),
                ),
              ),
            ),
          ),

          // 3. Glassmorphic Secondary Chat Bubble Badge
          Positioned(
            bottom: size * 0.04,
            right: size * 0.04,
            child: Container(
              width: size * 0.26,
              height: size * 0.26,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [
                    AppColors.accentSecondary,
                    AppColors.accentPrimary,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),

          // 4. Center Glowing Bolt Symbol with Multi-Stop Gradient
          ShaderMask(
            shaderCallback: (bounds) {
              return const LinearGradient(
                colors: [
                  Colors.white,
                  Color(0xFFFFF7AD), // golden highlights
                  AppColors.accentPrimary,
                ],
                stops: [0.0, 0.45, 1.0],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ).createShader(bounds);
            },
            blendMode: BlendMode.srcIn,
            child: Icon(
              Icons.bolt_rounded,
              size: iconSize,
            ),
          ),
        ],
      ),
    );
  }
}
