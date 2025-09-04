// Reutilizamos a classe Localizacao que já tínhamos definido em lote.dart
// para evitar duplicação de código. Se não a tiver aqui, pode copiá-la.
import 'package:eco_trade/core/models/lote.dart' show Localizacao;

// NOVO: Classe para representar o endereço.
class Address {
  final String street;
  final String number;
  final String neighborhood;
  final String city;
  final String state;
  final String zipCode;

  Address({
    required this.street,
    required this.number,
    required this.neighborhood,
    required this.city,
    required this.state,
    required this.zipCode,
  });

  // Construtor para criar um Address a partir de um JSON.
  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      street: json['street'],
      number: json['number'],
      neighborhood: json['neighborhood'],
      city: json['city'],
      state: json['state'],
      zipCode: json['zip_code'],
    );
  }
}

// Classe base para todos os utilizadores.
abstract class AppUser {
  final String id;
  final String email;
  final String name;
  final String phoneNumber;
  final ProfileType profileType;

  AppUser({
    required this.id,
    required this.email,
    required this.name,
    required this.phoneNumber,
    required this.profileType,
  });
}

// Enum para definir os tipos de perfil.
enum ProfileType { comercio, produtor }

// ALTERADO: Classe Comercio agora com todos os novos campos.
class Comercio extends AppUser {
  final String taxId; // CNPJ
  final String legalName; // Razão Social
  final Address address;
  final Localizacao location;

  Comercio({
    required super.id,
    required super.email,
    required super.name, // Nome Fantasia
    required super.phoneNumber,
    required this.taxId,
    required this.legalName,
    required this.address,
    required this.location,
  }) : super(profileType: ProfileType.comercio);

  // Construtor para criar um Comercio a partir de um JSON.
  factory Comercio.fromJson(Map<String, dynamic> json) {
    return Comercio(
      id: json['uid'], // MODIFICADO: De 'id' para 'uid' para corresponder à API
      email: json['email'],
      name: json['name'],
      phoneNumber: json['phone_number'],
      taxId: json['tax_id'],
      legalName: json['legal_name'],
      address: Address.fromJson(json['address']),
      location: Localizacao.fromJson(json['location']),
    );
  }
}

// Classe Produtor (sem alterações).
class Produtor extends AppUser {
  final int collectionCapacityKg;
  final List<String> acceptedWasteTypes;

  Produtor({
    required super.id,
    required super.email,
    required super.name,
    required super.phoneNumber,
    required this.collectionCapacityKg,
    required this.acceptedWasteTypes,
  }) : super(profileType: ProfileType.produtor);

  factory Produtor.fromJson(Map<String, dynamic> json) {
    return Produtor(
      id: json['uid'], // MODIFICADO: De 'id' para 'uid' para consistência
      email: json['email'],
      name: json['name'],
      phoneNumber: json['phone_number'],
      collectionCapacityKg: json['collection_capacity_kg'],
      acceptedWasteTypes: List<String>.from(json['accepted_waste_types']),
    );
  }
}