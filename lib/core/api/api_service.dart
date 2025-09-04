import 'package:eco_trade/core/models/compost_analysis.dart';
import 'package:eco_trade/core/models/impact_report.dart';
import 'package:eco_trade/core/models/interested_producer.dart';
import 'package:eco_trade/core/models/lote.dart';
import 'package:eco_trade/core/models/producer_scheduling.dart';
import 'package:eco_trade/core/models/rating.dart';
import 'package:eco_trade/core/models/scheduling_confirmation.dart';
import 'package:eco_trade/core/models/scheduling_creation.dart';
import 'package:eco_trade/core/models/scheduling_details.dart';

/// A interface define o "contrato" que qualquer serviço de API (real ou mock)
/// deve seguir. Se adicionar um novo método aqui, será obrigado a implementá-lo
/// tanto no ApiService real como no MockApiService, mantendo o código consistente.
abstract class ApiService {
  // --- MÉTODOS DO PRODUTOR ---

  /// Busca uma lista de lotes próximos com base na localização do utilizador.
  Future<List<LoteResumido>> getLotes({
    required double lat,
    required double long,
    int raioKm = 20,
  });

  /// Regista o interesse de um Produtor num lote específico.
  Future<void> registerInterest(String loteId);

  /// Busca a lista de agendamentos associados ao Produtor autenticado.
  Future<List<ProducerScheduling>> getProducerSchedulings({String? status});

  /// Permite que um Produtor proponha um novo agendamento de recolha para um lote.
  Future<SchedulingCreationResponse> createScheduling(SchedulingRequest request);

  // --- MÉTODOS DO COMÉRCIO ---

  /// Regista um novo lote de resíduos no sistema.
  Future<Lote> createLote({
    required String imagePath,
    required num weight,
    required DateTime limitDate,
    required double latitude,
    required double longitude,
  });

  /// Busca a lista de lotes criados pelo Comércio atualmente autenticado.
  Future<List<LoteResumido>> getMeusLotes();

  /// Busca a lista de Produtores que manifestaram interesse num lote específico.
  Future<List<InterestedProducer>> getInterestedProducers(String loteId);

  /// Envia dados de uma pilha de composto para análise e retorna recomendações.
  Future<CompostAnalysisResponse> analyzeCompost(String loteId, CompostAnalysisRequest request);

  /// Permite que um Comércio confirme a recolha de um lote com um Produtor específico.
  Future<SchedulingConfirmation> confirmCollection(String loteId, String producerId);

  /// Finaliza um agendamento que já foi confirmado.
  Future<Map<String, dynamic>> finalizeScheduling(String schedulingId);

  /// Submete uma avaliação (estrelas e comentário) para um agendamento finalizado.
  Future<Map<String, dynamic>> rateScheduling(String schedulingId, RatingRequest request);

  // --- MÉTODOS PARTILHADOS ---

  /// Busca os detalhes completos de um agendamento específico,
  /// acessível tanto pelo Comércio como pelo Produtor.
  Future<SchedulingDetails> getSchedulingDetails(String schedulingId);

  /// Gera um relatório de impacto com base num período de datas.
  Future<ImpactReportResponse> generateImpactReport(ImpactReportRequest request);
}

