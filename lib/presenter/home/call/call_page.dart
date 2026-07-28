import 'package:flutter/material.dart';
import 'package:gina/presenter/guardian/store/guardian_controller.dart';
import 'package:gina/responsiveness/gi_font_style.dart';
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
    final guardianController = context.read<GuardianController>();
    homeController.stopEmergency();
    guardianController.setEmergencyActivated(false);
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
            child:
                controller.remoteVideoTrack != null
                    ? VideoTrackRenderer(
                      controller.remoteVideoTrack!,
                      fit: VideoViewFit.cover,
                    )
                    : Center(
                      child: Image.asset(
                        BasAppAssets.attendant,
                        fit: BoxFit.fitHeight,
                      ),
                    ),
          ),

          // 2. MINIATURA NO CANTO: Câmera Local (O rosto do usuário no Android)
          if (controller.remoteVideoTrack == null)
            Positioned(
              bottom: Responsive.getSize(200),
              left: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: black.withValues(alpha: 0.2),
                ),

                padding: EdgeInsets.all(Responsive.getSize(10)),
                margin: EdgeInsets.symmetric(
                  horizontal: Responsive.getSize(16),
                ),
                child: Text(
                  "Aguardando conexão com o atendente...",
                  style: BasFontStyle.bodyLargeBoldSec.copyWith(
                    color: secondaryColor,
                  ),
                ),
              ),
            ),
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
                  FloatingActionButton(
                    backgroundColor: Colors.red,
                    onPressed: () async => await _endCall(controller),
                    child: const Icon(Icons.call_end, color: Colors.white),
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
