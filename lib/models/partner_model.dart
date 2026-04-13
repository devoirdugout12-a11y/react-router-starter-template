class PartnerModel {
  final String id;
  final String nom;
  final String logo;
  final String ussdCode;
  final String color;

  PartnerModel({
    required this.id,
    required this.nom,
    required this.logo,
    this.ussdCode = '',
    this.color = '#4CAF50',
  });

  factory PartnerModel.fromMap(String id, Map<dynamic, dynamic> map) {
    return PartnerModel(
      id: id,
      nom: map['nom'] ?? '',
      logo: map['logo'] ?? '',
      ussdCode: map['ussdCode'] ?? '',
      color: map['color'] ?? '#4CAF50',
    );
  }

  Map<String, dynamic> toMap() => {
    'nom': nom,
    'logo': logo,
    'ussdCode': ussdCode,
    'color': color,
  };
}
