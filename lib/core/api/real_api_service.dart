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
  final String _baseUrl = 'http://192.168.3.10:8000/api';
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

  // Função auxiliar para tratar os erros da API de forma robusta
  Exception _handleDioError(DioException e) {
    if (e.response != null && e.response?.data != null) {
      // Se a resposta do erro for um mapa (JSON) e tiver uma chave 'message'
      if (e.response?.data is Map && e.response?.data['message'] != null) {
        return Exception('Erro do servidor: ${e.response?.data['message']}');
      }
      // Se a resposta for qualquer outra coisa (ex: texto simples)
      return Exception('Erro do servidor: ${e.response?.data}');
    } else {
      // Erro de conexão/rede.
      return Exception('Falha na ligação. Verifique a sua internet.');
    }
  }

  @override
  Future<Map<String, dynamic>> signIn(String email, String password) async {
    try {
      final response = await _dio.post(
        '/auth/login/',
        data: {
          'email': email,
          'password': password,
        },
      );

      // 1. Pegamos o token que veio na resposta
      final String token = response.data['token'];
      
      // 2. Ensinamos o Dio a usar este token em TODAS as próximas requisições!
      _dio.options.headers['Authorization'] = 'Token $token';

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
  Future<Map<String, dynamic>> signUpComercio(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(
        '/auth/register/comercio/',
        data: data,
      );
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
      final response = await _dio.post(
        '/auth/register/produtor/',
        data: data,
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Ocorreu um erro inesperado.');
    }
  }

  // --- MÉTODOS A IMPLEMENTAR ---

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
  Future<Lote> createLote({
    required String imagePath,
    required num weight,
    required DateTime limitDate,
    required double latitude,
    required double longitude,
  }) async {
    try {
      // 1. Criamos um "Pacote de Correios" especial que aceita Ficheiros (FormData)
      FormData formData = FormData.fromMap({
        'weight': weight,
        // O Django gosta das datas no formato universal ISO 8601 (ex: 2026-03-20T15:00:00)
        'limit_date': limitDate.toIso8601String(),
        'latitude': latitude,
        'longitude': longitude,
        
        // 2. Anexamos a foto física que o utilizador tirou!
        'image_url': await MultipartFile.fromFile(
          imagePath, 
          filename: 'residuos_${DateTime.now().millisecondsSinceEpoch}.jpg'
        ),
      });

      // 3. Enviamos o pacote para a rota /lotes/ (Atenção à barra no final!)
      final response = await _dio.post(
        '/lotes/',
        data: formData,
      );

      // 4. O Django devolve os dados do Lote recém-criado e nós transformamos em Objeto
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
      // Fazemos um pedido DELETE apontando para o ID específico do lote
      await _dio.delete('/lotes/$loteId/');
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
  Future<List<LoteResumido>> getMeusLotes() async {
    try {
      // Fazemos um pedido GET àquela rota que criámos no backend
      final response = await _dio.get('/meus-lotes/');

      // O Django devolve uma lista de JSONs. Vamos transformá-la numa Lista do Flutter
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
  Future<Map<String, dynamic>> rateScheduling(
      String schedulingId, RatingRequest request) {
    throw UnimplementedError('rateScheduling ainda não implementado');
  }
}
