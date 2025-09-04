import 'dart:async';
import 'package:eco_trade/core/models/lote.dart' show Localizacao;
import 'package:eco_trade/core/models/user.dart';

class AuthService {
  // Controlador interno para gerir as mudanças de estado.
  final StreamController<AppUser?> _userController =
      StreamController<AppUser?>.broadcast();

  // Variável para guardar sempre o estado mais recente do utilizador.
  AppUser? _currentUser;

  // =======================================================================
  // == ESTA É A CORREÇÃO CRÍTICA ==
  // =======================================================================
  /// Um stream que emite o estado de autenticação atual imediatamente
  /// após ser ouvido, e depois emite quaisquer mudanças futuras.
  Stream<AppUser?> get authStateChanges async* {
    // 1. Emite o estado atual (que é `null` no arranque) assim que
    //    alguém (o AuthWrapper) começa a ouvir.
    yield _currentUser;

    // 2. Em seguida, retransmite quaisquer futuras mudanças que aconteçam
    //    no nosso controlador interno.
    yield* _userController.stream;
  }
  // =======================================================================

  AuthService() {
    // O construtor já não precisa de adicionar `null`, pois o getter acima
    // já trata disso.
  }

  // --- MÉTODOS DE AUTENTICAÇÃO (sem alterações lógicas) ---

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
    await Future.delayed(const Duration(seconds: 1));
    _currentUser = Comercio(
      id: 'comercio_${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      name: name,
      phoneNumber: phoneNumber,
      taxId: taxId,
      legalName: legalName,
      address: address,
      location: location,
    );
    _userController.add(_currentUser);
  }

  Future<void> signUpProdutor({
    required String email,
    required String password,
    required String name,
    required String phoneNumber,
    required int collectionCapacity,
    required List<String> wasteTypes,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    _currentUser = Produtor(
      id: 'produtor_${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      name: name,
      phoneNumber: phoneNumber,
      collectionCapacityKg: collectionCapacity,
      acceptedWasteTypes: wasteTypes,
    );
    _userController.add(_currentUser);
  }

  Future<void> signIn(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    // Simula um login bem-sucedido com um utilizador 'Comercio' para teste
    _currentUser = Comercio(
      id: 'user_signed_in',
      email: email,
      name: 'Comércio Logado',
      phoneNumber: '95999999999',
      taxId: '00.000.000/0001-00',
      legalName: 'Empresa Exemplo LTDA',
      address: Address(
          street: 'Rua Principal',
          number: '123',
          neighborhood: 'Centro',
          city: 'Boa Vista',
          state: 'RR',
          zipCode: '69301-000'),
      location: Localizacao(latitude: 2.8235, longitude: -60.6758),
    );
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
