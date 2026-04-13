import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/event_model.dart';
import '../models/partner_model.dart';
import '../services/firebase_service.dart';
import '../utils/constants.dart';
import '../widgets/event_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _svc = FirebaseService();
  String _selectedVille = 'Toutes';
  final _scrollCtrl = ScrollController();

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      backgroundColor: kDark,
      body: CustomScrollView(
        controller: _scrollCtrl,
        slivers: [
          // ── AppBar ──
          SliverAppBar(
            expandedHeight: 0,
            floating: true,
            snap: true,
            backgroundColor: kDark.withOpacity(0.95),
            elevation: 0,
            title: Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [kPrimary, Color(0xFFAB6FF8)]),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text('BAKA🎟️TIKET',
                      style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                          letterSpacing: 1)),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () =>
                      Navigator.pushNamed(context, '/partner-dashboard'),
                  icon: const Icon(Icons.dashboard_rounded,
                      color: kSecondary, size: 18),
                  label: Text('Espace Partenaire',
                      style: GoogleFonts.outfit(
                          color: kSecondary, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),

          // ── Hero Section ──
          SliverToBoxAdapter(child: _buildHero()),

          // ── Filtre villes ──
          SliverToBoxAdapter(child: _buildCityFilter()),

          // ── Titre section événements ──
          SliverToBoxAdapter(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 24,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                          colors: [kPrimary, kSecondary],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text('Top Événements',
                      style: GoogleFonts.outfit(
                          color: kTextPrimary,
                          fontSize: 22,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: kPrimary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('LIVE 🔴',
                        style: GoogleFonts.outfit(
                            color: kPrimary,
                            fontSize: 11,
                            fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ),
          ),

          // ── Grille événements (realtime Firebase) ──
          SliverToBoxAdapter(
            child: StreamBuilder<List<EventModel>>(
              stream: _svc.allEventsStream(),
              builder: (ctx, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(
                        child:
                            CircularProgressIndicator(color: kPrimary)),
                  );
                }
                final all = snap.data ?? [];
                final events = _selectedVille == 'Toutes'
                    ? all
                    : all
                        .where((e) => e.ville == _selectedVille)
                        .toList();

                if (events.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(40),
                    child: Center(
                      child: Column(
                        children: [
                          const Icon(Icons.event_busy_rounded,
                              color: kTextSecondary, size: 48),
                          const SizedBox(height: 12),
                          Text('Aucun événement disponible',
                              style: GoogleFonts.outfit(
                                  color: kTextSecondary, fontSize: 16)),
                          const SizedBox(height: 8),
                          Text(
                              'Soyez le premier à créer un événement !',
                              style: GoogleFonts.outfit(
                                  color: kTextSecondary.withOpacity(0.6),
                                  fontSize: 13)),
                        ],
                      ),
                    ),
                  );
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 8),
                  child: isWide
                      ? _buildWideGrid(events)
                      : _buildMobileList(events),
                );
              },
            ),
          ),

          // ── Section Partenaires ──
          SliverToBoxAdapter(child: _buildPartnersSection()),

          // ── Footer ──
          SliverToBoxAdapter(child: _buildFooter()),
        ],
      ),

      // ── FAB Créer événement ──
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () =>
            Navigator.pushNamed(context, '/partner-dashboard'),
        backgroundColor: kSecondary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: Text('Créer événement',
            style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
      ),
    );
  }

  Widget _buildHero() {
    return Container(
      height: 380,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF0D0D1A),
            Color(0xFF1A0A3E),
            Color(0xFF2D105A),
            Color(0xFF0D0D1A),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          // Cercles décoratifs
          Positioned(
            top: -60,
            right: -60,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: kPrimary.withOpacity(0.08),
              ),
            ),
          ),
          Positioned(
            bottom: -40,
            left: -40,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: kSecondary.withOpacity(0.08),
              ),
            ),
          ),
          // Contenu
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('🇨🇬 Billetterie #1 au Congo',
                    style: GoogleFonts.outfit(
                        color: kSecondary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 2))
                    .animate()
                    .fadeIn(delay: 100.ms),
                const SizedBox(height: 12),
                Text('Vos événements,\nnos billets.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      color: kTextPrimary,
                      fontSize: 48,
                      fontWeight: FontWeight.w800,
                      height: 1.1,
                    ))
                    .animate()
                    .fadeIn(delay: 200.ms)
                    .slideY(begin: 0.2, end: 0),
                const SizedBox(height: 16),
                Text(
                    'Pointe-Noire • Brazzaville • Dolisie\net toute la République du Congo',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                        color: kTextSecondary, fontSize: 16))
                    .animate()
                    .fadeIn(delay: 300.ms),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _heroBtn('Voir les événements', kPrimary, () {
                      _scrollCtrl.animateTo(400,
                          duration: const Duration(milliseconds: 600),
                          curve: Curves.easeOut);
                    }),
                    const SizedBox(width: 16),
                    _heroBtn('Espace Partenaire', kSecondary.withOpacity(0.15),
                        () => Navigator.pushNamed(
                            context, '/partner-dashboard'),
                        border: kSecondary),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _heroBtn(String label, Color bg, VoidCallback onTap,
      {Color? border}) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: bg,
        foregroundColor: Colors.white,
        padding:
            const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: border != null
              ? BorderSide(color: border, width: 1.5)
              : BorderSide.none,
        ),
        elevation: 0,
      ),
      child: Text(label,
          style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
    );
  }

  Widget _buildCityFilter() {
    final villes = ['Toutes', ...kVilles.take(6)];
    return SizedBox(
      height: 56,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        itemCount: villes.length,
        itemBuilder: (ctx, i) {
          final v = villes[i];
          final selected = _selectedVille == v;
          return GestureDetector(
            onTap: () => setState(() => _selectedVille = v),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                gradient: selected ? kPurpleGlow : null,
                color: selected ? null : kDarkCard,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: selected
                        ? Colors.transparent
                        : Colors.white.withOpacity(0.1)),
              ),
              child: Text(v,
                  style: GoogleFonts.outfit(
                      color: selected ? Colors.white : kTextSecondary,
                      fontWeight: selected
                          ? FontWeight.w700
                          : FontWeight.w400,
                      fontSize: 13)),
            ),
          );
        },
      ),
    );
  }

  Widget _buildWideGrid(List<EventModel> events) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        childAspectRatio: 0.72,
      ),
      itemCount: events.length,
      itemBuilder: (ctx, i) => EventCard(
        event: events[i],
        onReserver: () => Navigator.pushNamed(
            context, '/event/${events[i].id}'),
        onShare: () => _shareEvent(events[i]),
      ),
    );
  }

  Widget _buildMobileList(List<EventModel> events) {
    return Column(
      children: events
          .map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: EventCard(
                  event: e,
                  onReserver: () =>
                      Navigator.pushNamed(context, '/event/${e.id}'),
                  onShare: () => _shareEvent(e),
                ),
              ))
          .toList(),
    );
  }

  void _shareEvent(EventModel ev) {
    // Copier le lien dans le clipboard via dialog
    showDialog(
      context: context,
      builder: (_) => _ShareDialog(event: ev),
    );
  }

  Widget _buildPartnersSection() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 32),
      padding: const EdgeInsets.all(32),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0D0D1A), Color(0xFF16162B)],
        ),
      ),
      child: Column(
        children: [
          Text('💳 Nos Partenaires de Paiement',
              style: GoogleFonts.outfit(
                  color: kTextPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.w700),
              textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text('Payez facilement avec Mobile Money',
              style: GoogleFonts.outfit(
                  color: kTextSecondary, fontSize: 14),
              textAlign: TextAlign.center),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _partnerBadge('🟢 Airtel Money', '*186#', kAirtel),
              const SizedBox(width: 24),
              _partnerBadge('🟡 MTN Mobile Money', '*126#', kMTN),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: kSuccess.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: kSuccess.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.verified_rounded,
                    color: kSuccess, size: 20),
                const SizedBox(width: 8),
                Text(
                    '88% reversé au partenaire • 12% commission Bakatiket',
                    style: GoogleFonts.outfit(
                        color: kSuccess,
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _partnerBadge(String nom, String ussd, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.4), width: 1.5),
      ),
      child: Column(
        children: [
          Text(nom,
              style: GoogleFonts.outfit(
                  color: color,
                  fontSize: 16,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(ussd,
              style: GoogleFonts.outfit(
                  color: kTextSecondary, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(32),
      color: const Color(0xFF08080F),
      child: Column(
        children: [
          Text('BAKA🎟️TIKET',
              style: GoogleFonts.outfit(
                  color: kPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text('La billetterie numérique du Congo 🇨🇬',
              style: GoogleFonts.outfit(
                  color: kTextSecondary, fontSize: 14)),
          const SizedBox(height: 16),
          Text('© 2026 Bakatiket • Pointe-Noire, République du Congo',
              style:
                  GoogleFonts.outfit(color: kTextSecondary, fontSize: 12)),
        ],
      ),
    );
  }
}

// ── Dialog Share ──────────────────────────────────────────────────────────────
class _ShareDialog extends StatelessWidget {
  final EventModel event;
  const _ShareDialog({required this.event});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: kDarkCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Partager l\'événement',
                style: GoogleFonts.outfit(
                    color: kTextPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: kDark,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Text(event.shareLink,
                  style:
                      GoogleFonts.outfit(color: kTextSecondary, fontSize: 13)),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _shareBtn(context, '💬 WhatsApp', kSuccess,
                    whatsappShare(event.title, event.shareLink)),
                _shareBtn(context, '🐦 Twitter', const Color(0xFF1DA1F2),
                    twitterShare(event.title, event.shareLink)),
                _shareBtn(context, '📘 Facebook', const Color(0xFF1877F2),
                    facebookShare(event.shareLink)),
              ],
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Fermer',
                  style: GoogleFonts.outfit(color: kTextSecondary)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _shareBtn(
      BuildContext context, String label, Color color, String url) {
    return ElevatedButton(
      onPressed: () {
        // url_launcher sera utilisé ici
        Navigator.pop(context);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.15),
        foregroundColor: color,
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        side: BorderSide(color: color.withOpacity(0.3)),
      ),
      child:
          Text(label, style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}
