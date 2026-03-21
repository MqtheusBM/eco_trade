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
class RealApiService implements ApiService {
  late final Dio _dio;

  // Substitua este URL pelo endereço do seu servidor.
  final String _baseUrl = 'https://ecotrade.f3-software.com.br';
  
  RealApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    _dio.interceptors.add(LogInterceptor(responseBody: true, requestBody: true));
  }

  Exception _handleDioError(DioException e) {
    if (e.response != null && e.response?.data != null) {
      if (e.response?.data is Map && e.response?.data['message'] != null) {
        return Exception('Erro do servidor: ${e.response?.data['message']}');
      }
      return Exception('Erro do servidor: ${e.response?.data}');
    } else {
      return Exception('Falha na ligação. Verifique a sua internet.');
    }
  }

  @override
  Future<Map<String, dynamic>> signIn(String email, String password) async {
    try {
      final response = await _dio.post(
        '/api/auth/login/',
        data: {
          'email': email,
          'password': password,
        },
      );

      final String token = response.data['token'];
      _dio.options.headers['Authorization'] = 'Token $token';

      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        // Ajustado para capturar tanto 'message' quanto 'detail' (padrão do Django)
        throw Exception('Erro do servidor: ${e.response?.data['message'] ?? e.response?.data['detail'] ?? 'Falha no login.'}');
      } else {
        throw Exception('Falha na ligação. Verifique a sua internet.');
      }
    } catch (e) {
      throw Exception('Ocorreu um erro inesperado.');
    }
  }

  @override
  Future<Map<String, dynamic>> signUpComercio(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/api/auth/register/comercio/', data: data);
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Ocorreu um erro inesperado.');
    }
  }

  @override
  Future<Map<String, dynamic>> signUpProdutor(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/api/auth/register/produtor/', data: data);
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Ocorreu um erro inesperado.');
    }
  }

  // --- MÉTODOS A IMPLEMENTAR ---

  @override
  Future<CompostAnalysisResponse> analyzeCompost(String loteId, CompostAnalysisRequest request) {
    throw UnimplementedError('analyzeCompost ainda não implementado');
  }

  @override
  Future<SchedulingConfirmation> confirmCollection(String loteId, String producerId) {
    throw UnimplementedError('confirmCollection ainda não implementado');
  }

  @override
  Future<Lote> createLote({
    required String imagePath,
    required num weight,
    required DateTime limitDate,
    required double latitude,
    required double longitude,
  }) async {
    try {
      FormData formData = FormData.fromMap({
        'weight': weight,
        'limit_date': limitDate.toIso8601String(),
        'latitude': latitude,
        'longitude': longitude,
        'image_url': await MultipartFile.fromFile(imagePath, filename: 'residuos_${DateTime.now().millisecondsSinceEpoch}.jpg'),
      });

      final response = await _dio.post('/api/lotes/', data: formData);
      return Lote.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception('Erro do servidor: ${e.response?.data}');
      } else {
        throw Exception('Falha na ligação ao enviar o lote.');
      }
    } catch (e) {
      throw Exception('Ocorreu um erro inesperado ao criar o lote.');
    }
  }

  @override
  Future<void> deleteLote(String loteId) async {
    try {
      await _dio.delete('/api/lotes/$loteId/');
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception('Erro ${e.response?.statusCode}: Rota de exclusão não encontrada no servidor.');
      } else {
        throw Exception('Falha na ligação ao tentar excluir.');
      }
    } catch (e) {
      throw Exception('Erro inesperado ao excluir o lote.');
    }
  }

  @override
  Future<SchedulingCreationResponse> createScheduling(SchedulingRequest request) {
    throw UnimplementedError('createScheduling ainda não implementado');
  }

  @override
  Future<Map<String, dynamic>> finalizeScheduling(String schedulingId) {
    throw UnimplementedError('finalizeScheduling ainda não implementado');
  }

  @override
  Future<ImpactReportResponse> generateImpactReport(ImpactReportRequest request) {
    throw UnimplementedError('generateImpactReport ainda não implementado');
  }

  @override
  Future<List<InterestedProducer>> getInterestedProducers(String loteId) {
    throw UnimplementedError('getInterestedProducers ainda não implementado');
  }

  @override
  Future<List<LoteResumido>> getLotes({required double lat, required double long, int raioKm = 20}) async {
    try {
      final response = await _dio.get('/api/lotes/');
      final List<dynamic> data = response.data;
      return data.map((json) => LoteResumido.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Erro ao buscar os lotes no mapa: $e');
    }
  }

  @override
  Future<List<LoteResumido>> getMeusLotes() async {
    try {
      final response = await _dio.get('/api/meus-lotes/');
      final List<dynamic> data = response.data;
      return data.map((json) => LoteResumido.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception('Erro ao carregar lotes: ${e.message}');
    } catch (e) {
      throw Exception('Erro inesperado ao carregar os lotes.');
    }
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
  Future<Map<String, dynamic>> rateScheduling(String schedulingId, RatingRequest request) {
    throw UnimplementedError('rateScheduling ainda não implementado');
  }

  @override
  Future<void> agendarColeta(String loteId, DateTime proposedDate) async {
    try {
      await _dio.post(
        '/api/lotes/$loteId/agendar/',
        data: {'proposed_date': proposedDate.toIso8601String()},
      );
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data['error'] ?? 'Erro ao agendar coleta.');
      } else {
        throw Exception('Falha na ligação ao tentar agendar.');
      }
    } catch (e) {
      throw Exception('Erro inesperado: $e');
    }
  }

  @override
  Future<List<dynamic>> getMinhasColetas() async {
    try {
      final response = await _dio.get('/api/minhas-coletas/');
      return response.data; 
    } catch (e) {
      throw Exception('Erro ao buscar meus agendamentos: $e');
    }
  }

  @override
  Future<void> cancelarColeta(String agendamentoId) async {
    try {
      await _dio.post('/api/minhas-coletas/$agendamentoId/cancelar/');
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data['error'] ?? 'Erro ao cancelar a coleta.');
      } else {
        throw Exception('Falha de conexão ao tentar cancelar.');
      }
    } catch (e) {
      throw Exception('Erro inesperado: $e');
    }
  }

  // === A NOSSA FUNÇÃO DA PADARIA ESTÁ AQUI A SALVO! ===
  @override
  Future<void> responderAgendamento(String agendamentoId, String acao) async {
    try {
      await _dio.post(
        '/api/agendamentos/$agendamentoId/responder/',
        data: {'acao': acao},
      );
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data['error'] ?? 'Erro ao responder ao agendamento.');
      } else {
        throw Exception('Falha de conexão.');
      }
    } catch (e) {
      throw Exception('Erro inesperado: $e');
    }
  }
}