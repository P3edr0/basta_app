import 'package:flutter/material.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:provider/provider.dart';

import '../../../utils/routes/app_navigator.dart';
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
      controller.startCall();
    });
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
                    ? VideoTrackRenderer(controller.remoteVideoTrack!)
                    : const Center(
                      child: Text(
                        "Aguardando conexão com o assistente...",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
          ),

          // 2. MINIATURA NO CANTO: Câmera Local (O rosto do usuário no Android)
          if (controller.localVideoTrack != null)
            Positioned(
              top: 40,
              right: 20,
              width: 120,
              height: 160,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: VideoTrackRenderer(controller.localVideoTrack!),
              ),
            ),

          // 3. BOTÕES DE CONTROLE (Desligar, Mutar)
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FloatingActionButton(
                  backgroundColor: Colors.red,
                  onPressed: () async {
                    await controller.finishCall();
                    Navigator.pop(context);
                  },
                  child: const Icon(Icons.call_end, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
