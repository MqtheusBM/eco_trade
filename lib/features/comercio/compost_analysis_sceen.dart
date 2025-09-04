import 'package:eco_trade/core/models/compost_analysis.dart';
import 'package:eco_trade/core/models/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CompostAnalysisScreen extends ConsumerStatefulWidget {
  final String loteId;
  final String loteDescription;

  const CompostAnalysisScreen({
    super.key,
    required this.loteId,
    required this.loteDescription,
  });

  @override
  ConsumerState<CompostAnalysisScreen> createState() => _CompostAnalysisScreenState();
}

class _CompostAnalysisScreenState extends ConsumerState<CompostAnalysisScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Estado do formulário
  String _selectedMethod = 'windrow';
  String _selectedGoal = 'accelerate_decomposition';
  final Set<String> _selectedMaterials = {'dry_leaves'};
  final _observationsController = TextEditingController();

  // Opções para os menus (Estas são as variáveis que estamos a usar)
  final Map<String, String> _methodOptions = {
    'windrow': 'Leira (Windrow)',
    'static_pile': 'Pilha Estática (Static Pile)',
    'in_vessel': 'Em Recipiente (In-vessel)',
  };

  final Map<String, String> _goalOptions = {
    'accelerate_decomposition': 'Acelerar Decomposição',
    'improve_quality': 'Melhorar Qualidade',
    'reduce_odor': 'Reduzir Odor',
  };

  final Map<String, String> _carbonMaterialOptions = {
    'sawdust': 'Serradura',
    'dry_leaves': 'Folhas Secas',
    'shredded_cardboard': 'Papelão Triturado',
    'straw': 'Palha',
  };

  // REMOVED: As 3 listas '_available...' foram removidas pois não eram utilizadas.

  @override
  void dispose() {
    _observationsController.dispose();
    super.dispose();
  }

  Future<void> _submitAnalysis() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);

    final request = CompostAnalysisRequest(
      compostingMethod: _selectedMethod,
      availableCarbonMaterials: _selectedMaterials.toList(),
      goal: _selectedGoal,
      observations: _observationsController.text,
    );

    try {
      final response = await ref.read(apiServiceProvider).analyzeCompost(widget.loteId, request);
      
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Análise Concluída'),
            content: SingleChildScrollView(child: Text(response.recommendations)),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro na análise: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Analisar: ${widget.loteDescription}')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Método de Compostagem'),
              DropdownButtonFormField<String>(
                value: _selectedMethod,
                items: _methodOptions.entries.map((entry) {
                  return DropdownMenuItem(value: entry.key, child: Text(entry.value));
                }).toList(),
                onChanged: (value) => setState(() => _selectedMethod = value!),
                decoration: const InputDecoration(border: OutlineInputBorder()),
              ),
              const SizedBox(height: 20),

              _buildSectionTitle('Objetivo Principal'),
              DropdownButtonFormField<String>(
                value: _selectedGoal,
                items: _goalOptions.entries.map((entry) {
                  return DropdownMenuItem(value: entry.key, child: Text(entry.value));
                }).toList(),
                onChanged: (value) => setState(() => _selectedGoal = value!),
                decoration: const InputDecoration(border: OutlineInputBorder()),
              ),
              const SizedBox(height: 20),

              _buildSectionTitle('Materiais de Carbono Disponíveis'),
              ..._carbonMaterialOptions.entries.map((entry) {
                return CheckboxListTile(
                  title: Text(entry.value),
                  value: _selectedMaterials.contains(entry.key),
                  onChanged: (bool? value) {
                    setState(() {
                      if (value == true) {
                        _selectedMaterials.add(entry.key);
                      } else {
                        _selectedMaterials.remove(entry.key);
                      }
                    });
                  },
                );
              }).toList(),
              const SizedBox(height: 20),

              _buildSectionTitle('Observações'),
              TextFormField(
                controller: _observationsController,
                decoration: const InputDecoration(
                  hintText: 'Descreva o estado atual da sua pilha...',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 4,
                validator: (value) => (value == null || value.isEmpty) ? 'Este campo é obrigatório.' : null,
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _submitAnalysis,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        child: const Text('Obter Recomendações'),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
    );
  }
}

