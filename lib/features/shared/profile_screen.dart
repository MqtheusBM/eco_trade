import 'package:eco_trade/core/models/user.dart';
import 'package:eco_trade/core/models/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Uma tela que exibe os detalhes do perfil do utilizador logado.
/// Adapta-se para mostrar os campos de Comércio ou Produtor.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Obtém o utilizador atual do nosso provedor de estado de autenticação.
    final userAsyncValue = ref.watch(authStateProvider);
    final user = userAsyncValue.value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu Perfil'),
      ),
      body: user == null
          ? const Center(child: Text('Nenhum utilizador logado.'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // --- Secção de Informações Gerais ---
                  _buildProfileCard(
                    icon: Icons.person,
                    title: 'Informações Gerais',
                    children: [
                      _buildInfoRow('Nome:', user.name),
                      _buildInfoRow('Email:', user.email),
                      _buildInfoRow('Telefone:', user.phoneNumber),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // --- Secção Específica do Perfil ---
                  // Mostra os campos do Comércio se o perfil for 'comercio'.
                  if (user is Comercio)
                    _buildProfileCard(
                      icon: Icons.store,
                      title: 'Dados do Comércio',
                      children: [
                        _buildInfoRow('Razão Social:', user.legalName),
                        _buildInfoRow('CNPJ:', user.taxId),
                        _buildInfoRow('Endereço:',
                            '${user.address.street}, ${user.address.number}\n${user.address.neighborhood}, ${user.address.city}'),
                      ],
                    ),

                  // Mostra os campos do Produtor se o perfil for 'produtor'.
                  if (user is Produtor)
                    _buildProfileCard(
                      icon: Icons.eco,
                      title: 'Dados do Produtor',
                      children: [
                        _buildInfoRow('Capacidade (Kg):',
                            user.collectionCapacityKg.toString()),
                        _buildInfoRow('Resíduos Aceitos:',
                            user.acceptedWasteTypes.join(', ')),
                      ],
                    ),

                  const SizedBox(height: 32),

                  // --- Botão de Sair ---
                  ElevatedButton.icon(
                    onPressed: () {
                      ref.read(authServiceProvider).signOut();
                      // Fecha a tela de perfil e volta para a tela de login.
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text('Sair da Conta'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  // Widgets auxiliares para construir a UI
  Widget _buildProfileCard(
      {required IconData icon,
      required String title,
      required List<Widget> children}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: const Color.fromRGBO(9, 132, 85, 0.8)),
                const SizedBox(width: 8),
                Text(title,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const Divider(height: 20),
            ...children,
          ],
        ),
      ),
    );
  }

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
