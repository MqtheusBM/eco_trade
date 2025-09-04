import 'package:eco_trade/core/models/lote.dart';
import 'package:eco_trade/core/models/user.dart';

/// Classe principal que engloba toda a resposta da API de detalhes.
class SchedulingDetails {
  final Scheduling scheduling;
  final Batch batch;
  final Merchant merchant;

  SchedulingDetails({
    required this.scheduling,
    required this.batch,
    required this.merchant,
  });

  factory SchedulingDetails.fromJson(Map<String, dynamic> json) {
    return SchedulingDetails(
      scheduling: Scheduling.fromJson(json['scheduling']),
      batch: Batch.fromJson(json['batch']),
      merchant: Merchant.fromJson(json['merchant']),
    );
  }
}

/// Detalhes do agendamento.
class Scheduling {
  final String id;
  final String status;
  final DateTime scheduledDate;
  // ... outros campos se necessário ...

  Scheduling({required this.id, required this.status, required this.scheduledDate});

  factory Scheduling.fromJson(Map<String, dynamic> json) {
    return Scheduling(
      id: json['id'],
      status: json['status'],
      scheduledDate: DateTime.parse(json['scheduled_date']),
    );
  }
}

/// Detalhes do lote.
class Batch {
  final String id;
  final String status;
  final String descriptionIa;
  final int weight;

  Batch({required this.id, required this.status, required this.descriptionIa, required this.weight});

  factory Batch.fromJson(Map<String, dynamic> json) {
    return Batch(
      id: json['id'],
      status: json['status'],
      descriptionIa: json['description_ia'],
      weight: json['weight'],
    );
  }
}

/// Detalhes completos do Comércio (Merchant).
class Merchant {
  final String uid;
  final String name;
  final String phoneNumber;
  final String taxId;
  final String legalName;
  final Address address;
  final Localizacao location;

  Merchant({
    required this.uid,
    required this.name,
    required this.phoneNumber,
    required this.taxId,
    required this.legalName,
    required this.address,
    required this.location,
  });

  factory Merchant.fromJson(Map<String, dynamic> json) {
    return Merchant(
      uid: json['uid'],
      name: json['name'],
      phoneNumber: json['phone_number'],
      taxId: json['tax_id'],
      legalName: json['legal_name'],
      address: Address.fromJson(json['address']),
      location: Localizacao.fromJson(json['location']),
    );
  }
}
