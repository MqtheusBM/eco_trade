import 'package:eco_trade/core/models/providers.dart';
import 'package:eco_trade/features/comercio/confirmation_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Uma tela que exibe uma lista de produtores que manifestaram interesse
/// em recolher um lote específico de um Comércio.
class InterestedProducersScreen extends ConsumerStatefulWidget {
  final String loteId;
  final String loteDescription;

  const InterestedProducersScreen({
    super.key,
    required this.loteId,
    required this.loteDescription,
  });

  @override
  ConsumerState<InterestedProducersScreen> createState() =>
      _InterestedProducersScreenState();
}

class _InterestedProducersScreenState
    extends ConsumerState<InterestedProducersScreen> {
  // Guarda o ID do produtor que está a ser confirmado para mostrar o loading
  // apenas no botão pressionado.
  String? _confirmingProducerId;

  /// Função chamada quando o botão "Confirmar Recolha" é pressionado.
  Future<void> _confirmCollection(String producerId) async {
    // Ativa o indicador de carregamento para o produtor específico.
    setState(() {
      _confirmingProducerId = producerId;
    });

    try {
      // Chama o método da API através do Riverpod.
      final confirmationDetails = await ref
          .read(apiServiceProvider)
          .confirmCollection(widget.loteId, producerId);

      if (mounted) {
        // Navega para a tela de confirmação e remove a tela atual da pilha de navegação.
        // Isto impede que o utilizador volte para a lista de interessados.
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) =>
                ConfirmationScreen(confirmation: confirmationDetails),
          ),
        );
      }
    } catch (e) {
      // Em caso de erro, mostra uma mensagem.
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao confirmar: $e')),
        );
      }
    } finally {
      // Garante que o indicador de carregamento é desativado no final.
      if (mounted) {
        setState(() {
          _confirmingProducerId = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Observamos o provedor que busca os produtores interessados,
    // passando o ID do lote como parâmetro.
    final producersAsyncValue =
        ref.watch(interestedProducersProvider(widget.loteId));

    return Scaffold(
      appBar: AppBar(
        title: Text('Interessados: ${widget.loteDescription}'),
      ),
      body: producersAsyncValue.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Erro: $err')),
        data: (producers) {
          if (producers.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('Ainda não há produtores interessados neste lote.',
                    textAlign: TextAlign.center),
              ),
            );
          }

          // Constrói a lista de produtores.
          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: producers.length,
            itemBuilder: (context, index) {
              final producer = producers[index];
              // Verifica se o produtor atual é o que está a ser confirmado.
              final isLoading = _confirmingProducerId == producer.producerId;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                elevation: 3,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(producer.producerName,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 20),
                          const SizedBox(width: 4),
                          Text(producer.reputation.toString(),
                              style: const TextStyle(fontSize: 16)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                          '${producer.producerAddress.street}, ${producer.producerAddress.number}'),
                      Text(
                          '${producer.producerAddress.neighborhood}, ${producer.producerAddress.city}'),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          // Desativa o botão se uma confirmação estiver em curso.
                          onPressed: isLoading
                              ? null
                              : () => _confirmCollection(producer.producerId),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 3, color: Colors.white),
                                )
                              : const Text('Confirmar Recolha'),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
