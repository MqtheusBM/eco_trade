import 'package:eco_trade/core/models/lote.dart' show Localizacao;
import 'package:eco_trade/core/models/user.dart';
import 'package:eco_trade/core/models/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  ProfileType _selectedProfile = ProfileType.comercio;
  // REMOVIDO: A variável local `_isLoading` já não é necessária.
  // bool _isLoading = false;

  // Controladores de texto (sem alterações)
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _legalNameController = TextEditingController();
  final _taxIdController = TextEditingController();
  final _streetController = TextEditingController();
  final _numberController = TextEditingController();
  final _neighborhoodController = TextEditingController();
  final _cityController = TextEditingController(text: 'Boa Vista');
  final _stateController = TextEditingController(text: 'RR');
  final _zipCodeController = TextEditingController();
  LatLng _selectedLocation = const LatLng(2.8235, -60.6758);
  final _capacityController = TextEditingController();
  final _wasteTypesController = TextEditingController();

  @override
  void dispose() {
    // ... dispose de todos os controladores ...
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _legalNameController.dispose();
    _taxIdController.dispose();
    _streetController.dispose();
    _numberController.dispose();
    _neighborhoodController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipCodeController.dispose();
    _capacityController.dispose();
    _wasteTypesController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    // ALTERADO: Em vez de `setState`, agora atualizamos o provedor.
    ref.read(authLoadingProvider.notifier).state = true;

    try {
      if (_selectedProfile == ProfileType.comercio) {
        final address = Address(
            street: _streetController.text,
            number: _numberController.text,
            neighborhood: _neighborhoodController.text,
            city: _cityController.text,
            state: _stateController.text,
            zipCode: _zipCodeController.text);
        final location = Localizacao(
            latitude: _selectedLocation.latitude,
            longitude: _selectedLocation.longitude);
        await ref.read(authServiceProvider).signUpComercio(
            email: _emailController.text,
            password: _passwordController.text,
            name: _nameController.text,
            phoneNumber: _phoneController.text,
            taxId: _taxIdController.text,
            legalName: _legalNameController.text,
            address: address,
            location: location);
      } else {
        await ref.read(authServiceProvider).signUpProdutor(
            email: _emailController.text,
            password: _passwordController.text,
            name: _nameController.text,
            phoneNumber: _phoneController.text,
            collectionCapacity: int.tryParse(_capacityController.text) ?? 0,
            wasteTypes: _wasteTypesController.text
                .split(',')
                .map((e) => e.trim())
                .toList());
      }
    } catch (e, stackTrace) {
      if (mounted) {
        debugPrint('Erro detalhado ao registar: $e');
        debugPrint(stackTrace.toString());
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Ocorreu um erro inesperado: $e')));
      }
    } finally {
      // ALTERADO: Atualizamos o provedor no bloco `finally`.
      // A verificação `mounted` já não é estritamente necessária aqui, mas é uma boa prática.
      if (mounted) {
        ref.read(authLoadingProvider.notifier).state = false;
      }
    }
  }

  // Métodos _build... (sem alterações)
  List<Widget> _buildCommonFields() {
    return [
      TextFormField(
          controller: _emailController,
          decoration: const InputDecoration(
              labelText: 'Email', border: OutlineInputBorder()),
          keyboardType: TextInputType.emailAddress,
          validator: (value) =>
              (value?.isEmpty ?? true) ? 'Campo obrigatório' : null),
      const SizedBox(height: 12),
      TextFormField(
          controller: _passwordController,
          decoration: const InputDecoration(
              labelText: 'Senha', border: OutlineInputBorder()),
          obscureText: true,
          validator: (value) =>
              (value?.isEmpty ?? true) ? 'Campo obrigatório' : null),
      const SizedBox(height: 12),
      TextFormField(
          controller: _nameController,
          decoration: InputDecoration(
              labelText: _selectedProfile == ProfileType.comercio
                  ? 'Nome Fantasia'
                  : 'Nome Completo',
              border: const OutlineInputBorder()),
          validator: (value) =>
              (value?.isEmpty ?? true) ? 'Campo obrigatório' : null),
      const SizedBox(height: 12),
      TextFormField(
          controller: _phoneController,
          decoration: const InputDecoration(
              labelText: 'Telefone', border: OutlineInputBorder()),
          keyboardType: TextInputType.phone,
          validator: (value) =>
              (value?.isEmpty ?? true) ? 'Campo obrigatório' : null),
    ];
  }

  List<Widget> _buildComercioFields() {
    return [
      const SizedBox(height: 16),
      const Divider(),
      const Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: Text('Dados do Comércio',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
      TextFormField(
          controller: _legalNameController,
          decoration: const InputDecoration(
              labelText: 'Razão Social', border: OutlineInputBorder()),
          validator: (value) =>
              (value?.isEmpty ?? true) ? 'Campo obrigatório' : null),
      const SizedBox(height: 12),
      TextFormField(
          controller: _taxIdController,
          decoration: const InputDecoration(
              labelText: 'CNPJ', border: OutlineInputBorder()),
          keyboardType: TextInputType.number,
          validator: (value) =>
              (value?.isEmpty ?? true) ? 'Campo obrigatório' : null),
      const SizedBox(height: 16),
      const Divider(),
      const Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: Text('Endereço',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
      TextFormField(
          controller: _streetController,
          decoration: const InputDecoration(
              labelText: 'Rua/Avenida', border: OutlineInputBorder())),
      const SizedBox(height: 12),
      Row(children: [
        Expanded(
            child: TextFormField(
                controller: _numberController,
                decoration: const InputDecoration(
                    labelText: 'Número', border: OutlineInputBorder()))),
        const SizedBox(width: 12),
        Expanded(
            child: TextFormField(
                controller: _neighborhoodController,
                decoration: const InputDecoration(
                    labelText: 'Bairro', border: OutlineInputBorder())))
      ]),
      const SizedBox(height: 12),
      Row(children: [
        Expanded(
            child: TextFormField(
                controller: _cityController,
                decoration: const InputDecoration(
                    labelText: 'Cidade', border: OutlineInputBorder()))),
        const SizedBox(width: 12),
        SizedBox(
            width: 80,
            child: TextFormField(
                controller: _stateController,
                decoration: const InputDecoration(
                    labelText: 'Estado', border: OutlineInputBorder())))
      ]),
      const SizedBox(height: 12),
      TextFormField(
          controller: _zipCodeController,
          decoration: const InputDecoration(
              labelText: 'CEP', border: OutlineInputBorder())),
      const SizedBox(height: 16),
      const Text('Marque a sua localização no mapa:',
          style: TextStyle(fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      Container(
          height: 250,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade400)),
          child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: GoogleMap(
                  initialCameraPosition:
                      CameraPosition(target: _selectedLocation, zoom: 14),
                  markers: {
                    Marker(
                        markerId: const MarkerId('selected-location'),
                        position: _selectedLocation,
                        draggable: true,
                        onDragEnd: (newPosition) {
                          setState(() => _selectedLocation = newPosition);
                        })
                  },
                  onTap: (newPosition) {
                    setState(() => _selectedLocation = newPosition);
                  }))),
    ];
  }

  List<Widget> _buildProdutorFields() {
    return [
      const SizedBox(height: 12),
      TextFormField(
          controller: _capacityController,
          decoration: const InputDecoration(
              labelText: 'Capacidade de Recolha (Kg)',
              border: OutlineInputBorder()),
          keyboardType: TextInputType.number),
      const SizedBox(height: 12),
      TextFormField(
          controller: _wasteTypesController,
          decoration: const InputDecoration(
              labelText: 'Tipos de Resíduos Aceites',
              helperText: 'Separar por vírgulas (ex: orgânico, plástico)',
              border: OutlineInputBorder())),
    ];
  }

  @override
  Widget build(BuildContext context) {
    // ALTERADO: Agora "ouvimos" o provedor para obter o estado de carregamento.
    final isLoading = ref.watch(authLoadingProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Criar Conta')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SegmentedButton<ProfileType>(
                segments: const [
                  ButtonSegment(
                      value: ProfileType.comercio,
                      label: Text('Comércio'),
                      icon: Icon(Icons.store)),
                  ButtonSegment(
                      value: ProfileType.produtor,
                      label: Text('Produtor'),
                      icon: Icon(Icons.eco)),
                ],
                selected: {_selectedProfile},
                onSelectionChanged: (newSelection) {
                  setState(() => _selectedProfile = newSelection.first);
                },
              ),
              const SizedBox(height: 24),
              ..._buildCommonFields(),
              if (_selectedProfile == ProfileType.comercio)
                ..._buildComercioFields(),
              if (_selectedProfile == ProfileType.produtor)
                ..._buildProdutorFields(),
              const SizedBox(height: 24),
              // ALTERADO: O botão agora usa o `isLoading` do provedor.
              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Registar'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
