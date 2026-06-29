import 'package:flutter/material.dart';
import 'package:flashchat_app/constants/app_theme.dart';

class AvatarWidget extends StatelessWidget {
  final String name;
  final double size;
  final bool showOnlineIndicator;
  final bool isOnline;

  const AvatarWidget({
    Key? key,
    required this.name,
    this.size = 40,
    this.showOnlineIndicator = false,
    this.isOnline = false,
  }) : super(key: key);

  String get _initials {
    if (name.isEmpty) return '?';
    if (name.contains('@')) {
      // Email: take first letter before @
      return name[0].toUpperCase();
    }
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }

  Color get _backgroundColor {
    // Generate a consistent color from the name
    final colors = [
      const Color(0xFF6C63FF),
      const Color(0xFF00D2FF),
      const Color(0xFFFF6B6B),
      const Color(0xFFFFAB40),
      const Color(0xFF00E676),
      const Color(0xFFE040FB),
      const Color(0xFF7C4DFF),
      const Color(0xFF00BCD4),
      const Color(0xFFFF5722),
      const Color(0xFF8BC34A),
    ];
    final index = name.hashCode.abs() % colors.length;
    return colors[index];
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _backgroundColor.withValues(alpha: 0.15),
            border: Border.all(
              color: _backgroundColor.withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: Center(
            child: Text(
              _initials,
              style: TextStyle(
                color: _backgroundColor,
                fontSize: size * 0.38,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        if (showOnlineIndicator)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: size * 0.3,
              height: size * 0.3,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isOnline ? AppColors.online : AppColors.textMuted,
                border: Border.all(
                  color: AppColors.background,
                  width: 2,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
