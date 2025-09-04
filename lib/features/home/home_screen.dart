//import 'package:eco_trade/core/models/lote.dart';
import 'package:eco_trade/core/models/providers.dart';
import 'package:eco_trade/features/lot_details/lot_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

/// A tela (agora usada como uma aba) onde o Produtor pode descobrir novos
/// lotes de resíduos com base na sua localização atual.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Primeiro, tentamos obter a localização do utilizador.
    // O `locationProvider` trata de todo o fluxo de permissões e busca do GPS.
    final locationAsyncValue = ref.watch(locationProvider);

    // O Scaffold já não é necessário aqui, pois esta tela será embutida
    // numa TabBarView que já tem o seu próprio Scaffold.
    // A AppBar também foi movida para o `ProducerDashboardScreen`.
    return locationAsyncValue.when(
      // 1. Estado de Carregamento: a aguardar a permissão e a localização.
      loading: () => const Center(child: CircularProgressIndicator()),

      // 2. Estado de Erro: algo correu mal ao obter a localização.
      error: (err, stack) => Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text('Erro ao obter localização: $err',
              textAlign: TextAlign.center),
        ),
      ),

      // 3. Estado de Sucesso: a localização foi obtida.
      data: (position) {
        // Usamos a posição obtida para chamar o widget que exibe a lista de lotes.
        return _LotesList(position: position);
      },
    );
  }
}

/// Widget interno para exibir a lista de lotes.
/// Foi separado para evitar o aninhamento excessivo de `.when()` clauses.
class _LotesList extends ConsumerWidget {
  final Position position;

  const _LotesList({required this.position});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Agora, observamos o provider que busca os lotes, passando as coordenadas
    // da localização que recebemos.
    final lotesAsyncValue = ref.watch(lotesProvider(
      (lat: position.latitude, long: position.longitude),
    ));

    return lotesAsyncValue.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child:
              Text('Erro ao buscar lotes: $err', textAlign: TextAlign.center),
        ),
      ),
      data: (lotes) {
        if (lotes.isEmpty) {
          return const Center(
              child: Text('Nenhum lote encontrado perto de si.'));
        }

        // Se houver lotes, construímos a lista.
        return RefreshIndicator(
          onRefresh: () => ref.refresh(lotesProvider(
            (lat: position.latitude, long: position.longitude),
          ).future),
          child: ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: lotes.length,
            itemBuilder: (context, index) {
              final lote = lotes[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 3,
                child: InkWell(
                  onTap: () {
                    // Navega para a tela de detalhes, passando o objeto 'lote' completo.
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => LotDetailsScreen(lote: lote),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            lote.imageUrl,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, progress) =>
                                progress == null
                                    ? child
                                    : const Center(
                                        child: CircularProgressIndicator()),
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.broken_image,
                                    size: 80, color: Colors.grey),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                lote.description,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.location_on,
                                      size: 16, color: Colors.grey.shade600),
                                  const SizedBox(width: 4),
                                  Text(
                                    lote.distance,
                                    style:
                                        TextStyle(color: Colors.grey.shade600),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
