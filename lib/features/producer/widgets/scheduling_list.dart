import 'package:eco_trade/core/models/lote.dart';
import 'package:eco_trade/core/models/rating.dart';
import 'package:eco_trade/core/models/providers.dart';
import 'package:eco_trade/features/shared/scheduling_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class SchedulingList extends ConsumerStatefulWidget {
  const SchedulingList({super.key});

  @override
  ConsumerState<SchedulingList> createState() => _SchedulingListState();
}

class _SchedulingListState extends ConsumerState<SchedulingList> {
  String? _selectedStatus;

  final Map<String, String> _statusFilters = {
    'ativo': 'Ativos',
    'aguardando_confirmação': 'Aguardando',
    'confirmado': 'Confirmados',
    'finalizado': 'Finalizados',
    'rejeitado': 'Rejeitados',
  };

  /// Mostra o diálogo para o Produtor avaliar o Comércio.
  void _showRatingDialog(BuildContext context, String schedulingId) {
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
              title: const Text('Avaliar Comércio'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                        'Por favor, avalie a sua experiência com este comércio.'),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return IconButton(
                          onPressed: () =>
                              setState(() => _rating = index + 1.0),
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
                  onPressed: _isSubmitting
                      ? null
                      : () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: _isSubmitting
                      ? null
                      : () async {
                          setState(() => _isSubmitting = true);
                          try {
                            final request = RatingRequest(
                                rating: _rating,
                                comments: _commentsController.text);
                            final response = await ref
                                .read(apiServiceProvider)
                                .rateScheduling(schedulingId, request);

                            Navigator.of(dialogContext).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(response['message']!),
                                  backgroundColor: const Color.fromRGBO(9, 132, 85, 0.8)),
                            );
                          } catch (e) {
                            Navigator.of(dialogContext).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text('Erro ao avaliar: $e'),
                                  backgroundColor: Colors.red),
                            );
                          }
                        },
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
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
  Widget build(BuildContext context) {
    final schedulingsAsyncValue =
        ref.watch(producerSchedulingsProvider(_selectedStatus));

    return Column(
      children: [
        // Filtros (sem alterações)
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Wrap(
            spacing: 8.0,
            children: _statusFilters.entries.map((entry) {
              return FilterChip(
                label: Text(entry.value),
                selected: _selectedStatus == entry.key,
                onSelected: (selected) {
                  setState(() {
                    _selectedStatus = selected ? entry.key : null;
                  });
                },
              );
            }).toList(),
          ),
        ),
        // Lista de Agendamentos
        Expanded(
          child: schedulingsAsyncValue.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Erro: $err')),
            data: (schedulings) {
              if (schedulings.isEmpty) {
                return Center(
                    child: Text(
                        'Nenhum agendamento encontrado${_selectedStatus == null ? '' : ' com este status'}.'));
              }
              return RefreshIndicator(
                onRefresh: () => ref.refresh(
                    producerSchedulingsProvider(_selectedStatus).future),
                child: ListView.builder(
                  itemCount: schedulings.length,
                  itemBuilder: (context, index) {
                    final scheduling = schedulings[index];
                    final formattedDate = DateFormat('dd/MM/yy \'às\' HH:mm')
                        .format(scheduling.scheduledDate);

                    // ATUALIZAÇÃO: Usamos um ListTile para facilmente adicionar o menu de ações.
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 16.0),
                        title: Text(scheduling.batchInfo.description,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Comércio: ${scheduling.merchantInfo.name}'),
                            const SizedBox(height: 4),
                            Text('Data: $formattedDate'),
                            const SizedBox(height: 8),
                            Chip(
                              label: Text(scheduling.status
                                  .replaceAll('_', ' ')
                                  .toUpperCase()),
                              backgroundColor:
                                  _getStatusColor(scheduling.status),
                              labelStyle: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                            ),
                          ],
                        ),
                        // Menu de Ações
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'detalhes') {
                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => SchedulingDetailsScreen(
                                    schedulingId: scheduling.schedulingId),
                              ));
                            } else if (value == 'avaliar') {
                              _showRatingDialog(
                                  context, scheduling.schedulingId);
                            }
                          },
                          itemBuilder: (BuildContext context) =>
                              <PopupMenuEntry<String>>[
                            const PopupMenuItem<String>(
                              value: 'detalhes',
                              child: ListTile(
                                  leading: Icon(Icons.visibility),
                                  title: Text('Ver Detalhes')),
                            ),
                            // Mostra a opção de avaliar apenas se o agendamento estiver finalizado.
                            if (scheduling.status == 'finalizado')
                              const PopupMenuItem<String>(
                                value: 'avaliar',
                                child: ListTile(
                                    leading:
                                        Icon(Icons.star, color: Colors.amber),
                                    title: Text('Avaliar Comércio')),
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
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'ativo':
        return Colors.blue;
      case 'aguardando_confirmação':
        return Colors.orange;
      case 'confirmado':
        return const Color.fromRGBO(9, 132, 85, 0.8);
      case 'rejeitado':
        return Colors.red;
      case 'finalizado':
        return Colors.grey.shade600;
      default:
        return Colors.grey;
    }
  }
}
