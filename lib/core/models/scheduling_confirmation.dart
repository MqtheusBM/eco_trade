/// Classe principal que engloba toda a resposta da API de confirmação.
class SchedulingConfirmation {
  final Scheduling scheduling;
  final Batch batch;
  final ProducerConfirmed producerConfirmed;
  final CollectionData collectionData;

  SchedulingConfirmation({
    required this.scheduling,
    required this.batch,
    required this.producerConfirmed,
    required this.collectionData,
  });

  factory SchedulingConfirmation.fromJson(Map<String, dynamic> json) {
    return SchedulingConfirmation(
      scheduling: Scheduling.fromJson(json['scheduling']),
      batch: Batch.fromJson(json['batch']),
      producerConfirmed: ProducerConfirmed.fromJson(json['producer_confirmed']),
      collectionData: CollectionData.fromJson(json['collection_data']),
    );
  }
}

/// Detalhes do agendamento.
class Scheduling {
  final String id;
  final String status;
  final DateTime scheduledDate;
  final String producerId;
  final String merchantId;

  Scheduling({
    required this.id,
    required this.status,
    required this.scheduledDate,
    required this.producerId,
    required this.merchantId,
  });

  factory Scheduling.fromJson(Map<String, dynamic> json) {
    return Scheduling(
      id: json['id'],
      status: json['status'],
      scheduledDate: DateTime.parse(json['scheduled_date']),
      producerId: json['producer_id'],
      merchantId: json['merchant_id'],
    );
  }
}

/// Detalhes do lote (batch).
class Batch {
  final String id;
  final String status;
  final String descriptionIa;
  final int weight;

  Batch({
    required this.id,
    required this.status,
    required this.descriptionIa,
    required this.weight,
  });

  factory Batch.fromJson(Map<String, dynamic> json) {
    return Batch(
      id: json['id'],
      status: json['status'],
      descriptionIa: json['description_ia'],
      weight: json['weight'],
    );
  }
}

/// Detalhes do produtor confirmado.
class ProducerConfirmed {
  final String id;
  final String name;
  final String phoneNumber;
  final double reputation;

  ProducerConfirmed({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.reputation,
  });

  factory ProducerConfirmed.fromJson(Map<String, dynamic> json) {
    return ProducerConfirmed(
      id: json['id'],
      name: json['name'],
      // O JSON pode enviar o número como int, então convertemos para String.
      phoneNumber: json['phone_number'].toString(),
      reputation: (json['reputation'] as num).toDouble(),
    );
  }
}

/// Dados para a recolha.
class CollectionData {
  final String id;
  final String fullAddress;
  final String companyName;
  final String telephonePhoneNumber;

  CollectionData({
    required this.id,
    required this.fullAddress,
    required this.companyName,
    required this.telephonePhoneNumber,
  });

  factory CollectionData.fromJson(Map<String, dynamic> json) {
    return CollectionData(
      id: json['id'],
      fullAddress: json['full_address'],
      companyName: json['company_name'],
      telephonePhoneNumber: json['telephone_phone_number'].toString(),
    );
  }
}
