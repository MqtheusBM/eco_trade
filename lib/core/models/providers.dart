import 'package:eco_trade/core/api/api_service.dart';
import 'package:eco_trade/core/api/mock_api_service.dart';
import 'package:eco_trade/core/models/auth/auth_service.dart';
import 'package:eco_trade/core/models/interested_producer.dart';
import 'package:eco_trade/core/models/lote.dart';
import 'package:eco_trade/core/models/producer_scheduling.dart';
import 'package:eco_trade/core/models/scheduling_details.dart';
import 'package:eco_trade/core/models/user.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

// ===================================================================
// == Provedor de Localização ==
// ===================================================================

/// Trata de todo o fluxo de obter a localização GPS do utilizador,
/// incluindo a verificação de permissões.
final locationProvider = FutureProvider<Position>((ref) async {
  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    throw 'O serviço de localização está desativado.';
  }

  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      throw 'A permissão de localização foi negada.';
    }
  }

  if (permission == LocationPermission.deniedForever) {
    throw 'A permissão de localização foi negada permanentemente. É necessário ativá-la nas configurações.';
  }

  return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high);
});

// ===================================================================
// == Provedores de Autenticação ==
// ===================================================================

/// MODIFICADO: Agora injeta a dependência do ApiService no AuthService.
final authServiceProvider = Provider<AuthService>((ref) {
  // Obtém a instância do ApiService (seja o mock ou o real)
  final apiService = ref.watch(apiServiceProvider);
  // Cria o AuthService, passando o apiService para ele
  final authService = AuthService(apiService);
  ref.onDispose(() => authService.dispose());
  return authService;
});

/// Fornece um stream com o estado atual de autenticação do utilizador.
/// Widgets podem "ouvir" este provedor para reagir a logins e logouts.
final authStateProvider = StreamProvider<AppUser?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
});

/// Controla o estado de carregamento (ex: true/false) durante operações
/// de autenticação como login ou registo.
final authLoadingProvider = StateProvider<bool>((ref) => false);

// ===================================================================
// == Provedores da API ==
// ===================================================================

/// Fornece a instância do nosso serviço de API.
/// AQUI É ONDE TROCAMOS ENTRE A API FALSA (MOCK) E A REAL.
final apiServiceProvider = Provider<ApiService>((ref) {
  // Para desenvolvimento, usamos o serviço MOCK.
  return MockApiService();

  // Quando o backend estiver pronto, basta comentar a linha acima
  // e descomentar a linha abaixo para usar a API real.
  // return ApiService();
});

/// Busca a lista de lotes criados pelo Comércio atualmente autenticado.
final meusLotesProvider = FutureProvider.autoDispose<List<LoteResumido>>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return apiService.getMeusLotes();
});

/// Busca a lista de Produtores que manifestaram interesse num lote específico.
/// O `.family` permite-nos passar o `loteId` como parâmetro.
final interestedProducersProvider = FutureProvider.autoDispose
    .family<List<InterestedProducer>, String>((ref, loteId) {
  final apiService = ref.watch(apiServiceProvider);
  return apiService.getInterestedProducers(loteId);
});

/// Busca uma lista de lotes próximos com base na localização do utilizador (Produtor).
/// O `.family` permite-nos passar as coordenadas como parâmetro.
final lotesProvider = FutureProvider.autoDispose
    .family<List<LoteResumido>, ({double lat, double long})>((ref, coords) {
  final apiService = ref.watch(apiServiceProvider);
  return apiService.getLotes(lat: coords.lat, long: coords.long);
});

/// Busca os agendamentos do Produtor, com um filtro opcional por status.
final producerSchedulingsProvider = FutureProvider.autoDispose
    .family<List<ProducerScheduling>, String?>((ref, status) {
  final apiService = ref.watch(apiServiceProvider);
  return apiService.getProducerSchedulings(status: status);
});

/// Busca os detalhes de um agendamento específico.
final schedulingDetailsProvider = FutureProvider.autoDispose
    .family<SchedulingDetails, String>((ref, schedulingId) {
  final apiService = ref.watch(apiServiceProvider);
  return apiService.getSchedulingDetails(schedulingId);
});
