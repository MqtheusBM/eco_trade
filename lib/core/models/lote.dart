/// Representa a localização de um lote.
class Localizacao {
  final double latitude;
  final double longitude;

  Localizacao({required this.latitude, required this.longitude});

  factory Localizacao.fromJson(Map<String, dynamic> json) {
    return Localizacao(
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
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
      // Proteção de ID e campos com nomes que vêm do Django
      id: json['id']?.toString() ?? '',
      descriptionAI: json['description'] ?? '', // O Django manda 'description'
      weight: json['weight'] ?? 0.0,
      limitDate: json['limit_date'] != null
          ? DateTime.parse(json['limit_date'])
          : DateTime.now(),
      status: traduzirStatus(json['status']),
      imageUrl: json['image_url'] ?? '', // Django manda 'image_url'
      // A API manda lat e long soltos, não dentro de 'location'
      location: Localizacao(
        latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
        longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      ),
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
  final num weight;

  LoteResumido({
    required this.id,
    required this.description,
    required this.location,
    required this.distance,
    required this.status,
    required this.imageUrl,
    required this.limitDate,
    required this.weight,
  });

  factory LoteResumido.fromJson(Map<String, dynamic> json) {
    // === O NOSSO DETETIVE ===
    print('📦 LOTE RECEBIDO: ${json['description']}');
    print('🔗 URL QUE VEIO DO DJANGO: ${json['image_url']}');
    // ========================

    return LoteResumido(
      id: json['id']?.toString() ?? '',
      description: json['description'] ?? '',
      location: Localizacao(
        latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
        longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      ),
      distance: json['distance']?.toString() ?? '...',
      status: traduzirStatus(json['status']),
      
      // Vamos manter a nossa lógica do IP por enquanto
      imageUrl: json['image_url'] ?? '',
          
      limitDate: json['limit_date'] != null ? DateTime.parse(json['limit_date']) : DateTime.now(),
      weight: json['weight'] ?? 0.0,
    );
  }
}

/// Função inteligente para traduzir o status do sistema (inglês) para o utilizador (português)
String traduzirStatus(String? statusBackend) {
  if (statusBackend == null) return 'ativo';

  switch (statusBackend.toLowerCase()) {
    case 'scheduled':
      return 'agendado';
    case 'active':
      return 'ativo';
    case 'pending':
      return 'pendente';
    case 'confirmed':
      return 'confirmado';
    case 'completed':
    case 'finished':
      return 'finalizado';
    default:
      return statusBackend; // Se vier algo diferente, mostra o original
  }
}
