/// Representa os dados que o utilizador envia para a análise.
class CompostAnalysisRequest {
  final String compostingMethod;
  final List<String> availableCarbonMaterials;
  final String goal;
  final String observations;

  CompostAnalysisRequest({
    required this.compostingMethod,
    required this.availableCarbonMaterials,
    required this.goal,
    required this.observations,
  });

  /// Converte o objeto Dart para um mapa JSON para ser enviado à API.
  Map<String, dynamic> toJson() {
    return {
      'composting_method': compostingMethod,
      'available_carbon_materials': availableCarbonMaterials,
      'goal': goal,
      'observations': observations,
    };
  }
}

/// Representa a resposta recebida da API com as recomendações.
class CompostAnalysisResponse {
  final String recommendations;

  CompostAnalysisResponse({required this.recommendations});

  /// Cria um objeto a partir de um mapa JSON recebido da API.
  factory CompostAnalysisResponse.fromJson(Map<String, dynamic> json) {
    return CompostAnalysisResponse(
      recommendations: json['recommendations'] ?? 'Nenhuma recomendação recebida.',
    );
  }
}
