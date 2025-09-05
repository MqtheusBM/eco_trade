import 'package:eco_trade/core/models/lote.dart';
import 'package:eco_trade/core/models/scheduling_creation.dart';
import 'package:eco_trade/core/models/user.dart';
import 'package:eco_trade/core/models/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

/// Uma tela que mostra os detalhes de um lote específico.
/// Se o utilizador logado for um Produtor, a tela também exibirá um botão
/// para propor um agendamento de recolha.
class LotDetailsScreen extends ConsumerStatefulWidget {
  final LoteResumido lote; // Agora recebemos o objeto LoteResumido completo.

  const LotDetailsScreen({
    super.key,
    required this.lote,
  });

  @override
  ConsumerState<LotDetailsScreen> createState() => _LotDetailsScreenState();
}

class _LotDetailsScreenState extends ConsumerState<LotDetailsScreen> {
  bool _isScheduling = false;

  /// Mostra um diálogo com DatePicker e, em seguida, um TimePicker.
  Future<void> _showSchedulingDialog(BuildContext context) async {
    final DateTime now = DateTime.now();

    // Mostra o seletor de data, restringindo a data máxima.
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: now.isBefore(widget.lote.limitDate)
          ? now.add(const Duration(days: 1))
          : widget.lote.limitDate,
      firstDate: now,
      // O utilizador não pode selecionar uma data posterior à data limite do lote.
      lastDate: widget.lote.limitDate,
    );

    if (selectedDate == null || !mounted)
      return; // Utilizador cancelou o DatePicker.

    // Mostra o seletor de hora.
    final TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(now.add(const Duration(hours: 1))),
    );

    if (selectedTime == null || !mounted)
      return; // Utilizador cancelou o TimePicker.

    // Combina a data e a hora selecionadas.
    final fullDateTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime.hour,
      selectedTime.minute,
    );

    // Chama a função que efetivamente contacta a API.
    _createSchedule(fullDateTime);
  }

  /// Chama a API para criar o agendamento.
  Future<void> _createSchedule(DateTime scheduledDate) async {
    setState(() => _isScheduling = true);

    try {
      final request = SchedulingRequest(
          loteId: widget.lote.id, scheduledDate: scheduledDate);
      final response =
          await ref.read(apiServiceProvider).createScheduling(request);

      if (mounted) {
        // Atualiza a lista de agendamentos no painel do produtor em segundo plano
        // para que a nova proposta apareça quando ele voltar.
        ref.refresh(producerSchedulingsProvider(null));

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Agendamento proposto com sucesso para ${DateFormat('dd/MM/yy HH:mm').format(response.scheduledDate)}!'),
            backgroundColor: const Color.fromRGBO(9, 132, 85, 0.8),
          ),
        );
        // Fecha a tela de detalhes após o sucesso.
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Erro ao agendar: $e'),
              backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isScheduling = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Verifica o perfil do utilizador logado para decidir se mostra o botão.
    final currentUser = ref.watch(authStateProvider).value;
    final formattedLimitDate =
        DateFormat('dd/MM/yyyy').format(widget.lote.limitDate);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do Lote'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  widget.lote.imageUrl,
                  height: 250,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                      height: 250,
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.broken_image,
                          size: 80, color: Colors.grey)),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                widget.lote.description,
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children: [
                  Chip(
                      label: Text('Status: ${widget.lote.status}'),
                      backgroundColor: Colors.blue.shade100),
                  Chip(
                      label: Text('Distância: ${widget.lote.distance}'),
                      backgroundColor: Colors.orange.shade100),
                ],
              ),
              const Divider(height: 32),
              const Text('Informações Adicionais',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('Peso Aproximado: 50 Kg (Simulado)'),
              const SizedBox(height: 4),
              Text(
                'Data Limite para Recolha: $formattedLimitDate',
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.red),
              ),
            ],
          ),
        ),
      ),
      // Mostra a barra de navegação inferior com o botão APENAS se o utilizador for um produtor.
      bottomNavigationBar: (currentUser?.profileType == ProfileType.produtor)
          ? Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton.icon(
                onPressed:
                    _isScheduling ? null : () => _showSchedulingDialog(context),
                icon: _isScheduling
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.calendar_today),
                label: Text(_isScheduling
                    ? 'A AGENDAR...'
                    : 'PROPOR AGENDAMENTO DE COLETA'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            )
          : null,
    );
  }
}
