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
  bool _isPasswordVisible = false;

  // Controladores de texto
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

  // Estado para os tipos de resíduos do Produtor
  Set<String> _selectedWasteTypes = {};
  bool _otherWasteTypeSelected = false;
  final _otherWasteTypeController = TextEditingController();

  @override
  void dispose() {
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
    _otherWasteTypeController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final List<String> finalWasteTypes = _selectedWasteTypes.toList();
    if (_otherWasteTypeSelected) {
      if (_otherWasteTypeController.text.isNotEmpty) {
        finalWasteTypes.add(_otherWasteTypeController.text.trim());
      }
    }

    if (_selectedProfile == ProfileType.produtor && finalWasteTypes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Por favor, selecione pelo menos um tipo de resíduo.')),
      );
      return;
    }

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
              location: location,
            );
      } else {
        await ref.read(authServiceProvider).signUpProdutor(
              email: _emailController.text,
              password: _passwordController.text,
              name: _nameController.text,
              phoneNumber: _phoneController.text,
              collectionCapacity: int.tryParse(_capacityController.text) ?? 0,
              wasteTypes: finalWasteTypes,
            );
      }
    } catch (e, stackTrace) {
      if (mounted) {
        debugPrint('Erro detalhado ao registar: $e');
        debugPrint(stackTrace.toString());
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Ocorreu um erro inesperado: $e')));
      }
    } finally {
      if (mounted) {
        ref.read(authLoadingProvider.notifier).state = false;
      }
    }
  }

  List<Widget> _buildCommonFields() {
    return [
      TextFormField(
        controller: _emailController,
        decoration: const InputDecoration(
            labelText: 'Email', border: OutlineInputBorder()),
        keyboardType: TextInputType.emailAddress,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Campo obrigatório';
          }
          final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
          if (!emailRegex.hasMatch(value)) {
            return 'Por favor, insira um email válido';
          }
          return null;
        },
      ),
      const SizedBox(height: 12),
      TextFormField(
        controller: _passwordController,
        decoration: InputDecoration(
          labelText: 'Senha',
          border: const OutlineInputBorder(),
          suffixIcon: IconButton(
            icon: Icon(
              _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
            ),
            onPressed: () {
              setState(() {
                _isPasswordVisible = !_isPasswordVisible;
              });
            },
          ),
        ),
        obscureText: !_isPasswordVisible,
        validator: (value) =>
            (value?.isEmpty ?? true) ? 'Campo obrigatório' : null,
      ),
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
              labelText: 'Rua/Avenida', border: OutlineInputBorder()),
          validator: (value) =>
              (value?.isEmpty ?? true) ? 'Campo obrigatório' : null),
      const SizedBox(height: 12),
      Row(children: [
        Expanded(
            child: TextFormField(
                controller: _numberController,
                decoration: const InputDecoration(
                    labelText: 'Número', border: OutlineInputBorder()),
                validator: (value) =>
                    (value?.isEmpty ?? true) ? 'Campo obrigatório' : null)),
        const SizedBox(width: 12),
        Expanded(
            child: TextFormField(
                controller: _neighborhoodController,
                decoration: const InputDecoration(
                    labelText: 'Bairro', border: OutlineInputBorder()),
                validator: (value) =>
                    (value?.isEmpty ?? true) ? 'Campo obrigatório' : null)),
      ]),
      const SizedBox(height: 12),
      Row(children: [
        Expanded(
            child: TextFormField(
                controller: _cityController,
                decoration: const InputDecoration(
                    labelText: 'Cidade', border: OutlineInputBorder()),
                validator: (value) =>
                    (value?.isEmpty ?? true) ? 'Campo obrigatório' : null)),
        const SizedBox(width: 12),
        SizedBox(
            width: 80,
            child: TextFormField(
                controller: _stateController,
                decoration: const InputDecoration(
                    labelText: 'Estado', border: OutlineInputBorder()),
                validator: (value) =>
                    (value?.isEmpty ?? true) ? 'Campo obrigatório' : null)),
      ]),
      const SizedBox(height: 12),
      TextFormField(
          controller: _zipCodeController,
          decoration: const InputDecoration(
              labelText: 'CEP', border: OutlineInputBorder()),
          validator: (value) =>
              (value?.isEmpty ?? true) ? 'Campo obrigatório' : null),
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

  // ATUALIZADO: Lógica de seleção de resíduos movida para um diálogo
  Future<void> _showWasteTypeDialog() async {
    final tempSelectedTypes = Set<String>.from(_selectedWasteTypes);
    bool tempOtherSelected = _otherWasteTypeSelected;
    final tempOtherController =
        TextEditingController(text: _otherWasteTypeController.text);

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Selecione os Tipos de Resíduo'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CheckboxListTile(
                      title: const Text('Orgânico'),
                      value: tempSelectedTypes.contains('orgânico'),
                      onChanged: (bool? value) {
                        setDialogState(() {
                          if (value == true) {
                            tempSelectedTypes.add('orgânico');
                          } else {
                            tempSelectedTypes.remove('orgânico');
                          }
                        });
                      },
                    ),
                    CheckboxListTile(
                      title: const Text('Plástico'),
                      value: tempSelectedTypes.contains('plástico'),
                      onChanged: (bool? value) {
                        setDialogState(() {
                          if (value == true) {
                            tempSelectedTypes.add('plástico');
                          } else {
                            tempSelectedTypes.remove('plástico');
                          }
                        });
                      },
                    ),
                    CheckboxListTile(
                      title: const Text('Outros'),
                      value: tempOtherSelected,
                      onChanged: (bool? value) {
                        setDialogState(() {
                          tempOtherSelected = value ?? false;
                        });
                      },
                    ),
                    if (tempOtherSelected)
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 8.0, left: 16.0, right: 16.0),
                        child: TextFormField(
                          controller: tempOtherController,
                          decoration: const InputDecoration(
                            labelText: 'Especifique o tipo',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Confirmar'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result == true) {
      setState(() {
        _selectedWasteTypes = tempSelectedTypes;
        _otherWasteTypeSelected = tempOtherSelected;
        _otherWasteTypeController.text = tempOtherController.text;
        if (!_otherWasteTypeSelected) {
          _otherWasteTypeController.clear();
        }
      });
    }
  }

  String _buildSelectedTypesText() {
    if (_selectedWasteTypes.isEmpty && !_otherWasteTypeSelected) {
      return 'Nenhum selecionado';
    }
    final displayTypes = _selectedWasteTypes.toList();
    if (_otherWasteTypeSelected) {
      final otherText = _otherWasteTypeController.text.trim();
      displayTypes.add(otherText.isNotEmpty ? otherText : 'Outros');
    }
    return displayTypes.join(', ');
  }

  List<Widget> _buildProdutorFields() {
    return [
      const SizedBox(height: 12),
      TextFormField(
          controller: _capacityController,
          decoration: const InputDecoration(
              labelText: 'Capacidade de Recolha (Kg)',
              border: OutlineInputBorder()),
          keyboardType: TextInputType.number,
          validator: (value) =>
              (value?.isEmpty ?? true) ? 'Campo obrigatório' : null),
      const SizedBox(height: 16),
      const Divider(),
      // ATUALIZADO: Campo de seleção que abre o diálogo
      InkWell(
        onTap: _showWasteTypeDialog,
        child: InputDecorator(
          decoration: const InputDecoration(
            labelText: 'Tipos de Resíduos Aceitos',
            border: OutlineInputBorder(),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                  child: Text(_buildSelectedTypesText(),
                      overflow: TextOverflow.ellipsis)),
              const Icon(Icons.arrow_drop_down),
            ],
          ),
        ),
      ),
      // Mostra o campo de texto de "Outros" diretamente na tela se a opção
      // estiver selecionada, para facilitar a edição.
      if (_otherWasteTypeSelected)
        Padding(
          padding: const EdgeInsets.only(top: 12.0),
          child: TextFormField(
            controller: _otherWasteTypeController,
            decoration: const InputDecoration(
              labelText: 'Especifique qual o "Outro" tipo',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (_otherWasteTypeSelected && (value == null || value.isEmpty)) {
                return 'Por favor, especifique o tipo';
              }
              return null;
            },
          ),
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
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
