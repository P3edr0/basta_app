import 'dart:ui';

import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:gina/components/buttons/rounded_button.dart';
import 'package:gina/responsiveness/responsive.dart';
import 'package:gina/theme/colors.dart';
import 'package:gina/utils/assets/app_assets.dart';
import 'package:gina/utils/routes/app_routes.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:provider/provider.dart';

import '../../../components/dialogs/info_dialog.dart';
import '../../../utils/routes/app_navigator.dart';
import '../home/store/home_controller.dart';
import 'store/call_controller.dart';

class CallPage extends StatefulWidget {
  const CallPage({super.key});

  @override
  State<CallPage> createState() => _CallPageState();
}

class _CallPageState extends State<CallPage> {
  final navigator = AppNavigator();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final controller = context.read<CallController>();
      await controller.startRingtone();
      final successOnStartCall = await controller.startCall();
      if (!successOnStartCall) {
        InfoDialog.show("Atenção", controller.exception!, context);

        await Future.delayed(Duration(seconds: 5));
        await _endCall(controller);
      }
    });
  }

  Future<void> _endCall(CallController controller) async {
    final homeController = context.read<HomeController>();
    homeController.stopEmergency();
    await controller.finishCall();
    navigator.goto(BasRoutes.home, clearStack: true);
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<CallController>(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. TELA CHEIA: Vídeo Remoto (O Robô de IA ou o Atendente da Central)
          Positioned.fill(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 800),
              switchInCurve: Curves.easeInCubic,
              switchOutCurve: Curves.easeOutCubic,
              child:
                  controller.remoteVideoTrack != null
                      ? VideoTrackRenderer(
                        controller.remoteVideoTrack!,
                        fit: VideoViewFit.cover,
                        mirrorMode:
                            controller.isFrontCamera
                                ? VideoViewMirrorMode.mirror
                                : VideoViewMirrorMode.off,
                      )
                      : BackdropFilter(
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
                                    backgroundImage: AssetImage(
                                      BasAppAssets.attendantAvatar,
                                    ),
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
                      ),
            ),
          ),

          // 2. MINIATURA NO CANTO: Câmera Local (O rosto do usuário no Android)
          // if (controller.remoteVideoTrack == null)
          //   Positioned(
          //     bottom: Responsive.getSize(200),
          //     left: 0,
          //     right: 0,
          //     child: Container(
          //       decoration: BoxDecoration(
          //         borderRadius: BorderRadius.circular(16),
          //         color: black.withValues(alpha: 0.2),
          //       ),

          //       padding: EdgeInsets.all(Responsive.getSize(10)),
          //       margin: EdgeInsets.symmetric(
          //         horizontal: Responsive.getSize(16),
          //       ),
          //       child: Text(
          //         "Aguardando conexão com o atendente...",
          //         style: BasFontStyle.bodyLargeBoldSec.copyWith(
          //           color: secondaryColor,
          //         ),
          //       ),
          //     ),
          //   ),
          if (controller.localVideoTrack != null)
            Positioned(
              top: Responsive.getSize(60),
              right: Responsive.getSize(20),
              width: Responsive.getSize(120),
              height: Responsive.getSize(180),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: VideoTrackRenderer(
                  controller.localVideoTrack!,
                  fit: VideoViewFit.cover,
                ),
              ),
            ),

          // 3. BOTÕES DE CONTROLE (Desligar, Mutar)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                top: Responsive.getSize(20),
                bottom: Responsive.getSize(20),
              ),
              decoration: BoxDecoration(color: black.withValues(alpha: 0.2)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  BasRoundedButton.solid(
                    radius: 16,
                    height: Responsive.getSize(65),
                    color: blue,
                    onTap:
                        () async => await controller.changeMicrophoneStatus(),
                    child: Icon(
                      controller.isMuted ? Icons.mic_off : Icons.mic_none,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: Responsive.getSize(30)),
                  BasRoundedButton.solid(
                    radius: 16,
                    height: Responsive.getSize(80),
                    color: alertColor,
                    onTap: () async => await _endCall(controller),
                    child: const Icon(
                      Icons.call_end_outlined,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: Responsive.getSize(30)),

                  BasRoundedButton.solid(
                    radius: 16,
                    height: Responsive.getSize(65),
                    color: success,
                    onTap: () async => await controller.switchCamera(),
                    child: const Icon(
                      Icons.flip_camera_ios_outlined,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
