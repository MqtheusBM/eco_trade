/// Representa os dados que o Produtor envia para criar um novo agendamento.
class SchedulingRequest {
  final String loteId;
  final DateTime scheduledDate;

  SchedulingRequest({
    required this.loteId,
    required this.scheduledDate,
  });

  /// Converte o objeto Dart para um mapa JSON para ser enviado à API.
  Map<String, dynamic> toJson() {
    return {
      'lote_id': loteId,
      // Converte a data para o formato ISO 8601 que a API espera.
      'scheduled_date': scheduledDate.toIso8601String(),
    };
  }
}

/// Representa a resposta da API após a criação bem-sucedida de um agendamento.
class SchedulingCreationResponse {
  final String id;
  final String status;
  final DateTime scheduledDate;
  final String producerId;
  final String merchantId;

  SchedulingCreationResponse({
    required this.id,
    required this.status,
    required this.scheduledDate,
    required this.producerId,
    required this.merchantId,
  });

  factory SchedulingCreationResponse.fromJson(Map<String, dynamic> json) {
    return SchedulingCreationResponse(
      id: json['id'],
      status: json['status'],
      scheduledDate: DateTime.parse(json['scheduled_date']),
      producerId: json['producer_id'],
      merchantId: json['merchant_id'],
    );
  }
}
