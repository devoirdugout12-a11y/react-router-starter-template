import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../models/event_model.dart';
import '../services/firebase_service.dart';
import '../utils/constants.dart';

class EventDetailScreen extends StatefulWidget {
  final String eventId;
  const EventDetailScreen({super.key, required this.eventId});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  final _svc = FirebaseService();
  TicketType? _selectedTicket;
  bool _purchasing = false;

  String _formatPrice(int prix) {
    final f = NumberFormat('#,###', 'fr_FR');
    return '${f.format(prix)} FCFA';
  }

  String _formatDate(String date) {
    try {
      final d = DateTime.parse(date);
      return DateFormat('EEEE dd MMMM yyyy • HH:mm', 'fr_FR').format(d);
    } catch (_) {
      return date;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kDark,
      body: FutureBuilder<EventModel?>(
        future: _svc.getEvent(widget.eventId),
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: kPrimary));
          }
          final ev = snap.data;
          if (ev == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline,
                      color: kTextSecondary, size: 48),
                  const SizedBox(height: 16),
                  Text('Événement introuvable',
                      style: GoogleFonts.outfit(
                          color: kTextPrimary, fontSize: 18)),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/'),
                    child: Text('Retour à l\'accueil',
                        style: GoogleFonts.outfit(color: kPrimary)),
                  ),
                ],
              ),
            );
          }
          return _buildDetail(ev);
        },
      ),
    );
  }

  Widget _buildDetail(EventModel ev) {
    return CustomScrollView(
      slivers: [
        // ── Hero image + AppBar ──
        SliverAppBar(
          expandedHeight: 320,
          pinned: true,
          backgroundColor: kDark,
          leading: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black38,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.arrow_back_rounded, color: Colors.white),
            ),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black38,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.share_rounded, color: Colors.white),
              ),
              onPressed: () => _showShareSheet(ev),
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: ev.photoUrl.isNotEmpty
                ? Image.network(ev.photoUrl, fit: BoxFit.cover)
                : Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                          colors: [Color(0xFF2D1B69), Color(0xFF6C3EE8)]),
                    ),
                    child: const Center(
                        child: Icon(Icons.event_rounded,
                            color: Colors.white30, size: 80)),
                  ),
          ),
        ),

        // ── Contenu détail ──
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Badges
                Row(
                  children: [
                    _chip(ev.ville, kSecondary, Icons.location_on_rounded),
                    const SizedBox(width: 8),
                    if (ev.marketing.featured)
                      _chip('Featured', kPrimary, Icons.star_rounded),
                    if (ev.marketing.promoCode.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      _chip('${ev.marketing.promoCode} -${ev.marketing.promoPercent}%',
                          kGold, Icons.local_offer_rounded,
                          textColor: kDark),
                    ],
                  ],
                ),
                const SizedBox(height: 16),

                // Titre
                Text(ev.title,
                    style: GoogleFonts.outfit(
                        color: kTextPrimary,
                        fontSize: 28,
                        fontWeight: FontWeight.w800))
                    .animate()
                    .fadeIn(),

                const SizedBox(height: 12),

                // Date
                Row(
                  children: [
                    const Icon(Icons.calendar_month_rounded,
                        color: kTextSecondary, size: 18),
                    const SizedBox(width: 8),
                    Text(_formatDate(ev.date),
                        style: GoogleFonts.outfit(
                            color: kTextSecondary, fontSize: 14)),
                  ],
                ),
                const SizedBox(height: 24),

                // Description
                Text('À propos',
                    style: GoogleFonts.outfit(
                        color: kTextPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Text(ev.description,
                    style: GoogleFonts.outfit(
                        color: kTextSecondary,
                        fontSize: 15,
                        height: 1.6)),
                const SizedBox(height: 32),

                // ── Sélection tickets ──
                Text('Choisissez votre ticket',
                    style: GoogleFonts.outfit(
                        color: kTextPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 16),
                ...ev.tickets.map((t) => _ticketOption(t)),
                const SizedBox(height: 24),

                // ── Bouton achat ──
                if (_selectedTicket != null) _buildCheckoutButton(ev),
                const SizedBox(height: 32),

                // ── QR Code + Share ──
                _buildShareSection(ev),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _chip(String label, Color color, IconData icon,
      {Color textColor = Colors.white}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 13),
          const SizedBox(width: 4),
          Text(label,
              style: GoogleFonts.outfit(
                  color: textColor == Colors.white ? color : textColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _ticketOption(TicketType t) {
    final isSelected = _selectedTicket?.type == t.type;
    final isSoldOut = t.stock == 0;

    Color accentColor;
    switch (t.type.toLowerCase()) {
      case 'gold':
        accentColor = kGold;
        break;
      case 'présidentiel':
      case 'vvip':
        accentColor = kSecondary;
        break;
      default:
        accentColor = kPrimary;
    }

    return GestureDetector(
      onTap: isSoldOut ? null : () => setState(() => _selectedTicket = t),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: isSoldOut ? kDarkCard.withOpacity(0.5) : kDarkCard,
          border: Border.all(
            color: isSelected
                ? accentColor
                : Colors.white.withOpacity(0.1),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                      color: accentColor.withOpacity(0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 4))
                ]
              : [],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.confirmation_number_rounded,
                  color: isSoldOut ? kTextSecondary : accentColor, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t.type,
                      style: GoogleFonts.outfit(
                          color: isSoldOut ? kTextSecondary : kTextPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 16)),
                  Text(isSoldOut ? 'Épuisé' : '${t.stock} places restantes',
                      style: GoogleFonts.outfit(
                          color: isSoldOut ? Colors.red.shade400 : kSuccess,
                          fontSize: 12)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(_formatPrice(t.prix),
                    style: GoogleFonts.outfit(
                        color: isSoldOut ? kTextSecondary : accentColor,
                        fontWeight: FontWeight.w800,
                        fontSize: 16)),
                if (isSelected)
                  const Icon(Icons.check_circle_rounded,
                      color: kSuccess, size: 18),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckoutButton(EventModel ev) {
    final t = _selectedTicket!;
    final split = _svc.calculateSplit(t.prix);

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: kDarkCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Column(
            children: [
              _splitRow('Prix ticket', _formatPrice(t.prix), kTextPrimary),
              _splitRow(
                  'Commission Bakatiket (12%)',
                  _formatPrice(split['bakatiket']!),
                  kTextSecondary),
              _splitRow(
                  'Partenaire (88%)',
                  _formatPrice(split['partenaire']!),
                  kSuccess),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _purchasing ? null : () => _processPurchase(ev),
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            child: _purchasing
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2))
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.payment_rounded, size: 20),
                      const SizedBox(width: 8),
                      Text(
                          'Payer avec Mobile Money • ${_formatPrice(t.prix)}',
                          style: GoogleFonts.outfit(
                              fontWeight: FontWeight.w700, fontSize: 15)),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _splitRow(String label, String value, Color valueColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style:
                  GoogleFonts.outfit(color: kTextSecondary, fontSize: 13)),
          Text(value,
              style: GoogleFonts.outfit(
                  color: valueColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _buildShareSection(EventModel ev) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kDarkCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        children: [
          Text('Partager cet événement 🔗',
              style: GoogleFonts.outfit(
                  color: kTextPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          // QR Code
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: QrImageView(
              data: ev.shareLink,
              version: QrVersions.auto,
              size: 140,
              backgroundColor: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          // Lien copiable
          GestureDetector(
            onTap: () {
              Clipboard.setData(ClipboardData(text: ev.shareLink));
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('Lien copié ! 🔗',
                    style: GoogleFonts.outfit(color: Colors.white)),
                backgroundColor: kSuccess,
                behavior: SnackBarBehavior.floating,
              ));
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: kDark,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: kPrimary.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.link_rounded, color: kPrimary, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(ev.shareLink,
                        style: GoogleFonts.outfit(
                            color: kPrimary, fontSize: 12),
                        overflow: TextOverflow.ellipsis),
                  ),
                  const Icon(Icons.copy_rounded,
                      color: kPrimary, size: 16),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Boutons sociaux
          Row(
            children: [
              Expanded(
                child: _socialBtn(
                    '💬 WhatsApp',
                    kSuccess,
                    whatsappShare(ev.title, ev.shareLink)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _socialBtn(
                    '📘 Facebook',
                    const Color(0xFF1877F2),
                    facebookShare(ev.shareLink)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _socialBtn(
                    '🐦 Twitter',
                    const Color(0xFF1DA1F2),
                    twitterShare(ev.title, ev.shareLink)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _socialBtn(String label, Color color, String url) {
    return ElevatedButton(
      onPressed: () {
        // En prod: url_launcher
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.15),
        foregroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 10),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(color: color.withOpacity(0.3))),
        elevation: 0,
      ),
      child: Text(label,
          style: GoogleFonts.outfit(
              fontSize: 11, fontWeight: FontWeight.w700)),
    );
  }

  void _showShareSheet(EventModel ev) {
    showModalBottomSheet(
      context: context,
      backgroundColor: kDarkCard,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text('Partager',
                style: GoogleFonts.outfit(
                    color: kTextPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 20),
            _buildShareSection(ev),
          ],
        ),
      ),
    );
  }

  void _processPurchase(EventModel ev) async {
    setState(() => _purchasing = true);
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() => _purchasing = false);

    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: kDarkCard,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle_rounded,
                  color: kSuccess, size: 64),
              const SizedBox(height: 16),
              Text('Paiement réussi ! 🎉',
                  style: GoogleFonts.outfit(
                      color: kTextPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text('Votre ticket ${_selectedTicket?.type} est confirmé.',
                  style: GoogleFonts.outfit(
                      color: kTextSecondary, fontSize: 14),
                  textAlign: TextAlign.center),
              const SizedBox(height: 16),
              Text(
                  '88% reversé à l\'organisateur\n12% commission Bakatiket',
                  style: GoogleFonts.outfit(
                      color: kTextSecondary, fontSize: 12),
                  textAlign: TextAlign.center),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/');
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimary,
                    foregroundColor: Colors.white),
                child: Text('Retour à l\'accueil',
                    style:
                        GoogleFonts.outfit(fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
