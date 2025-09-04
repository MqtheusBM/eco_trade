// Este é um teste básico de widgets do Flutter.

import 'package:eco_trade/core/api/api_service.dart';
//import 'package:eco_trade/core/api/mock_api_service.dart';
//import 'package:eco_trade/core/models/user.dart';
import 'package:eco_trade/core/models/providers.dart';
import 'package:eco_trade/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';

// Classe "Dummy" para a nossa API falsa de teste.
// Isto é mais limpo do que usar o MockApiService completo.
class FakeApiService implements ApiService {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  // Garante que o ambiente de teste para plugins nativos está pronto.
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('A aplicação arranca e mostra o ecrã inicial de login', (WidgetTester tester) async {
    // Passo 1: Construir a nossa aplicação com um ambiente de teste totalmente controlado.
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          // Override 1: Forçamos o estado de autenticação para "deslogado".
          // Esta é a substituição mais importante. Dizemos diretamente ao Riverpod
          // que o utilizador é 'null', sem depender do AuthService.
          authStateProvider.overrideWith((_) => Stream.value(null)),

          // Override 2 (Salvaguarda): Substituímos o ApiService por uma versão
          // completamente vazia para garantir que nenhuma chamada de rede é feita.
          apiServiceProvider.overrideWithValue(FakeApiService()),

          // Override 3 (Salvaguarda): Substituímos o locationProvider para evitar
          // qualquer tentativa de aceder ao GPS.
          locationProvider.overrideWith(
            (_) async => Position(
              latitude: 0, longitude: 0, timestamp: DateTime.now(),
              accuracy: 0, altitude: 0, altitudeAccuracy: 0, heading: 0,
              headingAccuracy: 0, speed: 0, speedAccuracy: 0,
            ),
          ),
        ],
        // O erro aqui deve agora desaparecer de vez.
        child: const MyApp(),
      ),
    );

    // Passo 2: Esperar que a UI se estabilize.
    // Este comando garante que todas as operações iniciais terminem.
    await tester.pumpAndSettle();

    // Passo 3: Verificar se a aplicação está no estado esperado.
    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.text('Bem-vindo ao EcoTrade'), findsOneWidget);
  });
}

