import 'package:flutter/material.dart';

class ThemeModel {
  final String id;
  final String name;
  final String nameEn;
  final Color primaryColor;
  final Color secondaryColor;
  final Color accentColor;
  final Color backgroundColor;
  final Color surfaceColor;
  final Color textColor;
  final Color textSecondaryColor;

  ThemeModel({
    required this.id,
    required this.name,
    required this.nameEn,
    required this.primaryColor,
    required this.secondaryColor,
    required this.accentColor,
    required this.backgroundColor,
    required this.surfaceColor,
    required this.textColor,
    required this.textSecondaryColor,
  });

  static ThemeModel getTheme(String themeId) {
    switch (themeId) {
      case 'default':
        return ThemeModel(
          id: 'default',
          name: 'Baħar u Sema',
          nameEn: 'Sea & Sky',
          primaryColor: const Color(0xFF1E40AF),
          secondaryColor: const Color(0xFFF97316),
          accentColor: const Color(0xFF0D9488),
          backgroundColor: const Color(0xFF1E40AF),
          surfaceColor: Colors.white.withValues(alpha: 0.1),
          textColor: Colors.white,
          textSecondaryColor: const Color(0xFFDBEAFE),
        );
      case 'terracotta':
        return ThemeModel(
          id: 'terracotta',
          name: 'Ħamra tal-Art',
          nameEn: 'Earth Red',
          primaryColor: const Color(0xFFC2410C),
          secondaryColor: const Color(0xFFD97706),
          accentColor: const Color(0xFF059669),
          backgroundColor: const Color(0xFFC2410C),
          surfaceColor: const Color(0xFFFFF7ED).withValues(alpha: 0.2),
          textColor: const Color(0xFFFEF3C7),
          textSecondaryColor: const Color(0xFFFEF3C7),
        );
      case 'mediterranean':
        return ThemeModel(
          id: 'mediterranean',
          name: 'Blu Mediterran',
          nameEn: 'Mediterranean Blue',
          primaryColor: const Color(0xFF1E3A8A),
          secondaryColor: const Color(0xFFF59E0B),
          accentColor: const Color(0xFF0EA5E9),
          backgroundColor: const Color(0xFF1E3A8A),
          surfaceColor: const Color(0xFFEFF6FF).withValues(alpha: 0.15),
          textColor: const Color(0xFFEFF6FF),
          textSecondaryColor: const Color(0xFFDBEAFE),
        );
      case 'limestone':
        return ThemeModel(
          id: 'limestone',
          name: 'Ġebla tal-Franka',
          nameEn: 'Limestone',
          primaryColor: const Color(0xFF57534E),
          secondaryColor: const Color(0xFFD97706),
          accentColor: const Color(0xFF059669),
          backgroundColor: const Color(0xFF57534E),
          surfaceColor: const Color(0xFFF5F5F4).withValues(alpha: 0.2),
          textColor: const Color(0xFFFAFAF9),
          textSecondaryColor: const Color(0xFFE7E5E4),
        );
      case 'heritage':
        return ThemeModel(
          id: 'heritage',
          name: 'Wirt Antik',
          nameEn: 'Ancient Heritage',
          primaryColor: const Color(0xFF065F46),
          secondaryColor: const Color(0xFFCA8A04),
          accentColor: const Color(0xFFE11D48),
          backgroundColor: const Color(0xFF065F46),
          surfaceColor: const Color(0xFFECFDF5).withValues(alpha: 0.15),
          textColor: const Color(0xFFECFDF5),
          textSecondaryColor: const Color(0xFFD1FAE5),
        );
      case 'luzzu':
        return ThemeModel(
          id: 'luzzu',
          name: 'Luzzu Tradizzjonali',
          nameEn: 'Traditional Luzzu',
          primaryColor: const Color(0xFF3B82F6),
          secondaryColor: const Color(0xFFEAB308),
          accentColor: const Color(0xFF22C55E),
          backgroundColor: const Color(0xFF3B82F6),
          surfaceColor: Colors.white.withValues(alpha: 0.15),
          textColor: Colors.white,
          textSecondaryColor: const Color(0xFFFEF3C7),
        );
      case 'harbor':
        return ThemeModel(
          id: 'harbor',
          name: 'Port tal-Gżira',
          nameEn: 'Island Harbor',
          primaryColor: const Color(0xFFD97706),
          secondaryColor: const Color(0xFFF97316),
          accentColor: const Color(0xFF0EA5E9),
          backgroundColor: const Color(0xFFD97706),
          surfaceColor: const Color(0xFFFFF7ED).withValues(alpha: 0.2),
          textColor: Colors.white,
          textSecondaryColor: const Color(0xFFFEF3C7),
        );
      case 'lagoon':
        return ThemeModel(
          id: 'lagoon',
          name: 'Laguna Torquoise',
          nameEn: 'Turquoise Lagoon',
          primaryColor: const Color(0xFF22D3EE),
          secondaryColor: const Color(0xFFEAB308),
          accentColor: const Color(0xFF10B981),
          backgroundColor: const Color(0xFF22D3EE),
          surfaceColor: const Color(0xFFECFEFF).withValues(alpha: 0.2),
          textColor: Colors.white,
          textSecondaryColor: const Color(0xFFCFFAFE),
        );
      case 'nightharbor':
        return ThemeModel(
          id: 'nightharbor',
          name: 'Lejl fil-Port',
          nameEn: 'Night Harbor',
          primaryColor: const Color(0xFF111827),
          secondaryColor: const Color(0xFFEAB308),
          accentColor: const Color(0xFF22D3EE),
          backgroundColor: const Color(0xFF111827),
          surfaceColor: const Color(0xFF1E293B).withValues(alpha: 0.4),
          textColor: const Color(0xFFF1F5F9),
          textSecondaryColor: const Color(0xFFCBD5E1),
        );
      case 'deepcave':
        return ThemeModel(
          id: 'deepcave',
          name: 'Dlam ta\' Għar',
          nameEn: 'Deep Cave',
          primaryColor: Colors.black,
          secondaryColor: const Color(0xFFFB923C),
          accentColor: const Color(0xFF10B981),
          backgroundColor: Colors.black,
          surfaceColor: const Color(0xFF1F2937).withValues(alpha: 0.5),
          textColor: const Color(0xFFFAFAFA),
          textSecondaryColor: const Color(0xFFE5E7EB),
        );
      case 'monochrome':
        return ThemeModel(
          id: 'monochrome',
          name: 'Griż Pur',
          nameEn: 'Pure Gray',
          primaryColor: const Color(0xFF374151),
          secondaryColor: const Color(0xFF6B7280),
          accentColor: const Color(0xFF9CA3AF),
          backgroundColor: const Color(0xFF374151),
          surfaceColor: const Color(0xFFF9FAFB).withValues(alpha: 0.15),
          textColor: const Color(0xFFF9FAFB),
          textSecondaryColor: const Color(0xFFE5E7EB),
        );
      case 'highcontrast':
        return ThemeModel(
          id: 'highcontrast',
          name: 'Kuntrast Għoli',
          nameEn: 'High Contrast',
          primaryColor: Colors.black,
          secondaryColor: const Color(0xFF374151),
          accentColor: const Color(0xFF6B7280),
          backgroundColor: Colors.black,
          surfaceColor: const Color(0xFFF3F4F6).withValues(alpha: 0.2),
          textColor: Colors.white,
          textSecondaryColor: const Color(0xFFE5E7EB),
        );
      case 'paperwhite':
        return ThemeModel(
          id: 'paperwhite',
          name: 'Karta Bajda',
          nameEn: 'Paper White',
          primaryColor: const Color(0xFFF9FAFB),
          secondaryColor: const Color(0xFFE5E7EB),
          accentColor: const Color(0xFFD1D5DB),
          backgroundColor: const Color(0xFFF9FAFB),
          surfaceColor: const Color(0xFF374151).withValues(alpha: 0.1),
          textColor: const Color(0xFF111827),
          textSecondaryColor: const Color(0xFF6B7280),
        );
      case 'charcoal':
        return ThemeModel(
          id: 'charcoal',
          name: 'Faħam Iswed',
          nameEn: 'Charcoal',
          primaryColor: const Color(0xFF1F2937),
          secondaryColor: const Color(0xFF4B5563),
          accentColor: const Color(0xFF6B7280),
          backgroundColor: const Color(0xFF1F2937),
          surfaceColor: const Color(0xFFF3F4F6).withValues(alpha: 0.15),
          textColor: const Color(0xFFF9FAFB),
          textSecondaryColor: const Color(0xFFE5E7EB),
        );
      case 'minimal':
        return ThemeModel(
          id: 'minimal',
          name: 'Minimaliżmu',
          nameEn: 'Minimalism',
          primaryColor: const Color(0xFF6B7280),
          secondaryColor: const Color(0xFF9CA3AF),
          accentColor: const Color(0xFFD1D5DB),
          backgroundColor: const Color(0xFF6B7280),
          surfaceColor: const Color(0xFFF9FAFB).withValues(alpha: 0.2),
          textColor: const Color(0xFFF9FAFB),
          textSecondaryColor: const Color(0xFFE5E7EB),
        );
      default:
        return getTheme('default');
    }
  }

  static List<ThemeModel> getAllThemes() {
    return [
      getTheme('default'),
      getTheme('terracotta'),
      getTheme('mediterranean'),
      getTheme('limestone'),
      getTheme('heritage'),
      getTheme('luzzu'),
      getTheme('harbor'),
      getTheme('lagoon'),
      getTheme('nightharbor'),
      getTheme('deepcave'),
      getTheme('monochrome'),
      getTheme('highcontrast'),
      getTheme('paperwhite'),
      getTheme('charcoal'),
      getTheme('minimal'),
    ];
  }
}
