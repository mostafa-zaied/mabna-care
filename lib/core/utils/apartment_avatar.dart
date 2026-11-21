import 'dart:typed_data';

import 'package:flutter/material.dart';

/// Deterministic Material-Icon avatar per apartment number until the resident
/// uploads their own custom profile photo.
class ApartmentAvatar extends StatelessWidget {
  final int aptNum;
  final String? avatarUrl;
  final Uint8List? localBytes;
  final double size;
  final double borderRadius;

  const ApartmentAvatar({
    super.key,
    required this.aptNum,
    this.avatarUrl,
    this.localBytes,
    this.size = 46,
    this.borderRadius = 14,
  });

  static const _icons = <IconData>[
    Icons.face_rounded,
    Icons.face_2_rounded,
    Icons.face_3_rounded,
    Icons.face_4_rounded,
    Icons.face_5_rounded,
    Icons.face_6_rounded,
    Icons.sentiment_satisfied_alt_rounded,
    Icons.person_rounded,
    Icons.emoji_people_rounded,
    Icons.psychology_alt_rounded,
    Icons.mood_rounded,
    Icons.record_voice_over_rounded,
  ];

  static const _gradients = <List<Color>>[
    [Color(0xFF2563EB), Color(0xFF10B981)],
    [Color(0xFF7C3AED), Color(0xFF3B82F6)],
    [Color(0xFF0EA5E9), Color(0xFF14B8A6)],
    [Color(0xFFF59E0B), Color(0xFFEA580C)],
    [Color(0xFFEC4899), Color(0xFF8B5CF6)],
    [Color(0xFF059669), Color(0xFF0284C7)],
  ];

  @override
  Widget build(BuildContext context) {
    final idx = (aptNum.abs() * 7 + 3);
    final icon = _icons[idx % _icons.length];
    final colors = _gradients[aptNum.abs() % _gradients.length];

    Widget fallback() => Icon(
          icon,
          size: size * 0.56,
          color: Colors.white,
        );

    final hasUrl = avatarUrl != null && avatarUrl!.trim().isNotEmpty;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
        ),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      clipBehavior: Clip.antiAlias,
      alignment: Alignment.center,
      child: localBytes != null
          ? Image.memory(
              localBytes!,
              width: size,
              height: size,
              fit: BoxFit.cover,
            )
          : (hasUrl
              ? Image.network(
                  avatarUrl!.trim(),
                  width: size,
                  height: size,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => fallback(),
                )
              : fallback()),
    );
  }
}
