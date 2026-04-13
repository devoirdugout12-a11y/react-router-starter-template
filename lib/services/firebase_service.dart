import 'dart:convert';
import 'package:firebase_database/firebase_database.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import '../models/event_model.dart';
import '../models/partner_model.dart';
import '../utils/constants.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  final _db = FirebaseDatabase.instance;
  final _uuid = const Uuid();

  // ─── EVENTS ────────────────────────────────────────────────────────────────

  /// Stream des événements featured (accueil realtime)
  Stream<List<EventModel>> featuredEventsStream() {
    return _db
        .ref('events')
        .onValue
        .map((event) {
          final data = event.snapshot.value;
          if (data == null) return [];
          final map = Map<dynamic, dynamic>.from(data as Map);
          final events = map.entries
              .map((e) => EventModel.fromMap(
                    e.key.toString(),
                    Map<dynamic, dynamic>.from(e.value as Map),
                  ))
              .where((ev) => ev.marketing.featured)
              .toList();
          events.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return events;
        });
  }

  /// Stream de TOUS les événements
  Stream<List<EventModel>> allEventsStream() {
    return _db.ref('events').onValue.map((event) {
      final data = event.snapshot.value;
      if (data == null) return [];
      final map = Map<dynamic, dynamic>.from(data as Map);
      final events = map.entries
          .map((e) => EventModel.fromMap(
                e.key.toString(),
                Map<dynamic, dynamic>.from(e.value as Map),
              ))
          .toList();
      events.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return events;
    });
  }

  /// Stream événements d'un partenaire
  Stream<List<EventModel>> partnerEventsStream(String partnerId) {
    return allEventsStream().map((events) =>
        events.where((e) => e.partnerId == partnerId).toList());
  }

  /// Obtenir un événement par ID
  Future<EventModel?> getEvent(String eventId) async {
    final snap = await _db.ref('events/$eventId').get();
    if (!snap.exists || snap.value == null) return null;
    return EventModel.fromMap(
        eventId, Map<dynamic, dynamic>.from(snap.value as Map));
  }

  /// Créer un événement (push Firebase)
  Future<String> createEvent(EventModel event) async {
    final newId = 'event_${_uuid.v4().substring(0, 8)}';
    final eventWithId = EventModel(
      id: newId,
      partnerId: event.partnerId,
      title: event.title,
      ville: event.ville,
      photos: event.photos,
      tickets: event.tickets,
      date: event.date,
      description: event.description,
      shareLink: 'https://bakatiket.cg/event/$newId',
      marketing: event.marketing,
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );
    await _db.ref('events/$newId').set(eventWithId.toMap());
    return newId;
  }

  /// Mettre à jour le stock d'un ticket après achat
  Future<void> decrementTicketStock(
      String eventId, String ticketType) async {
    final ref = _db.ref('events/$eventId/tickets');
    final snap = await ref.get();
    if (!snap.exists) return;

    final list = (snap.value as List?) ?? [];
    for (int i = 0; i < list.length; i++) {
      final t = Map<dynamic, dynamic>.from(list[i] as Map);
      if (t['type'] == ticketType && (t['stock'] as int) > 0) {
        await _db
            .ref('events/$eventId/tickets/$i/stock')
            .set((t['stock'] as int) - 1);
        break;
      }
    }
  }

  // ─── PARTNERS ──────────────────────────────────────────────────────────────

  Future<List<PartnerModel>> getPartners() async {
    final snap = await _db.ref('partners').get();
    if (!snap.exists || snap.value == null) return _defaultPartners();
    final map = Map<dynamic, dynamic>.from(snap.value as Map);
    return map.entries
        .map((e) => PartnerModel.fromMap(
              e.key.toString(),
              Map<dynamic, dynamic>.from(e.value as Map),
            ))
        .toList();
  }

  Stream<List<PartnerModel>> partnersStream() {
    return _db.ref('partners').onValue.map((event) {
      final data = event.snapshot.value;
      if (data == null) return _defaultPartners();
      final map = Map<dynamic, dynamic>.from(data as Map);
      return map.entries
          .map((e) => PartnerModel.fromMap(
                e.key.toString(),
                Map<dynamic, dynamic>.from(e.value as Map),
              ))
          .toList();
    });
  }

  List<PartnerModel> _defaultPartners() => [
        PartnerModel(
          id: 'airtel_money',
          nom: 'Airtel Money',
          logo: '',
          ussdCode: '*186#',
          color: '#E30613',
        ),
        PartnerModel(
          id: 'mtn_mobile',
          nom: 'MTN Mobile Money',
          logo: '',
          ussdCode: '*126#',
          color: '#FFCC00',
        ),
      ];

  /// Seed partenaires par défaut
  Future<void> seedPartners() async {
    await _db.ref('partners/airtel_money').set({
      'nom': 'Airtel Money',
      'logo': '',
      'ussdCode': '*186#',
      'color': '#E30613',
    });
    await _db.ref('partners/mtn_mobile').set({
      'nom': 'MTN Mobile Money',
      'logo': '',
      'ussdCode': '*126#',
      'color': '#FFCC00',
    });
  }

  /// Seed événement de démo
  Future<void> seedDemoEvent() async {
    final demoId = 'event_demo_001';
    final exists = await _db.ref('events/$demoId').get();
    if (exists.exists) return;

    await _db.ref('events/$demoId').set({
      'partnerId': 'airtel_money',
      'title': 'Concert Fally Ipupa',
      'ville': 'Pointe-Noire',
      'photos': [
        'https://images.unsplash.com/photo-1540575467063-178a50c2df87?w=800',
        'https://images.unsplash.com/photo-1470229722913-7c0e2dbbafd3?w=800',
      ],
      'tickets': [
        {'type': 'Standard', 'prix': 5000, 'stock': 100},
        {'type': 'Gold', 'prix': 15000, 'stock': 50},
        {'type': 'Présidentiel', 'prix': 50000, 'stock': 10},
      ],
      'date': '2026-05-15T20:00:00',
      'description':
          'Une soirée inoubliable avec le roi du Ndombolo ! Fally Ipupa en concert à Pointe-Noire. Vivez une expérience musicale unique avec les meilleures places.',
      'shareLink': 'https://bakatiket.cg/event/$demoId',
      'marketing': {
        'promoCode': 'FALLY20',
        'promoPercent': 20,
        'banner': '',
        'featured': true,
      },
      'createdAt': DateTime.now().millisecondsSinceEpoch,
    });
  }

  // ─── PAIEMENT ──────────────────────────────────────────────────────────────

  /// Calculer le split de paiement
  Map<String, int> calculateSplit(int prix) {
    final commission = (prix * kCommissionRate).round();
    final partnerAmount = prix - commission;
    return {
      'total': prix,
      'bakatiket': commission,
      'partenaire': partnerAmount,
    };
  }

  // ─── CLOUDINARY UPLOAD ─────────────────────────────────────────────────────

  Future<String?> uploadImageToCloudinary(
      List<int> imageBytes, String filename) async {
    try {
      final request =
          http.MultipartRequest('POST', Uri.parse(kCloudinaryUploadUrl));
      request.fields['upload_preset'] = kCloudinaryUploadPreset;
      request.files.add(http.MultipartFile.fromBytes(
        'file',
        imageBytes,
        filename: filename,
      ));
      final response = await request.send();
      if (response.statusCode == 200) {
        final body = await response.stream.bytesToString();
        final json = jsonDecode(body);
        return json['secure_url'] as String?;
      }
    } catch (e) {
      // ignore upload errors for demo
    }
    return null;
  }
}
