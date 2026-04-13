import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/event_model.dart';
import '../utils/constants.dart';

class EventCard extends StatefulWidget {
  final EventModel event;
  final VoidCallback? onReserver;
  final VoidCallback? onShare;

  const EventCard({
    super.key,
    required this.event,
    this.onReserver,
    this.onShare,
  });

  @override
  State<EventCard> createState() => _EventCardState();
}

class _EventCardState extends State<EventCard> {
  bool _hovered = false;

  String _formatPrice(int prix) {
    final f = NumberFormat('#,###', 'fr_FR');
    return '${f.format(prix)} FCFA';
  }

  String _formatDate(String date) {
    try {
      final d = DateTime.parse(date);
      return DateFormat('dd MMM yyyy • HH:mm', 'fr_FR').format(d);
    } catch (_) {
      return date;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ev = widget.event;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        transform: Matrix4.identity()
          ..translate(0.0, _hovered ? -6.0 : 0.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            colors: [Color(0xFF1E1E3A), Color(0xFF16162B)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: _hovered
                  ? kPrimary.withOpacity(0.4)
                  : Colors.black.withOpacity(0.3),
              blurRadius: _hovered ? 24 : 12,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(
            color: _hovered
                ? kPrimary.withOpacity(0.6)
                : Colors.white.withOpacity(0.07),
            width: 1.5,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Photo ──
              Stack(
                children: [
                  SizedBox(
                    height: 200,
                    width: double.infinity,
                    child: ev.photoUrl.isNotEmpty
                        ? Image.network(
                            ev.photoUrl,
                            fit: BoxFit.cover,
                            loadingBuilder: (ctx, child, progress) {
                              if (progress == null) return child;
                              return Container(
                                color: kDarkCard,
                                child: const Center(
                                  child: CircularProgressIndicator(
                                      color: kPrimary),
                                ),
                              );
                            },
                            errorBuilder: (_, __, ___) =>
                                _placeholderImage(ev.title),
                          )
                        : _placeholderImage(ev.title),
                  ),
                  // Featured badge
                  if (ev.marketing.featured)
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                              colors: [kSecondary, Color(0xFFFF9A00)]),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star_rounded,
                                color: Colors.white, size: 12),
                            const SizedBox(width: 4),
                            Text('FEATURED',
                                style: GoogleFonts.outfit(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1)),
                          ],
                        ),
                      ),
                    ),
                  // Promo badge
                  if (ev.marketing.promoCode.isNotEmpty)
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: kGold,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${ev.marketing.promoCode} -${ev.marketing.promoPercent}%',
                          style: GoogleFonts.outfit(
                              color: kDark,
                              fontSize: 10,
                              fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                  // Hover overlay avec Share
                  AnimatedOpacity(
                    opacity: _hovered ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: Container(
                      height: 200,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withOpacity(0.5),
                            Colors.transparent,
                          ],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                      ),
                      alignment: Alignment.bottomRight,
                      padding: const EdgeInsets.all(12),
                      child: GestureDetector(
                        onTap: widget.onShare,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: Colors.white.withOpacity(0.3)),
                          ),
                          child: const Icon(Icons.share_rounded,
                              color: Colors.white, size: 18),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // ── Contenu ──
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Ville + Date
                    Row(
                      children: [
                        const Icon(Icons.location_on_rounded,
                            color: kSecondary, size: 14),
                        const SizedBox(width: 4),
                        Text(ev.ville,
                            style: GoogleFonts.outfit(
                                color: kSecondary,
                                fontSize: 12,
                                fontWeight: FontWeight.w600)),
                        const Spacer(),
                        const Icon(Icons.calendar_today_rounded,
                            color: kTextSecondary, size: 12),
                        const SizedBox(width: 4),
                        Text(_formatDate(ev.date),
                            style: GoogleFonts.outfit(
                                color: kTextSecondary, fontSize: 11)),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Titre
                    Text(
                      ev.title,
                      style: GoogleFonts.outfit(
                        color: kTextPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),

                    // Tickets prix
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: ev.tickets.take(3).map((t) {
                        Color badgeColor;
                        switch (t.type.toLowerCase()) {
                          case 'gold':
                            badgeColor = kGold;
                            break;
                          case 'présidentiel':
                          case 'vvip':
                            badgeColor = kSecondary;
                            break;
                          default:
                            badgeColor = kPrimary;
                        }
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: badgeColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: badgeColor.withOpacity(0.4)),
                          ),
                          child: Text(
                            '${t.type} • ${_formatPrice(t.prix)}',
                            style: GoogleFonts.outfit(
                                color: badgeColor,
                                fontSize: 11,
                                fontWeight: FontWeight.w600),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),

                    // Bouton Réserver
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: widget.onReserver,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kPrimary,
                          foregroundColor: Colors.white,
                          padding:
                              const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.confirmation_number_rounded,
                                size: 16),
                            const SizedBox(width: 8),
                            Text('Réserver',
                                style: GoogleFonts.outfit(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _placeholderImage(String title) {
    return Container(
      height: 200,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF2D1B69), Color(0xFF6C3EE8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.event_rounded, color: Colors.white54, size: 48),
            const SizedBox(height: 8),
            Text(title,
                style: GoogleFonts.outfit(
                    color: Colors.white54, fontSize: 14),
                textAlign: TextAlign.center,
                maxLines: 2),
          ],
        ),
      ),
    );
  }
}
