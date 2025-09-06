import 'dart:io';

import 'package:eco_trade/core/models/providers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class LotCreationScreen extends ConsumerStatefulWidget {
  const LotCreationScreen({super.key});

  @override
  ConsumerState<LotCreationScreen> createState() => _LotCreationScreenState();
}

class _LotCreationScreenState extends ConsumerState<LotCreationScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Controladores e variáveis de estado do formulário
  final _weightController = TextEditingController();
  DateTime? _selectedDate;
  File? _imageFile;
  LatLng _selectedLocation =
      const LatLng(2.8235, -60.6758); // Localização inicial

  @override
  void dispose() {
    _weightController.dispose();
    super.dispose();
  }

  /// Mostra um diálogo para escolher entre a câmara ou a galeria.
  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galeria de Fotos'),
              onTap: () {
                _pickImage(ImageSource.gallery);
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Câmara'),
              onTap: () {
                _pickImage(ImageSource.camera);
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Lida com a seleção da imagem.
  Future<void> _pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 800,
        imageQuality: 70,
      );
      if (pickedFile != null) {
        setState(() => _imageFile = File(pickedFile.path));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao selecionar imagem: $e')));
    }
  }

  /// Mostra o seletor de data.
  Future<void> _pickDate() async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 90)),
    );
    if (pickedDate != null) {
      setState(() => _selectedDate = pickedDate);
    }
  }

  /// Valida e submete o formulário.
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Por favor, adicione uma foto do lote.')));
      return;
    }
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Por favor, selecione uma data limite.')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final newLote = await ref.read(apiServiceProvider).createLote(
            imagePath: _imageFile!.path,
            weight: num.parse(_weightController.text),
            limitDate: _selectedDate!,
            latitude: _selectedLocation.latitude,
            longitude: _selectedLocation.longitude,
          );

      // Atualiza a lista no painel para que o novo lote apareça.
      ref.invalidate(meusLotesProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Lote "${newLote.descriptionAI}" criado com sucesso!'),
              backgroundColor: const Color.fromRGBO(9, 132, 85, 0.8)),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Erro ao criar lote: $e'),
            backgroundColor: Colors.red));
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
      appBar: AppBar(title: const Text('Cadastrar Novo Lote')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Seletor de Imagem
              GestureDetector(
                onTap: _showImageSourceDialog,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade400),
                  ),
                  child: _imageFile != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(_imageFile!, fit: BoxFit.cover))
                      : const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.camera_alt,
                                size: 50, color: Colors.grey),
                            SizedBox(height: 8),
                            Text('Adicionar Foto do Lote',
                                style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 20),
              // Campo de Peso
              TextFormField(
                controller: _weightController,
                decoration: const InputDecoration(
                    labelText: 'Peso Estimado (Kg)',
                    border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                validator: (value) => (value == null || value.isEmpty)
                    ? 'Campo obrigatório'
                    : null,
              ),
              const SizedBox(height: 20),
              // Seletor de Data
              OutlinedButton.icon(
                onPressed: _pickDate,
                icon: const Icon(Icons.calendar_today),
                label: Text(_selectedDate == null
                    ? 'Selecionar Data Limite'
                    : DateFormat('dd/MM/yyyy').format(_selectedDate!)),
                style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16)),
              ),
              const SizedBox(height: 20),
              // Mapa
              const Text('Marque a localização do lote:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Container(
                height: 250,
                clipBehavior: Clip.antiAlias,
                decoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(12)),
                child: GoogleMap(
                  gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                    Factory<EagerGestureRecognizer>(
                      () => EagerGestureRecognizer(),
                    ),
                  },
                  initialCameraPosition:
                      CameraPosition(target: _selectedLocation, zoom: 14),
                  markers: {
                    Marker(
                      markerId: const MarkerId('selected-location'),
                      position: _selectedLocation,
                      draggable: true,
                      onDragEnd: (newPosition) =>
                          setState(() => _selectedLocation = newPosition),
                    )
                  },
                  onTap: (newPosition) =>
                      setState(() => _selectedLocation = newPosition),
                ),
              ),
              const SizedBox(height: 24),
              // Botão de Submissão
              ElevatedButton(
                onPressed: _isLoading ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16)),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Publicar Lote'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
