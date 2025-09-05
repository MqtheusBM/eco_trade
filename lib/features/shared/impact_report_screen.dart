import 'package:eco_trade/core/models/impact_report.dart';
import 'package:eco_trade/core/models/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class ImpactReportScreen extends ConsumerStatefulWidget {
  const ImpactReportScreen({super.key});

  @override
  ConsumerState<ImpactReportScreen> createState() => _ImpactReportScreenState();
}

class _ImpactReportScreenState extends ConsumerState<ImpactReportScreen> {
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isLoading = false;
  String? _reportResult;
  String? _error;

  Future<void> _pickDate(bool isStartDate) async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(2023),
      lastDate: now,
    );
    if (pickedDate != null) {
      setState(() {
        if (isStartDate) {
          _startDate = pickedDate;
        } else {
          _endDate = pickedDate;
        }
      });
    }
  }

  Future<void> _generateReport() async {
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Por favor, selecione a data de início e de fim.')),
      );
      return;
    }
    if (_startDate!.isAfter(_endDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('A data de início não pode ser posterior à data de fim.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _reportResult = null;
      _error = null;
    });

    try {
      final request =
          ImpactReportRequest(startDate: _startDate!, endDate: _endDate!);
      final response =
          await ref.read(apiServiceProvider).generateImpactReport(request);
      setState(() => _reportResult = response.report);
    } catch (e) {
      setState(() => _error = 'Falha ao gerar o relatório: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat('dd/MM/yyyy');
    return Scaffold(
      appBar: AppBar(title: const Text('Relatório de Impacto')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
                'Selecione o período para gerar o seu relatório de impacto ambiental.',
                textAlign: TextAlign.center),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildDatePickerButton(
                  label: 'Data de Início',
                  date: _startDate,
                  formatter: formatter,
                  onPressed: () => _pickDate(true),
                ),
                _buildDatePickerButton(
                  label: 'Data de Fim',
                  date: _endDate,
                  formatter: formatter,
                  onPressed: () => _pickDate(false),
                ),
              ],
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _generateReport,
                icon: const Icon(Icons.assessment),
                label: const Text('Gerar Relatório'),
                style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16)),
              ),
            ),
            const SizedBox(height: 24),
            const Divider(),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(32.0),
                child: Center(child: CircularProgressIndicator()),
              ),
            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red)),
            if (_reportResult != null)
              Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: MarkdownBody(data: _reportResult!),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePickerButton({
    required String label,
    required DateTime? date,
    required DateFormat formatter,
    required VoidCallback onPressed,
  }) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        OutlinedButton(
          onPressed: onPressed,
          child: Text(date == null ? 'Selecionar' : formatter.format(date)),
        ),
      ],
    );
  }
}
