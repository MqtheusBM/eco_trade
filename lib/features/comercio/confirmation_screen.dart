import 'package:eco_trade/core/models/scheduling_confirmation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ConfirmationScreen extends StatelessWidget {
  final SchedulingConfirmation confirmation;

  const ConfirmationScreen({super.key, required this.confirmation});

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('dd/MM/yyyy \'às\' HH:mm').format(confirmation.scheduling.scheduledDate);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Remove a seta de "voltar"
        title: const Text('Agendamento Confirmado!'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.check_circle, color: Color.fromRGBO(9, 132, 85, 0.8), size: 80),
            const SizedBox(height: 16),
            const Text(
              'Recolha agendada com sucesso!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            _buildInfoCard(
              title: 'Detalhes da Recolha',
              children: [
                _buildInfoRow('Data Agendada:', formattedDate),
                _buildInfoRow('Produtor:', confirmation.producerConfirmed.name),
                _buildInfoRow('Telefone do Produtor:', confirmation.producerConfirmed.phoneNumber),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoCard(
              title: 'Local da Recolha',
              children: [
                _buildInfoRow('Empresa:', confirmation.collectionData.companyName),
                _buildInfoRow('Endereço:', confirmation.collectionData.fullAddress),
              ],
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                // Fecha esta tela e volta para o painel principal.
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 16),
              ),
              child: const Text('Voltar ao Painel'),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({required String title, required List<Widget> children}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
