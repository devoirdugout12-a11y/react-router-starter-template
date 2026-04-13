import 'package:flutter/material.dart';

// ─── Couleurs Bakatiket ────────────────────────────────────────────────────────
const kPrimary = Color(0xFF6C3EE8);       // violet profond
const kSecondary = Color(0xFFFF6B35);     // orange Congo
const kGold = Color(0xFFFFD700);          // gold tickets
const kDark = Color(0xFF0D0D1A);          // fond sombre
const kDarkCard = Color(0xFF16162B);      // card fond
const kDarkSurface = Color(0xFF1E1E35);   // surface
const kTextPrimary = Color(0xFFFFFFFF);
const kTextSecondary = Color(0xFFB0B3C8);
const kSuccess = Color(0xFF00D97E);
const kAirtel = Color(0xFFE30613);
const kMTN = Color(0xFFFFCC00);

// ─── Gradients ────────────────────────────────────────────────────────────────
const kHeroGradient = LinearGradient(
  colors: [Color(0xFF0D0D1A), Color(0xFF1A0A3E), Color(0xFF0D0D1A)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

const kCardGradient = LinearGradient(
  colors: [Color(0xFF1E1E35), Color(0xFF16162B)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

const kPurpleGlow = LinearGradient(
  colors: [Color(0xFF6C3EE8), Color(0xFFAB6FF8)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

// ─── Commission ───────────────────────────────────────────────────────────────
const double kCommissionRate = 0.12;       // 12% Bakatiket
const double kPartnerRate = 0.88;          // 88% partenaire

// ─── Villes Congo ────────────────────────────────────────────────────────────
const List<String> kVilles = [
  'Pointe-Noire',
  'Brazzaville',
  'Dolisie',
  'Ewo',
  'Nkayi',
  'Impfondo',
  'Madingou',
  'Ouesso',
  'Sibiti',
  'Oyo',
  'Kinkala',
  'Autres',
];

// ─── Types de tickets ─────────────────────────────────────────────────────────
const List<String> kTicketTypes = [
  'Standard',
  'Gold',
  'Présidentiel',
  'VIP',
  'VVIP',
  'Early Bird',
];

// ─── Firebase DB URL ──────────────────────────────────────────────────────────
const String kFirebaseDbUrl = 'https://baka-ticket-2026-default-rtdb.firebaseio.com';

// ─── Cloudinary ───────────────────────────────────────────────────────────────
const String kCloudinaryCloudName = 'bakatiket';
const String kCloudinaryUploadPreset = 'bakatiket_unsigned';
const String kCloudinaryUploadUrl =
    'https://api.cloudinary.com/v1_1/bakatiket/image/upload';

// ─── Social share ─────────────────────────────────────────────────────────────
String whatsappShare(String text, String url) =>
    'https://wa.me/?text=${Uri.encodeComponent('$text $url')}';
String twitterShare(String text, String url) =>
    'https://twitter.com/intent/tweet?text=${Uri.encodeComponent(text)}&url=${Uri.encodeComponent(url)}';
String facebookShare(String url) =>
    'https://www.facebook.com/sharer/sharer.php?u=${Uri.encodeComponent(url)}';
