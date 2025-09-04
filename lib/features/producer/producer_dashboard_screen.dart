import 'package:eco_trade/core/models/providers.dart';
import 'package:eco_trade/features/home/home_screen.dart';
import 'package:eco_trade/features/producer/widgets/scheduling_list.dart';
import 'package:eco_trade/features/shared/impact_report_screen.dart';
import 'package:eco_trade/features/shared/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A tela principal para o utilizador do tipo "Produtor".
/// Utiliza uma TabBar para separar a visualização dos seus agendamentos
/// da funcionalidade de busca de novos lotes.
class ProducerDashboardScreen extends ConsumerWidget {
  const ProducerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // O DefaultTabController coordena a AppBar.bottom (a TabBar) com o
    // TabBarView no corpo do Scaffold.
    return DefaultTabController(
      length: 2, // Temos duas abas.
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Painel do Produtor'),
          actions: [
            // Botão para aceder ao Perfil.
            IconButton(
              icon: const Icon(Icons.person),
              tooltip: 'Meu Perfil',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                );
              },
            ),
            // Botão para aceder ao Relatório de Impacto.
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
          // A TabBar é colocada na parte inferior da AppBar.
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(icon: Icon(Icons.calendar_month), text: 'Meus Agendamentos'),
              Tab(icon: Icon(Icons.search), text: 'Buscar Lotes'),
            ],
          ),
        ),
        // O corpo do Scaffold é uma TabBarView, que contém as telas para cada aba.
        body: const TabBarView(
          children: [
            // Conteúdo da primeira aba: a lista de agendamentos do produtor.
            SchedulingList(),

            // Conteúdo da segunda aba: a tela de busca de lotes por proximidade.
            HomeScreen(),
          ],
        ),
      ),
    );
  }
}
