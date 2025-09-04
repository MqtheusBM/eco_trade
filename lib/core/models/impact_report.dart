/// Representa os dados que o utilizador envia para gerar o relatório.
class ImpactReportRequest {
  final DateTime startDate;
  final DateTime endDate;

  ImpactReportRequest({
    required this.startDate,
    required this.endDate,
  });

  /// Converte o objeto Dart para um mapa JSON para ser enviado à API.
  Map<String, dynamic> toJson() {
    return {
      // Formata a data para "YYYY-MM-DD", como no exemplo.
      'start_date': startDate.toIso8601String().split('T').first,
      'end_date': endDate.toIso8601String().split('T').first,
    };
  }
}

/// Representa a resposta recebida da API com o relatório.
class ImpactReportResponse {
  final String report;

  ImpactReportResponse({required this.report});

  factory ImpactReportResponse.fromJson(Map<String, dynamic> json) {
    return ImpactReportResponse(
      report: json['report'] ?? 'Não foi possível gerar o relatório.',
    );
  }
}
