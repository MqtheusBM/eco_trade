/// Representa os dados que o utilizador envia para avaliar um agendamento.
class RatingRequest {
  final double rating;
  final String comments;

  RatingRequest({
    required this.rating,
    required this.comments,
  });

  /// Converte o objeto Dart para um mapa JSON para ser enviado à API.
  Map<String, dynamic> toJson() {
    return {
      'rating': rating,
      'comments': comments,
    };
  }
}
