class TicketType {
  final String type;
  final int prix;
  final int stock;

  TicketType({required this.type, required this.prix, required this.stock});

  factory TicketType.fromMap(Map<dynamic, dynamic> map) {
    return TicketType(
      type: map['type'] ?? '',
      prix: (map['prix'] ?? 0) is int ? map['prix'] : int.tryParse(map['prix'].toString()) ?? 0,
      stock: (map['stock'] ?? 0) is int ? map['stock'] : int.tryParse(map['stock'].toString()) ?? 0,
    );
  }

  Map<String, dynamic> toMap() => {
    'type': type,
    'prix': prix,
    'stock': stock,
  };
}

class MarketingInfo {
  final String promoCode;
  final int promoPercent;
  final String banner;
  final bool featured;

  MarketingInfo({
    this.promoCode = '',
    this.promoPercent = 0,
    this.banner = '',
    this.featured = false,
  });

  factory MarketingInfo.fromMap(Map<dynamic, dynamic>? map) {
    if (map == null) return MarketingInfo();
    return MarketingInfo(
      promoCode: map['promoCode'] ?? '',
      promoPercent: (map['promoPercent'] ?? 0) is int
          ? map['promoPercent']
          : int.tryParse(map['promoPercent'].toString()) ?? 0,
      banner: map['banner'] ?? '',
      featured: map['featured'] == true,
    );
  }

  Map<String, dynamic> toMap() => {
    'promoCode': promoCode,
    'promoPercent': promoPercent,
    'banner': banner,
    'featured': featured,
  };
}

class EventModel {
  final String id;
  final String partnerId;
  final String title;
  final String ville;
  final List<String> photos;
  final List<TicketType> tickets;
  final String date;
  final String description;
  final String shareLink;
  final MarketingInfo marketing;
  final int createdAt;

  EventModel({
    required this.id,
    required this.partnerId,
    required this.title,
    required this.ville,
    required this.photos,
    required this.tickets,
    required this.date,
    required this.description,
    required this.shareLink,
    required this.marketing,
    required this.createdAt,
  });

  int get prixMin => tickets.isEmpty ? 0 : tickets.map((t) => t.prix).reduce((a, b) => a < b ? a : b);
  int get prixMax => tickets.isEmpty ? 0 : tickets.map((t) => t.prix).reduce((a, b) => a > b ? a : b);
  String get photoUrl => photos.isNotEmpty ? photos.first : '';

  factory EventModel.fromMap(String id, Map<dynamic, dynamic> map) {
    List<String> photos = [];
    if (map['photos'] != null) {
      if (map['photos'] is List) {
        photos = List<String>.from(map['photos']);
      } else if (map['photos'] is Map) {
        photos = (map['photos'] as Map).values.map((v) => v.toString()).toList();
      }
    }

    List<TicketType> tickets = [];
    if (map['tickets'] != null) {
      if (map['tickets'] is List) {
        tickets = (map['tickets'] as List)
            .whereType<Map>()
            .map((t) => TicketType.fromMap(t))
            .toList();
      } else if (map['tickets'] is Map) {
        tickets = (map['tickets'] as Map)
            .values
            .map((t) => TicketType.fromMap(t))
            .toList();
      }
    }

    return EventModel(
      id: id,
      partnerId: map['partnerId'] ?? '',
      title: map['title'] ?? '',
      ville: map['ville'] ?? '',
      photos: photos,
      tickets: tickets,
      date: map['date'] ?? '',
      description: map['description'] ?? '',
      shareLink: map['shareLink'] ?? 'https://bakatiket.cg/event/$id',
      marketing: MarketingInfo.fromMap(map['marketing']),
      createdAt: (map['createdAt'] ?? 0) is int
          ? map['createdAt']
          : int.tryParse(map['createdAt'].toString()) ?? 0,
    );
  }

  Map<String, dynamic> toMap() => {
    'partnerId': partnerId,
    'title': title,
    'ville': ville,
    'photos': photos,
    'tickets': tickets.map((t) => t.toMap()).toList(),
    'date': date,
    'description': description,
    'shareLink': shareLink,
    'marketing': marketing.toMap(),
    'createdAt': createdAt,
  };
}
