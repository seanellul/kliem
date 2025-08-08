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

  // Gradients & design tokens
  // A soft background gradient tuned to work across light/dark themes.
  // Order: start → mid → end. Screens should use these directly for
  // backgrounds to keep the visual language consistent across themes.
  List<Color> get backgroundGradient => [
        backgroundColor.withOpacity(0.90),
        primaryColor,
        Color.lerp(primaryColor, backgroundColor, 0.15)!.withOpacity(0.85),
        Color.lerp(primaryColor, secondaryColor, 0.25)!.withOpacity(0.40),
      ];

  // Primary CTA (e.g., Word Hunt). Warm blend from secondary into primary.
  List<Color> get primaryButtonGradient => [
        secondaryColor,
        Color.lerp(secondaryColor, primaryColor, 0.35)!,
        Color.lerp(secondaryColor, primaryColor, 0.70)!,
      ];

  // Secondary CTA (e.g., Word-Dex). Crisp blend from accent into primary.
  List<Color> get secondaryButtonGradient => [
        accentColor,
        Color.lerp(accentColor, primaryColor, 0.35)!,
        Color.lerp(accentColor, primaryColor, 0.70)!,
      ];

  static ThemeModel getTheme(String themeId) {
    switch (themeId) {
      case 'default':
        return ThemeModel(
          id: 'default',
          name: 'Baħar u Sajf',
          nameEn: 'Summer Seas',
          primaryColor: const Color(0xFF1E40AF),
          secondaryColor: const Color(0xFFF97316),
          accentColor: const Color(0xFF0D9488),
          backgroundColor: const Color(0xFF1E40AF),
          surfaceColor: Colors.white.withOpacity(0.1),
          textColor: Colors.white,
          textSecondaryColor: const Color(0xFFDBEAFE),
        );
      case 'terracotta':
        return ThemeModel(
          id: 'terracotta',
          name: 'L-Art l-Ħamra',
          nameEn: 'The Red Earth',
          primaryColor: const Color(0xFFC2410C),
          secondaryColor: const Color(0xFFD97706),
          accentColor: const Color(0xFF059669),
          backgroundColor: const Color(0xFFC2410C),
          surfaceColor: const Color(0xFFFFF7ED).withOpacity(0.2),
          textColor: const Color(0xFFFEF3C7),
          textSecondaryColor: const Color(0xFFFEF3C7),
        );
      case 'mediterranean':
        return ThemeModel(
          id: 'mediterranean',
          name: 'Il-Blu tal-Mediterran',
          nameEn: 'Mediterranean Blue',
          primaryColor: const Color(0xFF1E3A8A),
          accentColor: const Color(0xFFF59E0B),
          secondaryColor: const Color(0xFF0EA5E9),
          backgroundColor: const Color(0xFF1E3A8A),
          surfaceColor: const Color(0xFF2446A6).withOpacity(0.15),
          textColor: const Color(0xFFEFF6FF),
          textSecondaryColor: const Color(0xFFDBEAFE),
        );
      case 'limestone':
        return ThemeModel(
          id: 'limestone',
          name: 'Il-Ġebla tal-Franka',
          nameEn: 'Limestone',
          primaryColor: const Color(0xFF57534E),
          accentColor: const Color.fromARGB(255, 148, 85, 12),
          secondaryColor: const Color(0xFF059669),
          backgroundColor: const Color(0xFF57534E),
          surfaceColor: const Color(0xFFF5F5F4).withOpacity(0.2),
          textColor: const Color(0xFFFAFAF9),
          textSecondaryColor: const Color(0xFFE7E5E4),
        );
      case 'heritage':
        return ThemeModel(
          id: 'heritage',
          name: 'Il-Wirt l\'Antik',
          nameEn: 'Ancient Heritage',
          primaryColor: const Color.fromARGB(255, 7, 65, 48),
          accentColor: const Color(0xFFCA8A04),
          secondaryColor: const Color.fromARGB(255, 191, 46, 77),
          backgroundColor: const Color(0xFF065F46),
          surfaceColor: const Color(0xFFECFDF5).withOpacity(0.15),
          textColor: const Color(0xFFECFDF5),
          textSecondaryColor: const Color(0xFFD1FAE5),
        );
      case 'luzzu':
        return ThemeModel(
          id: 'luzzu',
          name: 'Il-Luzzu',
          nameEn: 'The Luzzu',
          primaryColor: const Color(0xFF3B82F6),
          accentColor: const Color.fromARGB(255, 143, 111, 17),
          secondaryColor: const Color(0xFF22C55E),
          backgroundColor: const Color(0xFF3B82F6),
          surfaceColor: Colors.white.withOpacity(0.15),
          textColor: Colors.white,
          textSecondaryColor: const Color(0xFFFEF3C7),
        );
      case 'sdm':
        return ThemeModel(
          id: 'sdm',
          name: 'L-SDM',
          nameEn: 'SDM',
          primaryColor: const Color(0xFF3B82F6),
          accentColor: const Color.fromARGB(255, 0, 0, 0),
          secondaryColor: const Color(0xFF3B82F6).withOpacity(0.5),
          backgroundColor: const Color(0xFF3B82F6),
          surfaceColor: Colors.white.withOpacity(0.15),
          textColor: Colors.white,
          textSecondaryColor: const Color(0xFFFEF3C7),
        );
      case 'harbor':
        return ThemeModel(
          id: 'harbor',
          name: 'Il-Polz',
          nameEn: 'Pulse',
          primaryColor: const Color(0xFFD97706),
          secondaryColor: const Color(0xFFF97316),
          accentColor: const Color.fromARGB(255, 31, 36, 38),
          backgroundColor: const Color(0xFFD97706),
          surfaceColor: const Color(0xFFFFF7ED).withOpacity(0.2),
          textColor: Colors.white,
          textSecondaryColor: const Color(0xFFFEF3C7),
        );
      case 'lagoon':
        return ThemeModel(
          id: 'lagoon',
          name: 'Il-Laguna',
          nameEn: 'The Lagoon',
          primaryColor: const Color(0xFF22D3EE),
          accentColor: const Color(0xFFEAB308),
          secondaryColor: const Color(0xFF10B981),
          backgroundColor: const Color(0xFF22D3EE),
          surfaceColor: const Color(0xFFECFEFF).withOpacity(0.2),
          textColor: Colors.white,
          textSecondaryColor: const Color(0xFFCFFAFE),
        );
      case 'nightharbor':
        return ThemeModel(
          id: 'nightharbor',
          name: 'Lejl fil-Port',
          nameEn: 'Night Harbor',
          primaryColor: const Color(0xFF111827),
          accentColor: const Color(0xFFEAB308),
          secondaryColor: const Color(0xFF22D3EE),
          backgroundColor: const Color(0xFF111827),
          surfaceColor: const Color(0xFF1E293B).withOpacity(0.4),
          textColor: const Color(0xFFF1F5F9),
          textSecondaryColor: const Color(0xFFCBD5E1),
        );
      case 'deepcave':
        return ThemeModel(
          id: 'deepcave',
          name: 'Id-Dlam ta\' l-Għar',
          nameEn: 'Dark Cave',
          primaryColor: Colors.black,
          secondaryColor: const Color(0xFFFB923C),
          accentColor: const Color(0xFF10B981),
          backgroundColor: Colors.black,
          surfaceColor: const Color(0xFF1F2937).withOpacity(0.5),
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
          surfaceColor: const Color(0xFFF9FAFB).withOpacity(0.15),
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
          surfaceColor: const Color(0xFFF3F4F6).withOpacity(0.2),
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
          accentColor: const Color(0xFF374151).withOpacity(0.35),
          backgroundColor: const Color(0xFFF9FAFB),
          surfaceColor: const Color(0xFF374151).withOpacity(0.1),
          textColor: const Color(0xFF111827),
          textSecondaryColor: const Color(0xFF6B7280),
        );
      case 'charcoal':
        return ThemeModel(
          id: 'charcoal',
          name: 'Faħam',
          nameEn: 'Charcoal',
          primaryColor: const Color(0xFF1F2937),
          accentColor: const Color(0xFF4B5563),
          secondaryColor: const Color(0xFF6B7280),
          backgroundColor: const Color(0xFF1F2937),
          surfaceColor: const Color(0xFFF3F4F6).withOpacity(0.15),
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
          surfaceColor: const Color(0xFFF9FAFB).withOpacity(0.2),
          textColor: const Color(0xFFF9FAFB),
          textSecondaryColor: const Color(0xFFE5E7EB),
        );
      case 'architecture':
        return ThemeModel(
          id: 'architecture',
          name: 'Architettura',
          nameEn: 'Architecture',
          primaryColor: const Color(0xFFF1E8BE),
          secondaryColor: const Color(0xFF693D1E),
          accentColor: const Color(0xFFB55D1F),
          backgroundColor: const Color(0xFF888D7E),
          surfaceColor: const Color(0xFFA28242).withOpacity(0.2),
          textColor: const Color(0xFF000000),
          textSecondaryColor: const Color.fromARGB(255, 60, 62, 66),
        );
      case 'redblue':
        return ThemeModel(
          id: 'redblue',
          name: 'Ahmar u Blu',
          nameEn: 'Red & Blue',
          primaryColor: const Color(0xFF2E4170),
          secondaryColor: const Color(0xFF505688),
          accentColor: const Color.fromARGB(255, 187, 71, 56),
          backgroundColor: const Color(0xFF3E3B44),
          surfaceColor: const Color(0xFF505688).withOpacity(0.2),
          textColor: const Color.fromARGB(255, 255, 255, 255),
          textSecondaryColor: const Color.fromARGB(255, 205, 205, 206),
        );
      default:
        return getTheme('default');
    }
  }

  static List<ThemeModel> getAllThemes() {
    return [
      getTheme('default'),
      getTheme('architecture'),
      getTheme('redblue'),
      getTheme('nightharbor'),
      getTheme('terracotta'),
      getTheme('charcoal'),
      getTheme('mediterranean'),
      getTheme('luzzu'),
      getTheme('limestone'),
      getTheme('heritage'),
      getTheme('deepcave'),
      getTheme('sdm'),
      getTheme('harbor'),
      getTheme('lagoon'),
      getTheme('monochrome'),
      getTheme('highcontrast'),
      getTheme('paperwhite'),
      getTheme('minimal'),
    ];
  }
}
