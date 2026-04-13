import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../models/event_model.dart';
import '../services/firebase_service.dart';
import '../utils/constants.dart';

class PartnerDashboard extends StatefulWidget {
  const PartnerDashboard({super.key});

  @override
  State<PartnerDashboard> createState() => _PartnerDashboardState();
}

class _PartnerDashboardState extends State<PartnerDashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  final _svc = FirebaseService();

  // Form state
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _promoCodeCtrl = TextEditingController();
  String _selectedVille = kVilles.first;
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 30));
  bool _featured = false;
  int _promoPercent = 0;
  List<String> _photoUrls = [];
  List<Map<String, dynamic>> _tickets = [
    {'type': 'Standard', 'prix': 5000, 'stock': 100},
  ];
  bool _submitting = false;
  String? _createdEventId;

  // PartnerId simulé (en prod: auth)
  final String _partnerId = 'airtel_money';

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _promoCodeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kDark,
      appBar: AppBar(
        backgroundColor: kDarkCard,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: kTextPrimary),
          onPressed: () => Navigator.pushNamed(context, '/'),
        ),
        title: Row(
          children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [kPrimary, Color(0xFFAB6FF8)]),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('BAKA🎟️TIKET',
                  style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 14)),
            ),
            const SizedBox(width: 10),
            Text('Espace Partenaire',
                style: GoogleFonts.outfit(
                    color: kTextSecondary, fontSize: 14)),
          ],
        ),
        bottom: TabBar(
          controller: _tabCtrl,
          indicatorColor: kPrimary,
          labelColor: kPrimary,
          unselectedLabelColor: kTextSecondary,
          tabs: [
            Tab(
                child: Text('➕ Créer événement',
                    style: GoogleFonts.outfit(fontWeight: FontWeight.w600))),
            Tab(
                child: Text('📋 Mes événements',
                    style: GoogleFonts.outfit(fontWeight: FontWeight.w600))),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: [
          _buildCreateForm(),
          _buildMyEvents(),
        ],
      ),
    );
  }

  // ─── Formulaire création événement ─────────────────────────────────────────

  Widget _buildCreateForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle('📝 Informations générales'),
            const SizedBox(height: 16),

            // Titre
            _field(
              controller: _titleCtrl,
              label: 'Titre de l\'événement',
              hint: 'Ex: Concert Fally Ipupa',
              icon: Icons.title_rounded,
              validator: (v) =>
                  v == null || v.isEmpty ? 'Titre requis' : null,
            ),
            const SizedBox(height: 16),

            // Ville
            _label('Ville'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: kDarkCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedVille,
                  dropdownColor: kDarkCard,
                  style: GoogleFonts.outfit(color: kTextPrimary),
                  isExpanded: true,
                  items: kVilles
                      .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedVille = v!),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Date
            _label('Date & Heure'),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: kDarkCard,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_month_rounded,
                        color: kPrimary, size: 20),
                    const SizedBox(width: 12),
                    Text(
                        DateFormat('dd MMMM yyyy • HH:mm', 'fr_FR')
                            .format(_selectedDate),
                        style: GoogleFonts.outfit(
                            color: kTextPrimary, fontSize: 15)),
                    const Spacer(),
                    const Icon(Icons.edit_calendar_rounded,
                        color: kTextSecondary, size: 16),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Description
            _field(
              controller: _descCtrl,
              label: 'Description',
              hint: 'Décrivez votre événement...',
              icon: Icons.description_rounded,
              maxLines: 4,
              validator: (v) =>
                  v == null || v.isEmpty ? 'Description requise' : null,
            ),
            const SizedBox(height: 24),

            // ── Photos ──
            _sectionTitle('📸 Photos (miniatures)'),
            const SizedBox(height: 12),
            _buildPhotoUpload(),
            const SizedBox(height: 24),

            // ── Tickets ──
            _sectionTitle('🎟️ Types de tickets'),
            const SizedBox(height: 12),
            ..._tickets.asMap().entries.map((e) => _ticketRow(e.key)),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _addTicket,
              icon: const Icon(Icons.add_rounded, color: kPrimary),
              label: Text('Ajouter un type de ticket',
                  style: GoogleFonts.outfit(color: kPrimary)),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: kPrimary.withOpacity(0.5)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 24),

            // ── Marketing ──
            _sectionTitle('📣 Marketing & Promo'),
            const SizedBox(height: 12),
            _buildMarketingSection(),
            const SizedBox(height: 32),

            // ── Bouton soumettre ──
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitting ? null : _submitEvent,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: _submitting
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.rocket_launch_rounded, size: 20),
                          const SizedBox(width: 10),
                          Text('Publier l\'événement',
                              style: GoogleFonts.outfit(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700)),
                        ],
                      ),
              ),
            ),

            // Résultat après création
            if (_createdEventId != null) _buildSuccessCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoUpload() {
    return Column(
      children: [
        if (_photoUrls.isNotEmpty)
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _photoUrls.length,
              itemBuilder: (_, i) => Container(
                margin: const EdgeInsets.only(right: 8),
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: kPrimary.withOpacity(0.4)),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(_photoUrls[i], fit: BoxFit.cover),
                ),
              ),
            ),
          ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: _pickPhoto,
          icon: const Icon(Icons.add_photo_alternate_rounded,
              color: kSecondary),
          label: Text(
              _photoUrls.length >= 2
                  ? 'Maximum 2 photos atteint'
                  : 'Ajouter une photo',
              style: GoogleFonts.outfit(color: kSecondary)),
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: kSecondary.withOpacity(0.4)),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }

  Widget _ticketRow(int index) {
    final t = _tickets[index];
    final types = kTicketTypes;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kDarkCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: t['type'],
                    dropdownColor: kDarkSurface,
                    style: GoogleFonts.outfit(color: kTextPrimary),
                    items: types
                        .map((tp) =>
                            DropdownMenuItem(value: tp, child: Text(tp)))
                        .toList(),
                    onChanged: (v) =>
                        setState(() => _tickets[index]['type'] = v),
                  ),
                ),
              ),
              if (_tickets.length > 1)
                IconButton(
                  onPressed: () =>
                      setState(() => _tickets.removeAt(index)),
                  icon: const Icon(Icons.delete_rounded,
                      color: Colors.red, size: 20),
                ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: _numField(
                  label: 'Prix (FCFA)',
                  value: t['prix'],
                  onChanged: (v) =>
                      setState(() => _tickets[index]['prix'] = v),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _numField(
                  label: 'Stock',
                  value: t['stock'],
                  onChanged: (v) =>
                      setState(() => _tickets[index]['stock'] = v),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _numField({
    required String label,
    required int value,
    required Function(int) onChanged,
  }) {
    final ctrl = TextEditingController(text: value.toString());
    return TextField(
      controller: ctrl,
      keyboardType: TextInputType.number,
      style: GoogleFonts.outfit(color: kTextPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.outfit(color: kTextSecondary, fontSize: 12),
        filled: true,
        fillColor: kDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: kPrimary),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
      onChanged: (v) => onChanged(int.tryParse(v) ?? 0),
    );
  }

  Widget _buildMarketingSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kDarkCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kGold.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Code promo
          _field(
            controller: _promoCodeCtrl,
            label: 'Code promo (optionnel)',
            hint: 'Ex: FALLY20',
            icon: Icons.local_offer_rounded,
          ),
          const SizedBox(height: 16),

          // Réduction %
          _label('Réduction (%)'),
          const SizedBox(height: 8),
          Slider(
            value: _promoPercent.toDouble(),
            min: 0,
            max: 50,
            divisions: 10,
            activeColor: kGold,
            label: '$_promoPercent%',
            onChanged: (v) => setState(() => _promoPercent = v.round()),
          ),
          Text('Réduction : $_promoPercent%',
              style: GoogleFonts.outfit(color: kGold, fontSize: 13)),
          const SizedBox(height: 16),

          // Featured toggle
          Row(
            children: [
              Switch(
                value: _featured,
                activeColor: kPrimary,
                onChanged: (v) => setState(() => _featured = v),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('⭐ Événement Featured',
                      style: GoogleFonts.outfit(
                          color: kTextPrimary, fontWeight: FontWeight.w600)),
                  Text('Visible en priorité sur l\'accueil',
                      style:
                          GoogleFonts.outfit(color: kTextSecondary, fontSize: 12)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessCard() {
    final link = 'https://bakatiket.cg/event/$_createdEventId';
    return Container(
      margin: const EdgeInsets.only(top: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kSuccess.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kSuccess.withOpacity(0.4)),
      ),
      child: Column(
        children: [
          const Icon(Icons.check_circle_rounded, color: kSuccess, size: 48),
          const SizedBox(height: 12),
          Text('Événement publié ! 🎉',
              style: GoogleFonts.outfit(
                  color: kSuccess,
                  fontSize: 20,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text('Visible sur l\'accueil en temps réel',
              style: GoogleFonts.outfit(color: kTextSecondary)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: kDark,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(link,
                style: GoogleFonts.outfit(color: kPrimary, fontSize: 13),
                textAlign: TextAlign.center),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(
                context, '/event/$_createdEventId'),
            style: ElevatedButton.styleFrom(
                backgroundColor: kPrimary, foregroundColor: Colors.white),
            child: Text('Voir l\'événement',
                style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    ).animate().fadeIn().scale();
  }

  // ─── Mes événements ────────────────────────────────────────────────────────

  Widget _buildMyEvents() {
    return StreamBuilder<List<EventModel>>(
      stream: _svc.partnerEventsStream(_partnerId),
      builder: (ctx, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(color: kPrimary));
        }
        final events = snap.data ?? [];
        if (events.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.event_note_rounded,
                    color: kTextSecondary, size: 56),
                const SizedBox(height: 16),
                Text('Aucun événement créé',
                    style: GoogleFonts.outfit(
                        color: kTextPrimary, fontSize: 18)),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => _tabCtrl.animateTo(0),
                  child: Text('Créer votre premier événement →',
                      style: GoogleFonts.outfit(color: kPrimary)),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(24),
          itemCount: events.length,
          itemBuilder: (_, i) => _partnerEventTile(events[i]),
        );
      },
    );
  }

  Widget _partnerEventTile(EventModel ev) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kDarkCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: ev.photoUrl.isNotEmpty
                ? Image.network(ev.photoUrl,
                    width: 70, height: 70, fit: BoxFit.cover)
                : Container(
                    width: 70,
                    height: 70,
                    color: kPrimary.withOpacity(0.2),
                    child: const Icon(Icons.event_rounded,
                        color: kPrimary, size: 30)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(ev.title,
                    style: GoogleFonts.outfit(
                        color: kTextPrimary, fontWeight: FontWeight.w700)),
                Text('${ev.ville} • ${ev.date.substring(0, 10)}',
                    style: GoogleFonts.outfit(
                        color: kTextSecondary, fontSize: 12)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (ev.marketing.featured)
                      _miniChip('⭐ Featured', kPrimary),
                    if (ev.marketing.promoCode.isNotEmpty) ...[
                      const SizedBox(width: 4),
                      _miniChip(ev.marketing.promoCode, kGold),
                    ],
                    const SizedBox(width: 4),
                    _miniChip('🟢 LIVE', kSuccess),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () =>
                Navigator.pushNamed(context, '/event/${ev.id}'),
            icon: const Icon(Icons.arrow_forward_ios_rounded,
                color: kTextSecondary, size: 16),
          ),
        ],
      ),
    );
  }

  Widget _miniChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: GoogleFonts.outfit(color: color, fontSize: 10)),
    );
  }

  // ─── Helpers ───────────────────────────────────────────────────────────────

  Widget _sectionTitle(String title) {
    return Text(title,
        style: GoogleFonts.outfit(
            color: kTextPrimary, fontSize: 18, fontWeight: FontWeight.w700));
  }

  Widget _label(String text) {
    return Text(text,
        style:
            GoogleFonts.outfit(color: kTextSecondary, fontSize: 13));
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    String? hint,
    IconData? icon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      style: GoogleFonts.outfit(color: kTextPrimary),
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: GoogleFonts.outfit(color: kTextSecondary),
        hintStyle: GoogleFonts.outfit(
            color: kTextSecondary.withOpacity(0.5)),
        prefixIcon: icon != null ? Icon(icon, color: kPrimary, size: 20) : null,
        filled: true,
        fillColor: kDarkCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: kPrimary, width: 2),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      builder: (ctx, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(primary: kPrimary),
        ),
        child: child!,
      ),
    );
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDate),
    );
    if (!mounted) return;
    setState(() {
      _selectedDate = DateTime(date.year, date.month, date.day,
          time?.hour ?? 20, time?.minute ?? 0);
    });
  }

  Future<void> _pickPhoto() async {
    if (_photoUrls.length >= 2) return;
    // En prod: ImagePicker → Cloudinary
    // Demo: URL placeholder
    setState(() {
      _photoUrls.add(
          'https://images.unsplash.com/photo-1540575467063-178a50c2df87?w=800');
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'Photo ajoutée (demo) • En prod: upload Cloudinary',
            style: GoogleFonts.outfit(color: Colors.white)),
        backgroundColor: kSuccess,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _addTicket() {
    setState(() {
      _tickets.add({'type': 'Standard', 'prix': 5000, 'stock': 50});
    });
  }

  Future<void> _submitEvent() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);

    try {
      final event = EventModel(
        id: '',
        partnerId: _partnerId,
        title: _titleCtrl.text.trim(),
        ville: _selectedVille,
        photos: _photoUrls,
        tickets: _tickets
            .map((t) => TicketType(
                  type: t['type'] ?? 'Standard',
                  prix: t['prix'] ?? 5000,
                  stock: t['stock'] ?? 50,
                ))
            .toList(),
        date: _selectedDate.toIso8601String(),
        description: _descCtrl.text.trim(),
        shareLink: '',
        marketing: MarketingInfo(
          promoCode: _promoCodeCtrl.text.trim(),
          promoPercent: _promoPercent,
          banner: '',
          featured: _featured,
        ),
        createdAt: DateTime.now().millisecondsSinceEpoch,
      );

      final id = await _svc.createEvent(event);
      if (!mounted) return;
      setState(() {
        _createdEventId = id;
        _submitting = false;
      });
      _tabCtrl.animateTo(1);
    } catch (e) {
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Erreur: $e',
            style: GoogleFonts.outfit(color: Colors.white)),
        backgroundColor: Colors.red,
      ));
    }
  }
}
