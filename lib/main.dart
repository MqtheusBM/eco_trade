import 'package:eco_trade/core/models/auth/auth_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// O ponto de entrada principal da aplicação.
void main() {
  // É uma boa prática garantir que os "bindings" do Flutter estão inicializados
  // antes de a aplicação correr, especialmente com projetos que usam plugins
  // e funcionalidades nativas. Isto resolve muitos erros subtis de inicialização.
  WidgetsFlutterBinding.ensureInitialized();

  // O ProviderScope envolve toda a aplicação, permitindo que qualquer widget
  // aceda aos nossos provedores de estado (Riverpod).
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

/// O widget raiz da sua aplicação.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Eco Trade',
      // Um tema moderno e consistente usando o design Material 3.
      theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white, // Cor do texto e ícones na AppBar
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
          ),
          chipTheme: ChipThemeData(
            selectedColor: Colors.green.shade600,
            labelStyle: const TextStyle(color: Colors.black87),
            secondaryLabelStyle: const TextStyle(color: Colors.white),
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
          )),
      debugShowCheckedModeBanner: false,
      // O AuthWrapper é a nossa "porta de entrada" que decide se mostra o login
      // ou a tela principal com base no estado de autenticação.
      home: const AuthWrapper(),
    );
  }
}
