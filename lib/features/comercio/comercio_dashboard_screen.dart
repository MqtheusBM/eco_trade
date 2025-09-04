import 'package:eco_trade/core/models/rating.dart';
import 'package:eco_trade/core/models/providers.dart';
import 'package:eco_trade/features/comercio/compost_analysis_sceen.dart';
import 'package:eco_trade/features/comercio/interested_producers_screen.dart';
import 'package:eco_trade/features/shared/impact_report_screen.dart';
import 'package:eco_trade/features/shared/profile_screen.dart';
import 'package:eco_trade/features/shared/scheduling_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ComercioDashboardScreen extends ConsumerWidget {
  const ComercioDashboardScreen({super.key});

  /// Função para lidar com a ação de finalizar um agendamento.
  Future<void> _handleFinalizeAction(BuildContext context, WidgetRef ref, String loteId) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final response = await ref.read(apiServiceProvider).finalizeScheduling(loteId);
      
      Navigator.of(context).pop(); // Fecha o diálogo de loading

      ref.refresh(meusLotesProvider); // Atualiza a lista de lotes

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response['message'] ?? 'Operação concluída!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      Navigator.of(context).pop(); // Fecha o diálogo de loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao finalizar: $e'), backgroundColor: Colors.red),
      );
    }
  }

  /// Função para mostrar o diálogo de avaliação de um agendamento.
  void _showRatingDialog(BuildContext context, WidgetRef ref, String loteId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        double _rating = 3.0;
        final _commentsController = TextEditingController();
        bool _isSubmitting = false;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Avaliar Agendamento'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Por favor, avalie a sua experiência com o produtor.'),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return IconButton(
                          onPressed: () => setState(() => _rating = index + 1.0),
                          icon: Icon(
                            index < _rating ? Icons.star : Icons.star_border,
                            color: Colors.amber,
                            size: 32,
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _commentsController,
                      decoration: const InputDecoration(
                        labelText: 'Comentários (opcional)',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: _isSubmitting ? null : () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: _isSubmitting ? null : () async {
                    setState(() => _isSubmitting = true);
                    try {
                      final request = RatingRequest(rating: _rating, comments: _commentsController.text);
                      final response = await ref.read(apiServiceProvider).rateScheduling(loteId, request);
                      
                      Navigator.of(dialogContext).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(response['message']!), backgroundColor: Colors.green),
                      );
                    } catch (e) {
                       Navigator.of(dialogContext).pop();
                       ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Erro ao avaliar: $e'), backgroundColor: Colors.red),
                      );
                    }
                  },
                  child: _isSubmitting
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Enviar Avaliação'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meusLotesAsyncValue = ref.watch(meusLotesProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Lotes Cadastrados'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            tooltip: 'Meu Perfil',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.assessment),
            tooltip: 'Relatório de Impacto',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ImpactReportScreen()),
              );
            },
          ),
        ],
      ),
      body: meusLotesAsyncValue.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Erro: $err')),
        data: (lotes) {
          if (lotes.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Text(
                  'Você ainda não cadastrou nenhum lote.\nClique no botão "+" para começar!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () => ref.refresh(meusLotesProvider.future),
            child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: lotes.length,
              itemBuilder: (context, index) {
                final lote = lotes[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 12, 0, 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            lote.imageUrl,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(width: 80, height: 80, color: Colors.grey.shade200, child: const Icon(Icons.broken_image, color: Colors.grey, size: 40)),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(lote.description, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 3, overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 8),
                              Chip(
                                label: Text(lote.status.toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10)),
                                backgroundColor: lote.status == 'ativo' ? Colors.green : (lote.status == 'confirmado' ? Colors.blue : (lote.status == 'finalizado' ? Colors.grey.shade600 : Colors.orange)),
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                side: BorderSide.none,
                              ),
                            ],
                          ),
                        ),
                        PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'interessados') {
                              Navigator.of(context).push(MaterialPageRoute(builder: (context) => InterestedProducersScreen(loteId: lote.id, loteDescription: lote.description)));
                            } else if (value == 'analisar') {
                              Navigator.of(context).push(MaterialPageRoute(builder: (context) => CompostAnalysisScreen(loteId: lote.id, loteDescription: lote.description)));
                            } else if (value == 'finalizar') {
                              _handleFinalizeAction(context, ref, lote.id);
                            } else if (value == 'avaliar') {
                              _showRatingDialog(context, ref, lote.id);
                            } else if (value == 'ver_agendamento') {
                              Navigator.of(context).push(MaterialPageRoute(builder: (context) => SchedulingDetailsScreen(schedulingId: lote.id)));
                            }
                          },
                          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                            if (lote.status == 'ativo')
                              const PopupMenuItem<String>(
                                value: 'interessados',
                                child: ListTile(leading: Icon(Icons.people), title: Text('Ver Interessados')),
                              ),
                            if (lote.status == 'confirmado' || lote.status == 'finalizado')
                               const PopupMenuItem<String>(
                                value: 'ver_agendamento',
                                child: ListTile(leading: Icon(Icons.calendar_today), title: Text('Ver Agendamento')),
                              ),
                            if (lote.status != 'finalizado')
                              const PopupMenuItem<String>(
                                value: 'analisar',
                                child: ListTile(leading: Icon(Icons.biotech), title: Text('Analisar Composto')),
                              ),
                            if (lote.status == 'confirmado')
                              const PopupMenuItem<String>(
                                value: 'finalizar',
                                child: ListTile(leading: Icon(Icons.check_circle, color: Colors.green), title: Text('Finalizar Agendamento')),
                              ),
                            if (lote.status == 'finalizado')
                              const PopupMenuItem<String>(
                                value: 'avaliar',
                                child: ListTile(leading: Icon(Icons.star, color: Colors.amber), title: Text('Avaliar Agendamento')),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('A tela de criação de lote será implementada aqui.')),
          );
        },
        child: const Icon(Icons.add),
        tooltip: 'Adicionar Novo Lote',
      ),
    );
  }
}

