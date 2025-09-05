import 'dart:async';
import 'package:eco_trade/core/api/api_service.dart';
import 'package:eco_trade/core/models/lote.dart' show Localizacao;
import 'package:eco_trade/core/models/user.dart';

class AuthService {
  // Adicionamos uma dependência para o nosso serviço de API
  final ApiService _apiService;

  // Controlador interno para gerir as mudanças de estado.
  final StreamController<AppUser?> _userController =
      StreamController<AppUser?>.broadcast();

  // Variável para guardar sempre o estado mais recente do utilizador.
  AppUser? _currentUser;

  // Stream que notifica os widgets sobre mudanças no estado de autenticação
  Stream<AppUser?> get authStateChanges async* {
    yield _currentUser;
    yield* _userController.stream;
  }

  // O construtor agora recebe a instância do serviço de API
  AuthService(this._apiService);

  // --- MÉTODOS DE AUTENTICAÇÃO ---

  // ATUALIZADO: Agora usa a resposta padronizada da API.
  Future<void> signUpComercio({
    required String email,
    required String password,
    required String name,
    required String phoneNumber,
    required String taxId,
    required String legalName,
    required Address address,
    required Localizacao location,
  }) async {
    final newComercio = Comercio(
      id: '', // A ser gerado pelo backend
      email: email,
      name: name,
      phoneNumber: phoneNumber,
      taxId: taxId,
      legalName: legalName,
      address: address,
      location: location,
    );

    // Adiciona a senha ao mapa de dados a ser enviado
    final dataToSend = newComercio.toJson()..['password'] = password;

    // A API agora retorna um Map, tal como o signIn
    final response = await _apiService.signUpComercio(dataToSend);
    final userJson = response['user'] as Map<String, dynamic>;

    _currentUser = Comercio.fromJson(userJson);
    _userController.add(_currentUser);
  }

  // ATUALIZADO: Agora usa a resposta padronizada da API.
  Future<void> signUpProdutor({
    required String email,
    required String password,
    required String name,
    required String phoneNumber,
    required int collectionCapacity,
    required List<String> wasteTypes,
  }) async {
    final newProdutor = Produtor(
      id: '', // A ser gerado pelo backend
      email: email,
      name: name,
      phoneNumber: phoneNumber,
      collectionCapacityKg: collectionCapacity,
      acceptedWasteTypes: wasteTypes,
    );
    final dataToSend = newProdutor.toJson()..['password'] = password;

    final response = await _apiService.signUpProdutor(dataToSend);
    final userJson = response['user'] as Map<String, dynamic>;

    _currentUser = Produtor.fromJson(userJson);
    _userController.add(_currentUser);
  }

  /// MÉTODO ATUALIZADO
  Future<void> signIn(String email, String password) async {
    // 1. Chama o método signIn do nosso serviço de API
    final response = await _apiService.signIn(email, password);

    // 2. Extrai os dados do utilizador da resposta
    final userJson = response['user'] as Map<String, dynamic>;
    final role = userJson['role'] as String;

    // 3. TODO: Armazenar o token de forma segura (ex: flutter_secure_storage)
    // final token = response['token'] as String;
    // print('Token recebido: $token');

    // 4. Cria a instância do utilizador correto com base na sua "role"
    if (role == 'merchant') {
      _currentUser = Comercio.fromJson(userJson);
    } else if (role == 'producer') {
      _currentUser = Produtor.fromJson(userJson);
    } else {
      throw Exception('Role de utilizador desconhecida vinda da API: $role');
    }

    // 5. Notifica o resto da aplicação que o utilizador mudou
    _userController.add(_currentUser);
  }

  Future<void> signOut() async {
    _currentUser = null;
    _userController.add(null);
  }

  void dispose() {
    _userController.close();
  }
}

