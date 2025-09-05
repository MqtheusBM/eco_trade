import 'package:dio/dio.dart';
import 'package:eco_trade/core/api/api_service.dart';
import 'package:eco_trade/core/models/compost_analysis.dart';
import 'package:eco_trade/core/models/impact_report.dart';
import 'package:eco_trade/core/models/interested_producer.dart';
import 'package:eco_trade/core/models/lote.dart';
import 'package:eco_trade/core/models/producer_scheduling.dart';
import 'package:eco_trade/core/models/rating.dart';
import 'package:eco_trade/core/models/scheduling_confirmation.dart';
import 'package:eco_trade/core/models/scheduling_creation.dart';
import 'package:eco_trade/core/models/scheduling_details.dart';

/// Esta é a implementação real do seu serviço de API.
/// Ela utiliza o pacote 'dio' para fazer chamadas HTTP ao seu backend.
class RealApiService implements ApiService {
  late final Dio _dio;

  // Substitua este URL pelo endereço do seu servidor.
  final String _baseUrl = 'https://api-i2hos5vtgq-uc.a.run.app/api';

  RealApiService() {
    // Configurações base do Dio.
    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // (Opcional) Adicione interceptors para logs, gestão de token, etc.
    _dio.interceptors
        .add(LogInterceptor(responseBody: true, requestBody: true));
  }

  @override
  Future<Map<String, dynamic>> signIn(String email, String password) async {
    try {
      final response = await _dio.post(
        '/auth/signin',
        data: {
          'email': email,
          'password': password,
        },
      );
      // O dio lança uma exceção para códigos de status não-2xx,
      // então se chegarmos aqui, a resposta foi bem-sucedida.
      return response.data;
    } on DioException catch (e) {
      // Trata erros específicos do Dio (rede, timeouts, respostas 4xx/5xx).
      if (e.response != null) {
        // O servidor respondeu com um erro.
        throw Exception('Erro do servidor: ${e.response?.data['message']}');
      } else {
        // Erro de conexão/rede.
        throw Exception('Falha na ligação. Verifique a sua internet.');
      }
    } catch (e) {
      // Outros erros inesperados.
      throw Exception('Ocorreu um erro inesperado.');
    }
  }

  // --- MÉTODOS A IMPLEMENTAR ---
  // Abaixo estão os outros métodos que precisa de implementar,
  // ligando cada um ao seu respetivo endpoint no backend.

  @override
  Future<CompostAnalysisResponse> analyzeCompost(
      String loteId, CompostAnalysisRequest request) {
    throw UnimplementedError('analyzeCompost ainda não implementado');
  }

  @override
  Future<SchedulingConfirmation> confirmCollection(
      String loteId, String producerId) {
    throw UnimplementedError('confirmCollection ainda não implementado');
  }

  @override
  Future<Lote> createLote(
      {required String imagePath,
      required num weight,
      required DateTime limitDate,
      required double latitude,
      required double longitude}) {
    throw UnimplementedError('createLote ainda não implementado');
  }

  @override
  Future<SchedulingCreationResponse> createScheduling(
      SchedulingRequest request) {
    throw UnimplementedError('createScheduling ainda não implementado');
  }

  @override
  Future<Map<String, dynamic>> finalizeScheduling(String schedulingId) {
    throw UnimplementedError('finalizeScheduling ainda não implementado');
  }

  @override
  Future<ImpactReportResponse> generateImpactReport(
      ImpactReportRequest request) {
    throw UnimplementedError('generateImpactReport ainda não implementado');
  }

  @override
  Future<List<InterestedProducer>> getInterestedProducers(String loteId) {
    throw UnimplementedError('getInterestedProducers ainda não implementado');
  }

  @override
  Future<List<LoteResumido>> getLotes(
      {required double lat, required double long, int raioKm = 20}) {
    throw UnimplementedError('getLotes ainda não implementado');
  }

  @override
  Future<List<LoteResumido>> getMeusLotes() {
    throw UnimplementedError('getMeusLotes ainda não implementado');
  }

  @override
  Future<List<ProducerScheduling>> getProducerSchedulings({String? status}) {
    throw UnimplementedError('getProducerSchedulings ainda não implementado');
  }

  @override
  Future<SchedulingDetails> getSchedulingDetails(String schedulingId) {
    throw UnimplementedError('getSchedulingDetails ainda não implementado');
  }

  @override
  Future<void> registerInterest(String loteId) {
    throw UnimplementedError('registerInterest ainda não implementado');
  }

  @override
  Future<Map<String, dynamic>> rateScheduling(
      String schedulingId, RatingRequest request) {
    throw UnimplementedError('rateScheduling ainda não implementado');
  }

  @override
  Future<Map<String, dynamic>> signUpComercio(Map<String, dynamic> data) async {
    // Implemente a chamada ao endpoint de cadastro de comércio
    try {
      final response = await _dio.post(
        '/auth/signup/comercio',
        data: data,
      );
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception('Erro do servidor: ${e.response?.data['message']}');
      } else {
        throw Exception('Falha na ligação. Verifique a sua internet.');
      }
    } catch (e) {
      throw Exception('Ocorreu um erro inesperado.');
    }
  }

  @override
  Future<Map<String, dynamic>> signUpProdutor(Map<String, dynamic> data) async {
    // Implemente a chamada ao endpoint de cadastro de produtor
    try {
      final response = await _dio.post(
        '/auth/signup/produtor',
        data: data,
      );
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception('Erro do servidor: ${e.response?.data['message']}');
      } else {
        throw Exception('Falha na ligação. Verifique a sua internet.');
      }
    } catch (e) {
      throw Exception('Ocorreu um erro inesperado.');
    }
  }
}
