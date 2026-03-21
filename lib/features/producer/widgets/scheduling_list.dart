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
    'pending': 'Pendentes',
    'scheduled': 'Agendados',
    'active': 'Ativos',
    'confirmed': 'Confirmados',
    'finished': 'Finalizados',
    'rejected': 'Rejeitados',
    'canceled': 'Cancelados',
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
                                  backgroundColor:
                                      const Color.fromRGBO(9, 132, 85, 0.8)),
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

  /// Mostra um aviso antes de cancelar e envia o pedido para a API
  Future<void> _cancelarAgendamento(
      BuildContext context, String agendamentoId) async {
    // 1. Pergunta se tem a certeza
    final bool? confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancelar Recolha?'),
        content: const Text(
            'Tem certeza que deseja cancelar? O lote voltará para o mapa para outros produtores.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Não, manter'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Sim, Cancelar',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    // Se ele clicou fora ou disse "Não", paramos aqui.
    if (confirmar != true) return;
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('A cancelar... ⏳')),
    );

    try {
      // 2. Manda o comando para o Django
      await ref.read(apiServiceProvider).cancelarColeta(agendamentoId);

      // 3. Atualiza a lista!
      ref.refresh(minhasColetasProvider);

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Recolha cancelada com sucesso! 🔄'),
            backgroundColor: Colors.green),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1. Usamos o NOVO provider que acabámos de criar
    final schedulingsAsyncValue = ref.watch(minhasColetasProvider);

    return Column(
      children: [
        // Filtros (mantidos iguais)
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
            data: (schedulingsRaw) {
              // 2. Filtramos os dados recebidos do Django com base no botão clicado
              final schedulings = schedulingsRaw.where((s) {
                if (_selectedStatus == null) return true;
                return s['status'] == _selectedStatus;
              }).toList();

              if (schedulings.isEmpty) {
                return Center(
                  child: Text(
                      'Nenhum agendamento encontrado${_selectedStatus == null ? '' : ' com este status'}.'),
                );
              }

              return RefreshIndicator(
                onRefresh: () => ref.refresh(minhasColetasProvider.future),
                child: ListView.builder(
                  itemCount: schedulings.length,
                  itemBuilder: (context, index) {
                    final scheduling = schedulings[index];

                    // Lemos a data que vem do Django (pode ser a 'proposed_date' ou a data de criação)
                    final dataString = scheduling['proposed_date'] ??
                        scheduling['created_at'] ??
                        DateTime.now().toString();
                    // Removemos a hora, mostra apenas Dia/Mês/Ano
                    final formattedDate = DateFormat('dd/MM/yyyy')
                        .format(DateTime.parse(dataString));

                    final descricaoLote = scheduling['lote_details']
                            ?['description'] ??
                        'Resíduos';
                    final statusAtual = scheduling['status'] ?? 'pending';

                    // Procura no dicionário a palavra em português. Se não achar, mostra o original.
                    final statusTraduzido =
                        _statusFilters[statusAtual] ?? statusAtual;

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 16.0),
                        title: Text(descricaoLote,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Data: $formattedDate'),
                            const SizedBox(height: 8),
                            Chip(
                              label: Text(statusTraduzido.toUpperCase()),
                              backgroundColor: _getStatusColor(statusAtual),
                              labelStyle: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                            ),
                          ],
                        ),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'detalhes') {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text('Detalhes em construção!')));
                            } else if (value == 'avaliar') {
                              _showRatingDialog(
                                  context, scheduling['id'].toString());
                            } else if (value == 'cancelar') {
                              _cancelarAgendamento(
                                  context, scheduling['id'].toString());
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
                            if (statusAtual == 'finalizado')
                              const PopupMenuItem<String>(
                                value: 'avaliar',
                                child: ListTile(
                                    leading:
                                        Icon(Icons.star, color: Colors.amber),
                                    title: Text('Avaliar Comércio')),
                              ),
                            // Só mostramos o botão se a recolha ainda estiver pendente ou agendada
                            if (statusAtual == 'pending' ||
                                statusAtual == 'scheduled' ||
                                statusAtual == 'active')
                              const PopupMenuItem<String>(
                                value: 'cancelar',
                                child: ListTile(
                                    leading:
                                        Icon(Icons.cancel, color: Colors.red),
                                    title: Text('Cancelar Recolha',
                                        style: TextStyle(color: Colors.red))),
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
      case 'canceled':
        return Colors.redAccent.shade400;
      case 'finalizado':
        return Colors.grey.shade600;
      default:
        return Colors.grey;
    }
  }
}
