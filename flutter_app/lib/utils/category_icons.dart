import 'package:flutter/material.dart';

/// Categorias predefinidas e mapeamento para ícones.
/// Para adicionar ícones a novas categorias, edite [getIcon] e, se quiser, [builtIn].
class CategoryIcons {
  CategoryIcons._();

  static const List<String> builtIn = [
    'streaming',
    'music',
    'cloud',
    'games',
    'software',
    'health',
    'education',
  ];

  /// Ícone para a categoria. Categorias desconhecidas usam [Icons.receipt_long_outlined].
  static IconData getIcon(String? category) {
    switch (category?.toLowerCase()) {
      case 'streaming':
        return Icons.movie_filter_outlined;
      case 'music':
        return Icons.headphones_outlined;
      case 'cloud':
        return Icons.cloud_outlined;
      case 'games':
        return Icons.sports_esports_outlined;
      case 'software':
        return Icons.code_outlined;
      case 'health':
        return Icons.favorite_outline;
      case 'education':
        return Icons.school_outlined;
      default:
        return Icons.receipt_long_outlined;
    }
  }

  /// Nome para exibição: primeira letra maiúscula.
  static String displayName(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1).toLowerCase();
  }
}
