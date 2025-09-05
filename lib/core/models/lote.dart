/// Representa a localização de um lote.
class Localizacao {
  final double latitude;
  final double longitude;

  Localizacao({required this.latitude, required this.longitude});

  factory Localizacao.fromJson(Map<String, dynamic> json) {
    return Localizacao(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );
  }

  // ATUALIZADO: Este método é essencial para o user.dart funcionar.
  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}

/// Representa um lote completo, geralmente recebido após a criação.
class Lote {
  final String id;
  final String descriptionAI;
  final num weight;
  final DateTime limitDate;
  final String status;
  final String imageUrl;
  final Localizacao location;

  Lote({
    required this.id,
    required this.descriptionAI,
    required this.weight,
    required this.limitDate,
    required this.status,
    required this.imageUrl,
    required this.location,
  });

  factory Lote.fromJson(Map<String, dynamic> json) {
    return Lote(
      id: json['id'],
      descriptionAI: json['descriptionAI'],
      weight: json['weight'],
      limitDate: DateTime.parse(json['limitDate']),
      status: json['status'],
      imageUrl: json['imageUrl'],
      location: Localizacao.fromJson(json['location']),
    );
  }
}

/// Representa um lote numa lista (versão resumida).
class LoteResumido {
  final String id;
  final String description;
  final Localizacao location;
  final String distance;
  final String status;
  final String imageUrl;
  final DateTime limitDate;

  LoteResumido({
    required this.id,
    required this.description,
    required this.location,
    required this.distance,
    required this.status,
    required this.imageUrl,
    required this.limitDate,
  });

  factory LoteResumido.fromJson(Map<String, dynamic> json) {
    return LoteResumido(
      id: json['id'],
      description: json['description'],
      location: Localizacao.fromJson(json['location']),
      distance: json['distance'],
      status: json['status'],
      imageUrl: json['imageUrl'],
      limitDate: DateTime.parse(json['limitDate']),
    );
  }
}

