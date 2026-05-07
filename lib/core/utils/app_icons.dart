/// Mapeamento centralizado de ícones Lucide para o Barber Hub.
/// Toda referência a LucideIcons no projeto passa por aqui,
/// garantindo substituição simples e tree-shaking eficiente.
library;

import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

export 'package:flutter_lucide/flutter_lucide.dart' show LucideIcons;

/// Ícones de capa das barbearias (substituem emojis ✂️ 🪒 👑)
class BarbershopIcons {
  BarbershopIcons._();
  static const IconData classica  = LucideIcons.scissors;   // ✂️ → scissors
  static const IconData urbano    = LucideIcons.zap;        // 🪒 → zap (modern/electric)
  static const IconData premium   = LucideIcons.crown;      // 👑 → crown

  /// Retorna ícone por chave salva no modelo
  static IconData fromKey(String key) {
    switch (key) {
      case 'scissors': return LucideIcons.scissors;
      case 'zap':      return LucideIcons.zap;
      case 'crown':    return LucideIcons.crown;
      case 'star':     return LucideIcons.star;
      default:         return LucideIcons.scissors;
    }
  }
}

/// Ícones de categoria de produto (substituem emojis 💈 🧴 🧔 ✨ ✂️ 🎁)
class ProductCategoryIcons {
  ProductCategoryIcons._();
  static const IconData pomade   = LucideIcons.sparkles;   // 💈 → sparkles (styling effect)
  static const IconData shampoo  = LucideIcons.droplets;   // 🧴 → droplets (liquid)
  static const IconData beard    = LucideIcons.user;       // 🧔 → user (grooming)
  static const IconData skincare = LucideIcons.sun;        // ✨ → sun (skin/radiance)
  static const IconData tool     = LucideIcons.scissors;   // ✂️ → scissors
  static const IconData kit      = LucideIcons.gift;       // 🎁 → gift
  static const IconData fallback = LucideIcons.package;    // 📦 → package

  static IconData fromKey(String key) {
    switch (key) {
      case 'pomade':   return pomade;
      case 'shampoo':  return shampoo;
      case 'beard':    return beard;
      case 'skincare': return skincare;
      case 'tool':     return tool;
      case 'kit':      return kit;
      default:         return fallback;
    }
  }
}

/// Ícones de avaliação (substituem emojis 🤩 😊 😐 😕 😞)
class RatingIcons {
  RatingIcons._();
  static const IconData excellent = LucideIcons.star;          // 🤩 → star
  static const IconData good      = LucideIcons.smile;         // 😊 → smile
  static const IconData neutral   = LucideIcons.meh;           // 😐 → meh
  static const IconData bad       = LucideIcons.frown;         // 😕 → frown
  static const IconData terrible  = LucideIcons.frown;         // 😞 → frown

  static IconData forRating(int rating) {
    switch (rating) {
      case 5:  return excellent;
      case 4:  return good;
      case 3:  return neutral;
      case 2:  return bad;
      default: return terrible;
    }
  }

  static Color colorForRating(int rating) {
    switch (rating) {
      case 5:  return const Color(0xFFFFD700);  // gold
      case 4:  return const Color(0xFF4CAF50);  // green
      case 3:  return const Color(0xFFFF9800);  // orange
      case 2:  return const Color(0xFFFF5722);  // deep orange
      default: return const Color(0xFFF44336);  // red
    }
  }
}

/// Ícones de bloqueio de data (substituem emojis 📅 🔄)
class BlockIcons {
  BlockIcons._();
  static const IconData specificDate  = LucideIcons.calendar_x_2;  // 📅 → calendar-x-2
  static const IconData allSundays    = LucideIcons.repeat;         // 🔄 → repeat
  static const IconData allSaturdays  = LucideIcons.repeat;         // 🔄 → repeat
}

/// Ícones de perfil/demo (substituem emojis 👤 ✂️ 💈 ⚙️)
class ProfileIcons {
  ProfileIcons._();
  static const IconData client    = LucideIcons.user;        // 👤
  static const IconData barbershop = LucideIcons.scissors;   // ✂️
  static const IconData barber    = LucideIcons.scissors;    // 💈
  static const IconData admin     = LucideIcons.settings;    // ⚙️
}
