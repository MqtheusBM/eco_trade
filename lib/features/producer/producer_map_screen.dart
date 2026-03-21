import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:eco_trade/core/models/providers.dart'; // Importante para puxar os lotes
import 'package:eco_trade/core/models/lote.dart';

class ProducerMapScreen extends ConsumerStatefulWidget {
  const ProducerMapScreen({super.key});

  @override
  ConsumerState<ProducerMapScreen> createState() => _ProducerMapScreenState();
}

class _ProducerMapScreenState extends ConsumerState<ProducerMapScreen> {
  final LatLng _boaVistaCenter = const LatLng(2.8235, -60.6758);

  // A janelinha que sobe quando tocamos num lote
  void _mostrarDetalhesLote(BuildContext context, LoteResumido lote) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Oportunidade de Recolha',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.scale, color: Colors.green),
                  const SizedBox(width: 8),
                  Text('Peso estimado: ${lote.weight} Kg', style: const TextStyle(fontSize: 16)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.blue),
                  const SizedBox(width: 8),
                  // MUDOU DE descriptionAI PARA description
                  Expanded(child: Text('Descrição: ${lote.description}', style: const TextStyle(fontSize: 16))), 
                ],
              ),
              const SizedBox(height: 24),
              // === O NOVO BOTÃO DE AGENDAMENTO ===
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () async {
                  // 1. Abre o calendário
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now().add(const Duration(days: 1)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 30)),
                  );

                  // Se cancelou o calendário, para aqui.
                  if (pickedDate == null) return; 

                  // === A NOSSA PROTEÇÃO (O FIM DO SUBLINHADO AZUL) ===
                  // Pergunta: "O ecrã ainda existe depois de esperarmos pelo calendário?"
                  if (!context.mounted) return; 
                  // ====================================================

                  // 2. Fecha a janelinha do lote em segurança
                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('A agendar o caminhão... 🚛')),
                  );

                  try {
                    // 3. Pede à API para agendar
                    await ref.read(apiServiceProvider).agendarColeta(lote.id, pickedDate);

                    // 4. MÁGICA: Atualiza o mapa! 
                    ref.refresh(lotesDisponiveisProvider);

                    // === OUTRA PROTEÇÃO DEPOIS DO AWAIT DA API ===
                    if (!context.mounted) return;

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Recolha agendada com sucesso! 🌱'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } catch (e) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Erro: $e'), backgroundColor: Colors.red),
                    );
                  }
                },
                child: const Text('Agendar Recolha', style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final lotesAsync = ref.watch(lotesDisponiveisProvider);

    return Scaffold(
      body: lotesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: Colors.green)),
        error: (error, stack) => Center(child: Text('Erro ao carregar mapa: $error')),
        data: (lotesAtivos) {
          return FlutterMap(
            options: MapOptions(
              initialCenter: _boaVistaCenter,
              initialZoom: 13.5,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.eco_trade',
              ),
              MarkerLayer(
                markers: lotesAtivos.map((lote) {
                  return Marker(
                    // === AQUI ESTÁ A CORREÇÃO: lote.location.latitude ===
                    point: LatLng(lote.location.latitude, lote.location.longitude),
                    width: 50,
                    height: 50,
                    child: GestureDetector(
                      onTap: () => _mostrarDetalhesLote(context, lote),
                      child: const Icon(
                        Icons.location_on,
                        color: Colors.green,
                        size: 45,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        onPressed: () => ref.refresh(lotesDisponiveisProvider),
        child: const Icon(Icons.refresh, color: Colors.green),
      ),
    );
  }
}