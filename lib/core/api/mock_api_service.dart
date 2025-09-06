import 'package:eco_trade/core/api/api_service.dart';
import 'package:eco_trade/core/models/compost_analysis.dart';
import 'package:eco_trade/core/models/impact_report.dart';
import 'package:eco_trade/core/models/interested_producer.dart';
import 'package:eco_trade/core/models/lote.dart';
import 'package:eco_trade/core/models/producer_scheduling.dart';
import 'package:eco_trade/core/models/rating.dart';
import 'package:eco_trade/core/models/scheduling_confirmation.dart';
import 'package:eco_trade/core/models/scheduling_creation.dart';
// Importa o ficheiro de detalhes, mas esconde as classes com nomes repetidos para evitar conflitos.
import 'package:eco_trade/core/models/scheduling_details.dart'
    hide Scheduling, Batch;
import 'package:eco_trade/core/models/user.dart';
import 'package:intl/intl.dart';

/// Esta classe simula o comportamento da nossa API real.
class MockApiService implements ApiService {
  // --- MÉTODOS DE AUTENTICAÇÃO ---
  @override
  Future<Map<String, dynamic>> signIn(String email, String password) async {
    await Future.delayed(const Duration(seconds: 2));
    print('--- MOCK API: Tentativa de login para o email: $email ---');

    // ATUALIZADO: Adicionado login para o perfil de Produtor
    if (email.toLowerCase() == "produtor@ecotrade.com" &&
        password == "senha123") {
      print('--- MOCK API: Login de Produtor bem-sucedido ---');
      return {
        "token": "jwt.token.produtor.67890",
        "user": {
          "uid": "p1r2o3d4u5t6o7r8",
          "email": "produtor@ecotrade.com",
          "name": "João da Silva",
          "phone_number": "95987654321",
          "role":
              "producer", // O AuthService usa este campo para decidir o ecrã
          "created_at": "2025-09-05T10:00:00.000Z",
          "cpf": "123.456.789-00",
          "collection_capacity_kg": 250,
          "accepted_waste_types": ["orgânico", "plástico", "papelão"]
        }
      };
    } else if (email.toLowerCase() == "contato@supermercado.com" &&
        password == "senhaForte123") {
      print('--- MOCK API: Login de Comércio bem-sucedido ---');
      return {
        "token": "jwt.token.muito.seguro.12345",
        "user": {
          "uid": "a1b2c3d4e5f6g7h8",
          "email": "contato@supermercado.com",
          "name": "Supermercado Preço Bom",
          "phone_number": "95991234567",
          "role": "merchant",
          "created_at": "2025-09-04T16:55:40.255Z",
          "tax_id": "12.345.678/0001-99",
          "legal_name": "Supermercado Preço Bom Ltda.",
          "address": {
            "street": "Av. Capitão Ene Garcez",
            "number": "1234",
            "neighborhood": "Centro",
            "city": "Boa Vista",
            "state": "RR",
            "zip_code": "69301-160"
          },
          "location": {"latitude": 2.8235, "longitude": -60.6758}
        }
      };
    } else {
      print('--- MOCK API: Credenciais inválidas ---');
      throw Exception('Credenciais inválidas.');
    }
  }

  // ATUALIZADO: Agora retorna um Map, igual ao signIn, para ser mais realista.
  @override
  Future<Map<String, dynamic>> signUpComercio(Map<String, dynamic> data) async {
    await Future.delayed(const Duration(seconds: 2));
    print('--- MOCK API: A simular registo de Comércio ---');
    print(data);

    // Simula que o backend criou o utilizador e o retorna.
    final newUser = {
      'uid': 'comercio_${DateTime.now().millisecondsSinceEpoch}',
      'role': 'merchant', // Adiciona a role
      ...data, // Usa os dados recebidos para preencher o resto
    };

    return {
      "token": "jwt.token.novo.utilizador.abcde",
      "user": newUser,
    };
  }

  // ATUALIZADO: Agora retorna um Map, igual ao signIn, para ser mais realista.
  @override
  Future<Map<String, dynamic>> signUpProdutor(Map<String, dynamic> data) async {
    await Future.delayed(const Duration(seconds: 2));
    print('--- MOCK API: A simular registo de Produtor ---');
    print(data);

    final newUser = {
      'uid': 'produtor_${DateTime.now().millisecondsSinceEpoch}',
      'role': 'producer', // Adiciona a role
      ...data,
    };

    return {
      "token": "jwt.token.novo.utilizador.fghij",
      "user": newUser,
    };
  }

  // --- MÉTODOS DO PRODUTOR ---

  @override
  Future<List<LoteResumido>> getLotes({
    required double lat,
    required double long,
    int raioKm = 20,
  }) async {
    await Future.delayed(const Duration(seconds: 2));
    print('--- MOCK API: A buscar lotes para lat:$lat, long:$long ---');
    return [
      LoteResumido(
        id: 'lote123',
        description: 'Supermercado Centro: Resíduos orgânicos',
        location: Localizacao(latitude: 2.8215, longitude: -60.6738),
        distance: '1.2 km',
        status: 'ativo',
        imageUrl:
            'https://placehold.co/400x400/7bed9f/000000?text=Org%C3%A2nicos',
        limitDate: DateTime.now().add(const Duration(days: 7)),
      ),
      LoteResumido(
        id: 'lote456',
        description: 'Restaurante Sabor Divino: Óleo de cozinha',
        location: Localizacao(latitude: 2.8255, longitude: -60.6788),
        distance: '2.5 km',
        status: 'ativo',
        imageUrl: 'https://placehold.co/400x400/ffc048/000000?text=%C3%93leo',
        limitDate: DateTime.now().add(const Duration(days: 3)),
      ),
    ];
  }

  @override
  Future<void> registerInterest(String loteId) async {
    await Future.delayed(const Duration(seconds: 1));
    print('--- MOCK API: Interesse registado com sucesso no lote $loteId. ---');
    return;
  }

  @override
  Future<List<ProducerScheduling>> getProducerSchedulings(
      {String? status}) async {
    await Future.delayed(const Duration(seconds: 1));
    print(
        '--- MOCK API: A buscar agendamentos do produtor com status: ${status ?? "todos"} ---');

    final allSchedulings = [
      ProducerScheduling(
        schedulingId: 'agendamento_abc456',
        status: 'confirmado',
        scheduledDate: DateTime.now().add(const Duration(days: 2, hours: 4)),
        batchInfo: BatchInfo(
          id: 'lote_xyz123',
          imageUrl:
              'https://placehold.co/400x400/27ae60/ffffff?text=Org%C3%A2nicos',
          description: 'Lote de orgânicos do Supermercado Centro',
          limitDate: DateTime.now().add(const Duration(days: 5)),
        ),
        merchantInfo: MerchantInfo(
            uid: 'comerciante_xyz123', name: 'Supermercado Preço Bom'),
      ),
      ProducerScheduling(
        schedulingId: 'agendamento_ghi012',
        status: 'aguardando_confirmação',
        scheduledDate: DateTime.now().add(const Duration(days: 1, hours: 2)),
        batchInfo: BatchInfo(
          id: 'lote_rst789',
          imageUrl: 'https://placehold.co/400x400/ffc048/000000?text=%C3%93leo',
          description: 'Óleo de cozinha do Restaurante Sabor Divino',
          limitDate: DateTime.now().add(const Duration(days: 3)),
        ),
        merchantInfo: MerchantInfo(
            uid: 'comerciante_rst789', name: 'Restaurante Sabor Divino'),
      ),
      ProducerScheduling(
        schedulingId: 'agendamento_jkl345',
        status: 'ativo',
        scheduledDate: DateTime.now().add(const Duration(days: 3)),
        batchInfo: BatchInfo(
          id: 'lote_mno012',
          imageUrl: 'https://placehold.co/400x400/f1c40f/000000?text=Metais',
          description: 'Sucata de metal da Oficina Central',
          limitDate: DateTime.now().add(const Duration(days: 4)),
        ),
        merchantInfo:
            MerchantInfo(uid: 'comerciante_mno012', name: 'Oficina Central'),
      ),
      ProducerScheduling(
        schedulingId: 'agendamento_pqr678',
        status: 'rejeitado',
        scheduledDate: DateTime.now().subtract(const Duration(days: 1)),
        batchInfo: BatchInfo(
          id: 'lote_stu345',
          imageUrl: 'https://placehold.co/400x400/c0392b/ffffff?text=Rejeitado',
          description: 'Resíduos de construção civil',
          limitDate: DateTime.now().subtract(const Duration(days: 1)),
        ),
        merchantInfo:
            MerchantInfo(uid: 'comerciante_stu345', name: 'Construtora RR'),
      ),
      ProducerScheduling(
        schedulingId: 'agendamento_def789',
        status: 'finalizado',
        scheduledDate: DateTime.now().subtract(const Duration(days: 4)),
        batchInfo: BatchInfo(
          id: 'lote_uvw456',
          imageUrl:
              'https://placehold.co/400x400/3498db/ffffff?text=Pl%C3%A1stico',
          description: 'Plásticos e papelão da Loja de Embalagens',
          limitDate: DateTime.now().subtract(const Duration(days: 2)),
        ),
        merchantInfo:
            MerchantInfo(uid: 'comerciante_uvw456', name: 'Loja de Embalagens'),
      ),
    ];

    if (status != null) {
      return allSchedulings.where((s) => s.status == status).toList();
    }

    return allSchedulings;
  }

  @override
  Future<SchedulingCreationResponse> createScheduling(
      SchedulingRequest request) async {
    await Future.delayed(const Duration(seconds: 2));
    print(
        '--- MOCK API: Criando agendamento para o lote ${request.loteId} ---');
    return SchedulingCreationResponse(
      id: 'agendamento_${DateTime.now().millisecondsSinceEpoch}',
      status: 'aguardando_confirmação',
      scheduledDate: request.scheduledDate,
      producerId: 'produtor_logado_123',
      merchantId: 'comerciante_dono_do_lote_xyz',
    );
  }

  // --- MÉTODOS DO COMÉRCIO ---

  @override
  Future<Lote> createLote({
    required String imagePath,
    required num weight,
    required DateTime limitDate,
    required double latitude,
    required double longitude,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    print('--- MOCK API: Simulando a criação de um novo lote. ---');
    return Lote(
      id: 'lote_criado_${DateTime.now().millisecondsSinceEpoch}',
      descriptionAI: 'Descrição gerada por IA para o novo lote.',
      weight: weight,
      limitDate: limitDate,
      status: 'ativo',
      imageUrl: 'https://placehold.co/400x400/2ecc71/ffffff?text=Criado!',
      location: Localizacao(latitude: latitude, longitude: longitude),
    );
  }

  @override
  Future<List<LoteResumido>> getMeusLotes() async {
    await Future.delayed(const Duration(seconds: 1));
    print('--- MOCK API: A buscar "Meus Lotes" para o Comércio logado. ---');
    return [
      LoteResumido(
        id: 'meu_lote_1',
        description: 'Lote de Orgânicos da Semana',
        distance: '',
        status: 'ativo',
        location: Localizacao(latitude: 2.82, longitude: -60.67),
        imageUrl: 'https://placehold.co/400x400/27ae60/ffffff?text=Meu+Lote+1',
        limitDate: DateTime.now().add(const Duration(days: 5)),
      ),
      LoteResumido(
        id: 'meu_lote_3',
        description: 'Óleo de Cozinha Usado',
        distance: '',
        status: 'confirmado',
        location: Localizacao(latitude: 2.82, longitude: -60.67),
        imageUrl: 'https://placehold.co/400x400/8e44ad/ffffff?text=Confirmado',
        limitDate: DateTime.now().add(const Duration(days: 1)),
      ),
      LoteResumido(
        id: 'meu_lote_4',
        description: 'Vidros Diversos',
        distance: '',
        status: 'finalizado',
        location: Localizacao(latitude: 2.82, longitude: -60.67),
        imageUrl: 'https://placehold.co/400x400/bdc3c7/ffffff?text=Finalizado',
        limitDate: DateTime.now().subtract(const Duration(days: 10)),
      ),
    ];
  }

  @override
  Future<List<InterestedProducer>> getInterestedProducers(String loteId) async {
    await Future.delayed(const Duration(seconds: 2));
    print(
        '--- MOCK API: A buscar Produtores interessados no lote $loteId. ---');
    return [
      InterestedProducer(
        producerId: 'produtor_123',
        producerName: 'Recicla Roraima LTDA',
        reputation: 4.8,
        producerAddress: Address(
            street: 'Rua das Acácias',
            number: '100',
            neighborhood: 'Pricumã',
            city: 'Boa Vista',
            state: 'RR',
            zipCode: '69309-500'),
      ),
      InterestedProducer(
        producerId: 'produtor_456',
        producerName: 'João da Compostagem',
        reputation: 4.5,
        producerAddress: Address(
            street: 'Av. Brigadeiro Eduardo Gomes',
            number: '500',
            neighborhood: 'Aeroporto',
            city: 'Boa Vista',
            state: 'RR',
            zipCode: '69310-005'),
      ),
    ];
  }

  @override
  Future<CompostAnalysisResponse> analyzeCompost(
      String loteId, CompostAnalysisRequest request) async {
    await Future.delayed(const Duration(seconds: 3));
    print('--- MOCK API: Analisando composto para o lote $loteId ---');
    String recommendationText = "Análise baseada nas suas observações:\n\n";
    if (request.observations.toLowerCase().contains('úmida')) {
      recommendationText +=
          "-> A sua pilha parece estar muito húmida. Adicione mais materiais de carbono, como **${request.availableCarbonMaterials.join(' ou ')}**.\n";
    }
    if (request.observations.toLowerCase().contains('cheiro')) {
      recommendationText +=
          "-> Odores desagradáveis indicam falta de oxigénio. Revolva a sua pilha com mais frequência.\n";
    }
    return CompostAnalysisResponse(recommendations: recommendationText);
  }

  @override
  Future<SchedulingConfirmation> confirmCollection(
      String loteId, String producerId) async {
    await Future.delayed(const Duration(seconds: 2));
    print(
        '--- MOCK API: Confirmando recolha para o lote $loteId com o produtor $producerId ---');
    return SchedulingConfirmation.fromJson({
      "scheduling": {
        "id": "agendamento_abc456",
        "status": "confirmed",
        "scheduled_date":
            DateTime.now().add(const Duration(days: 2)).toIso8601String(),
        "producer_id": producerId,
        "merchant_id": "comerciante_xyz123"
      },
      "batch": {
        "id": loteId,
        "status": "confirmed",
        "description_ia": "Lote misto...",
        "weight": 50
      },
      "producer_confirmed": {
        "id": producerId,
        "name": "Recicla Roraima LTDA",
        "phone_number": "95981035934",
        "reputation": 4.8
      },
      "collection_data": {
        "id": "id_123_abc",
        "full_address":
            "Av. Capitão Ene Garcez, 1234, Centro, Boa Vista, RR, 69301-160",
        "company_name": "Supermercado Preço Bom",
        "telephone_phone_number": "9532102030"
      }
    });
  }

  @override
  Future<Map<String, dynamic>> finalizeScheduling(String schedulingId) async {
    await Future.delayed(const Duration(seconds: 2));
    print('--- MOCK API: Finalizando o agendamento $schedulingId ---');
    return {"message": "Agendamento finalizado com sucesso."};
  }

  @override
  Future<Map<String, dynamic>> rateScheduling(
      String schedulingId, RatingRequest request) async {
    await Future.delayed(const Duration(seconds: 2));
    print(
        '--- MOCK API: Recebendo avaliação para o agendamento $schedulingId ---');
    print(
        '--- DADOS: Avaliação de ${request.rating} estrelas, Comentário: "${request.comments}" ---');
    return {"message": "Avaliação realizada com sucesso."};
  }

  // --- MÉTODOS PARTILHADOS ---

  @override
  Future<SchedulingDetails> getSchedulingDetails(String schedulingId) async {
    await Future.delayed(const Duration(seconds: 2));
    print(
        '--- MOCK API: A buscar detalhes para o agendamento $schedulingId ---');

    return SchedulingDetails.fromJson({
      "scheduling": {
        "id": schedulingId,
        "status": "confirmed",
        "scheduled_date": "2025-09-05T14:00:00.000Z",
        "producer_id": "produtor_abc456",
        "merchant_id": "comerciante_xyz123"
      },
      "batch": {
        "id": "lote_123_abc",
        "status": "confirmed",
        "description_ia": "Lote misto com aprox. 60% folhagens e 40% legumes.",
        "weight": 50,
        "imageUrl":
            "https://placehold.co/400x400/27ae60/ffffff?text=Lote+Detalhe"
      },
      "merchant": {
        "uid": "a1b2c3d4e5f6g7h8",
        "email": "contato@precobom.com",
        "name": "Supermercado Preço Bom",
        "phone_number": "95991234567",
        "role": "merchant",
        "created_at": "2025-09-03T22:50:50.949Z",
        "tax_id": "12.345.678/0001-99",
        "legal_name": "Supermercado Preço Bom Ltda.",
        "address": {
          "street": "Av. Capitão Ene Garcez",
          "number": "1234",
          "neighborhood": "Centro",
          "city": "Boa Vista",
          "state": "RR",
          "zip_code": "69301-160"
        },
        "location": {"latitude": 2.8235, "longitude": -60.6758}
      }
    });
  }

  @override
  Future<ImpactReportResponse> generateImpactReport(
      ImpactReportRequest request) async {
    await Future.delayed(const Duration(seconds: 3));
    print(
        '--- MOCK API: Gerando relatório de impacto de ${request.startDate} a ${request.endDate} ---');

    final formatter = DateFormat('dd/MM/yyyy');
    final String startDateFormatted = formatter.format(request.startDate);
    final String endDateFormatted = formatter.format(request.endDate);

    final days = request.endDate.difference(request.startDate).inDays;
    final totalKgColetados = (days * 15.5).toStringAsFixed(1);
    final viagensEvitadas = (days / 2).ceil();
    final co2Reduzido = (days * 2.5).toStringAsFixed(1);

    final reportText = """
**Relatório de Impacto Ambiental**
**Período:** $startDateFormatted a $endDateFormatted

Parabéns! Durante este período, a sua atividade resultou num impacto positivo:

- **Total de Resíduos Geridos:** **$totalKgColetados Kg** de resíduos desviados de aterros.
- **Emissões de CO₂ Reduzidas:** **$co2Reduzido Kg** de emissões de CO₂ evitadas.
- **Viagens de Caminhões Evitadas:** **$viagensEvitadas** viagens de caminhões de lixo evitadas.
""";

    return ImpactReportResponse(report: reportText);
  }
}