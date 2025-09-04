/// Classe principal que representa um agendamento na lista do produtor.
class ProducerScheduling {
  final String schedulingId;
  final String status;
  final DateTime scheduledDate;
  final BatchInfo batchInfo;
  final MerchantInfo merchantInfo;

  ProducerScheduling({
    required this.schedulingId,
    required this.status,
    required this.scheduledDate,
    required this.batchInfo,
    required this.merchantInfo,
  });

  factory ProducerScheduling.fromJson(Map<String, dynamic> json) {
    return ProducerScheduling(
      schedulingId: json['scheduling_id'],
      status: json['status'],
      scheduledDate: DateTime.parse(json['scheduled_date']),
      batchInfo: BatchInfo.fromJson(json['batch_info']),
      merchantInfo: MerchantInfo.fromJson(json['merchant_info']),
    );
  }
}

/// Informações resumidas sobre o lote associado ao agendamento.
class BatchInfo {
  final String id;
  final String imageUrl;
  final String description;
  // Este campo é crucial para a navegação para a tela de detalhes.
  final DateTime limitDate;

  BatchInfo({
    required this.id,
    required this.imageUrl,
    required this.description,
    required this.limitDate,
  });

  factory BatchInfo.fromJson(Map<String, dynamic> json) {
    return BatchInfo(
      id: json['id'],
      imageUrl: json['image_url'],
      description: json['description'],
      limitDate: DateTime.parse(json['limit_date']),
    );
  }
}

/// Informações resumidas sobre o comércio associado ao agendamento.
class MerchantInfo {
  final String uid;
  final String name;

  MerchantInfo({required this.uid, required this.name});

  factory MerchantInfo.fromJson(Map<String, dynamic> json) {
    return MerchantInfo(
      uid: json['uid'],
      name: json['name'],
    );
  }
}

