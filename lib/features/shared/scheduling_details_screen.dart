import 'package:eco_trade/core/models/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

/// Uma tela que exibe os detalhes completos de um agendamento.
/// Pode ser acedida tanto pelo Comércio como pelo Produtor.
class SchedulingDetailsScreen extends ConsumerWidget {
  final String schedulingId;

  const SchedulingDetailsScreen({super.key, required this.schedulingId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Observamos o provedor que busca os detalhes do agendamento.
    final detailsAsyncValue =
        ref.watch(schedulingDetailsProvider(schedulingId));

    return Scaffold(
      appBar: AppBar(title: const Text('Detalhes do Agendamento')),
      body: detailsAsyncValue.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) =>
            Center(child: Text('Erro ao carregar detalhes: $err')),
        data: (details) {
          final formattedDate = DateFormat('dd/MM/yyyy \'às\' HH:mm')
              .format(details.scheduling.scheduledDate);
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Cartão de detalhes do lote com a imagem centralizada
                Center(
                  // <-- ADICIONADO AQUI PARA CENTRALIZAR
                  child: Card(
                    margin: const EdgeInsets.only(bottom: 16.0),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    clipBehavior: Clip.antiAlias,
                    child: ConstrainedBox(
                      // Garante que o Card não ultrapasse a largura da tela
                      constraints: BoxConstraints(
                        maxWidth:
                            500, // Um limite máximo para telas muito grandes (tablets)
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Imagem
                          Image.network(
                            details.batch.imageUrl,
                            width: double.infinity,
                            height: 200,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                              width: double.infinity,
                              height: 200,
                              color: Colors.grey[200],
                              child: const Center(
                                child: Icon(Icons.broken_image,
                                    color: Colors.grey, size: 50),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Detalhes do Lote",
                                    style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold)),
                                const Divider(height: 20, thickness: 1),
                                _buildInfoRow(
                                    'Descrição:', details.batch.descriptionIa),
                                _buildInfoRow('Peso (Kg):',
                                    details.batch.weight.toString()),
                                _buildInfoRow(
                                    'Status do Lote:', details.batch.status),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                _buildInfoCard(
                  title: 'Status do Agendamento',
                  children: [
                    Center(
                      child: Chip(
                        label: Text(
                          details.scheduling.status
                              .toUpperCase()
                              .replaceAll('_', ' '),
                          style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        backgroundColor: const Color.fromRGBO(9, 132, 85, 0.8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                      ),
                    ),
                    _buildInfoRow('Data Agendada:', formattedDate),
                  ],
                ),
                _buildInfoCard(
                  title: 'Informações do Comércio',
                  children: [
                    _buildInfoRow('Nome Fantasia:', details.merchant.name),
                    _buildInfoRow('Razão Social:', details.merchant.legalName),
                    _buildInfoRow('Telefone:', details.merchant.phoneNumber),
                    _buildInfoRow('Endereço:',
                        '${details.merchant.address.street}, ${details.merchant.address.number}\n${details.merchant.address.neighborhood}, ${details.merchant.address.city} - ${details.merchant.address.state}'),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Widget auxiliar para criar os cartões de informação.
  Widget _buildInfoCard(
      {required String title, required List<Widget> children}) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(height: 20, thickness: 1),
            ...children,
          ],
        ),
      ),
    );
  }

  /// Widget auxiliar para criar uma linha de informação (label + valor).
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
