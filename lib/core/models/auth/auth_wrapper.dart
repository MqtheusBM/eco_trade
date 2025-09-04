import 'package:eco_trade/core/models/user.dart';
import 'package:eco_trade/core/models/providers.dart';
import 'package:eco_trade/features/auth/login_screen.dart';
import 'package:eco_trade/features/comercio/comercio_dashboard_screen.dart';
import 'package:eco_trade/features/producer/producer_dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Este widget funciona como o "porteiro" da aplicação.
/// Ele "ouve" o estado de autenticação e decide qual tela mostrar:
/// - Se ninguém estiver logado, mostra a [LoginScreen].
/// - Se um utilizador estiver logado, verifica o seu perfil e mostra
///   a tela apropriada ([ProducerDashboardScreen] para Produtor, [ComercioDashboardScreen] para Comércio).
class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Observamos o provedor de estado de autenticação.
    // O widget será reconstruído sempre que este estado mudar (login/logout).
    final authState = ref.watch(authStateProvider);

    return authState.when(
      // Estado de sucesso: recebemos um utilizador (ou null).
      data: (user) {
        if (user == null) {
          // Nenhum utilizador logado, mostrar a tela de login.
          return const LoginScreen();
        } else {
          // Utilizador logado, verificar o seu perfil.
          if (user.profileType == ProfileType.produtor) {
            // Produtor é direcionado para o seu novo painel com abas.
            return const ProducerDashboardScreen();
          } else {
            // Qualquer outro perfil (neste caso, Comércio) vê o seu painel.
            return const ComercioDashboardScreen();
          }
        }
      },
      // Estado de carregamento: a aguardar o primeiro estado do stream.
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      // Estado de erro: algo correu mal no stream de autenticação.
      error: (err, stack) => Scaffold(
        body: Center(child: Text('Ocorreu um erro: $err')),
      ),
    );
  }
}

