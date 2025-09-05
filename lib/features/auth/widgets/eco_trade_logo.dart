import 'package:flutter/material.dart';

class EcoTradeLogo extends StatelessWidget {
  final double height;
  const EcoTradeLogo({super.key, this.height = 100});

  @override
  Widget build(BuildContext context) {
    // Este widget carrega e exibe a imagem do logo a partir da pasta de assets.
    return Image.asset(
      'assets/images/logo.png',
      height: height,
    );
  }
}

