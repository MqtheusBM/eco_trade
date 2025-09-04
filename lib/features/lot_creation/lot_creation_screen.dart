import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:eco_trade/core/models/providers.dart';

class LotCreationScreen extends ConsumerStatefulWidget {
  const LotCreationScreen({super.key});

  @override
  ConsumerState<LotCreationScreen> createState() => _LotCreationScreenState();
}

class _LotCreationScreenState extends ConsumerState<LotCreationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _weightController = TextEditingController();

  // Estado local para os dados do formulário
  XFile? _imageFile;
  DateTime? _selectedDate;
  LatLng? _selectedLocation;
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _imageFile = pickedFile;
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _submitForm() async {
    if (_isLoading) return;

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor, selecione uma imagem.')));
      return;
    }
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Por favor, selecione uma data limite.')));
      return;
    }
    if (_selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Por favor, marque a localização no mapa.')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final apiService = ref.read(apiServiceProvider);
      await apiService.createLote(
        imagePath: _imageFile!.path,
        weight: num.parse(_weightController.text),
        limitDate: _selectedDate!,
        latitude: _selectedLocation!.latitude,
        longitude: _selectedLocation!.longitude,
      );

      // Invalida o provider para forçar a atualização da lista na tela principal
      ref.invalidate(lotesProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Lote criado com sucesso!')));
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Erro ao criar lote: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cadastrar Novo Lote')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Seletor de Imagem
              _buildImagePicker(),
              const SizedBox(height: 24),
              // Campo de Peso
              TextFormField(
                controller: _weightController,
                decoration: const InputDecoration(
                  labelText: 'Peso (Kg)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'Campo obrigatório.';
                  if (num.tryParse(value) == null)
                    return 'Por favor, insira um número válido.';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              // Seletor de Data
              _buildDatePicker(),
              const SizedBox(height: 24),
              // Seletor de Localização (Mapa)
              _buildMapPicker(),
              const SizedBox(height: 32),
              // Botão de Envio
              ElevatedButton(
                onPressed: _submitForm,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Cadastrar Lote'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return Column(
      children: [
        Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: _imageFile != null
              ? Image.file(File(_imageFile!.path), fit: BoxFit.cover)
              : const Center(child: Text('Nenhuma imagem selecionada.')),
        ),
        TextButton.icon(
          icon: const Icon(Icons.image),
          label: const Text('Selecionar Foto da Galeria'),
          onPressed: _pickImage,
        ),
      ],
    );
  }

  Widget _buildDatePicker() {
    return Row(
      children: [
        Expanded(
          child: Text(
            _selectedDate == null
                ? 'Nenhuma data limite selecionada'
                : 'Data Limite: ${DateFormat('dd/MM/yyyy').format(_selectedDate!)}',
          ),
        ),
        TextButton(
          onPressed: () => _selectDate(context),
          child: const Text('Escolher'),
        )
      ],
    );
  }

  Widget _buildMapPicker() {
    // AVISO: A API Key do Google Maps precisa ser configurada no seu projeto Android/iOS.
    // Android: android/app/src/main/AndroidManifest.xml
    // iOS: ios/Runner/AppDelegate.swift
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Marque o local de coleta no mapa:',
            style: TextStyle(fontSize: 16)),
        const SizedBox(height: 8),
        Container(
          height: 300,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: GoogleMap(
              initialCameraPosition: const CameraPosition(
                // Posição inicial do mapa (Boa Vista, RR)
                target: LatLng(2.8235, -60.6758),
                zoom: 12,
              ),
              markers: _selectedLocation == null
                  ? {}
                  : {
                      Marker(
                          markerId: const MarkerId('lote_location'),
                          position: _selectedLocation!)
                    },
              onTap: (location) {
                setState(() {
                  _selectedLocation = location;
                });
              },
            ),
          ),
        ),
      ],
    );
  }
}
