import 'dart:ui'; // Necessário para o ImageFilter (Blur)

import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:gina/theme/colors.dart';
import 'package:gina/utils/assets/app_assets.dart';

class CallTestPage extends StatefulWidget {
  const CallTestPage({super.key});

  @override
  State<CallTestPage> createState() => _CallTestPageState();
}

class _CallTestPageState extends State<CallTestPage> {
  // VARIÁVEL DE ESTADO PARA O TESTE
  // false = Mostra o Loading de Conexão
  // true  = Simula que a Atendente entrou (Vídeo Remoto)
  bool _isAttendantConnected = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: secondaryColor,
      // Usamos Stack para sobrepor o vídeo e o loading
      body: Stack(
        children: [
          // ---------------------------------------------------------
          // CAMADA 1 (Fundo): O conteúdo da chamada de vídeo
          // ---------------------------------------------------------
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 800), // Transição suave
            switchInCurve: Curves.easeInCubic,
            switchOutCurve: Curves.easeOutCubic,
            child:
                _isAttendantConnected
                    ? _buildRemoteVideoView() // Simula Atendente em Tela Cheia
                    : _buildLocalCameraPreview(), // Simula prévia da câmera local
          ),

          // ---------------------------------------------------------
          // CAMADA 2 (Overlay): O Widget de Loading de Pré-Conexão
          // ---------------------------------------------------------
          // Usamos AnimatedOpacity para esconder o loading suavemente
          // quando a atendente conectar.
          IgnorePointer(
            ignoring:
                _isAttendantConnected, // Permite tocar no vídeo atrás quando conectado
            child: AnimatedOpacity(
              opacity: _isAttendantConnected ? 0.0 : 1.0,
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeInOut,
              child: _buildConnectingOverlay(),
            ),
          ),

          // ---------------------------------------------------------
          // Botão de Voltar (Sempre visível)
          // ---------------------------------------------------------
          Positioned(
            top: 50,
            left: 20,
            child: CircleAvatar(
              backgroundColor: Colors.black38,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ),
        ],
      ),

      // ---------------------------------------------------------
      // BOTÃO FLUTUANTE DE TESTE (Para alternar o estado)
      // ---------------------------------------------------------
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: _isAttendantConnected ? Colors.red : Colors.green,
        onPressed: () {
          setState(() {
            _isAttendantConnected = !_isAttendantConnected;
          });
        },
        label: Text(
          _isAttendantConnected
              ? 'Simular Desconexão'
              : 'Simular Atendente Entrando',
        ),
        icon: Icon(_isAttendantConnected ? Icons.videocam_off : Icons.videocam),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  // ==========================================================================
  // WIDGETS AUXILIARES (CONSTRUÇÃO DA INTERFACE)
  // ==========================================================================

  // 1. O Overlay de Carregamento (Blur + Animação + Texto)
  Widget _buildConnectingOverlay() {
    return BackdropFilter(
      // Aplica o desfoque no que está atrás (Câmera Local)
      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
      child: Container(
        color: blue, // Fundo escuro semi-transparente
        width: double.infinity,
        height: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animação de pulso branca e suave
            AvatarGlow(
              glowColor: secondaryColor,
              glowRadiusFactor: 1.0,
              duration: const Duration(milliseconds: 2000),
              repeat: true,
              child: Material(
                elevation: 0,
                shape: const CircleBorder(),
                color: Colors.transparent,
                child: CircleAvatar(
                  backgroundImage: AssetImage(BasAppAssets.attendantAvatar),
                  radius: 80.0,
                ),
              ),
            ),
            const SizedBox(height: 30),
            // Texto Principal
            const Text(
              "Conectando com a atendente...",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 10),
            // Texto de Apoio (Traz calma)
            const Text(
              "Sua chamada está sendo iniciada.\nAguarde só alguns instantes na tela.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 15,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 2. Simulação da Prévia da Câmera Local do Usuário (Background)
  Widget _buildLocalCameraPreview() {
    return Container(
      key: const ValueKey('local_camera'),
      width: double.infinity,
      height: double.infinity,
      color: Colors.grey[900], // Fundo escuro caso não tenha imagem
      child: Stack(
        fit: StackFit.expand,
        children: [
          // SIMULAÇÃO: Coloque aqui uma imagem que lembre uma câmera local
          // ou deixe apenas a cor.
          Image.network(
            'https://images.unsplash.com/photo-1521575107034-e0ae0af5c677?q=80&w=600', // Exemplo de rosto
            fit: BoxFit.cover,
            errorBuilder: (c, e, s) => Container(color: Colors.grey[800]),
          ),
          // Gradient leve na borda para dar acabamento
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.black26, Colors.transparent, Colors.black45],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 3. Simulação do Vídeo da Atendente em Tela Cheia (Quando conecta)
  Widget _buildRemoteVideoView() {
    return Container(
      key: const ValueKey('remote_video'),
      width: double.infinity,
      height: double.infinity,
      color: Colors.blueGrey[900],
      child: Stack(
        fit: StackFit.expand,
        children: [
          // SIMULAÇÃO: Imagem que representa a atendente em vídeo
          Image.network(
            'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?q=80&w=800', // Exemplo de atendente
            fit: BoxFit.cover,
            errorBuilder: (c, e, s) => Container(color: Colors.blueGrey[700]),
          ),
          // Label identificando que é o vídeo remoto
          Positioned(
            bottom: 100,
            left: 20,
            child: Container(
              padding: const EdgeInsets.all(8),
              color: Colors.black54,
              child: const Text(
                "ATENDENTE (LIVE)",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
