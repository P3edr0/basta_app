import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gina/domain/entities/call_data_entity.dart';
import 'package:livekit_client/livekit_client.dart';

class CallController extends ChangeNotifier {
  Room? room;
  bool _estaConectado = false;
  bool get estaConectado => _estaConectado;
  CallDataEntity? call;

  // Transmissões de vídeo locais (usuário) e remotas (robô/atendente)
  VideoTrack? localVideoTrack;
  VideoTrack? remoteVideoTrack;

  void setCall(CallDataEntity newCall) {
    call = newCall;
    notifyListeners();
  }

  Future<bool> startCall() async {
    try {
      // 1. Instancia a Sala com as configurações padrão do LiveKit
      room = Room();

      // 2. Escuta os eventos da sala (como quando o robô/atendente entra com vídeo)
      final listener = room!.createListener();
      _configurarListeners(listener);

      // 3. Conecta nativamente na infraestrutura
      await room!.connect(call!.serverUrl, call!.token);
      _estaConectado = true;
      try {
        // 4. Ativa a Câmera e o Microfone do celular Android imediatamente
        final cameraStatus = await room!.localParticipant?.setCameraEnabled(
          true,
          cameraCaptureOptions: const CameraCaptureOptions(
            params: VideoParametersPresets.h720_169,
          ),
        );
        final microphoneStatus = await room!.localParticipant
            ?.setMicrophoneEnabled(true);
      } catch (e, stack) {
        return false;
      }
      // 5. Captura a faixa de vídeo do próprio usuário para exibir o "preview" na tela
      final localVideoPublication =
          room!.localParticipant?.videoTrackPublications.firstOrNull;
      if (localVideoPublication != null) {
        localVideoTrack = localVideoPublication.track as VideoTrack?;
      }

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint("Erro ao conectar no LiveKit Android: $e");
      return false;
    }
  }

  void _configurarListeners(EventsListener<RoomEvent> listener) {
    // Fica vigiando se alguém (robô ou atendente) publicou uma faixa de vídeo na sala
    listener.on<TrackSubscribedEvent>((event) {
      if (event.track.kind == TrackType.VIDEO) {
        remoteVideoTrack = event.track as VideoTrack?;
        notifyListeners();
      }
    });

    // Se o outro lado desligar ou a emergência fechar
    listener.on<RoomDisconnectedEvent>((event) {
      _estaConectado = false;
      localVideoTrack = null;
      remoteVideoTrack = null;
      room = null;
      notifyListeners();
    });
  }

  // Chame sempre ao sair da tela para liberar a câmera do Android
  Future<void> finishCall() async {
    await room?.disconnect();
    _estaConectado = false;
    localVideoTrack = null;
    remoteVideoTrack = null;
    notifyListeners();
  }
}
