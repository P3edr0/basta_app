import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart' as rtc;
import 'package:gina/domain/entities/call_data_entity.dart';
import 'package:livekit_client/livekit_client.dart';

class CallController extends ChangeNotifier {
  Room? room;
  bool _isConnected = false;
  bool get isConnected => _isConnected;
  CallDataEntity? call;
  String? exception;
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
      _isConnected = true;
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
        exception =
            "Você precisa conceder permissão para acessar o microfone e a câmera para iniciar uma chamada de emergência.";
        return false;
      }
      // 5. Captura a faixa de vídeo do próprio usuário para exibir o "preview" na tela
      final localVideoPublication =
          room!.localParticipant?.videoTrackPublications.firstOrNull;
      if (localVideoPublication != null) {
        localVideoTrack = localVideoPublication.track as VideoTrack?;
      }
      exception = null;
      notifyListeners();
      return true;
    } catch (e) {
      exception = "Erro ao conectar no LiveKit Android!\n Erro:$e";
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
      _isConnected = false;
      localVideoTrack = null;
      remoteVideoTrack = null;
      room = null;
      notifyListeners();
    });
  }

  Future<void> switchCamera() async {
    // 1. Pega a publicação de vídeo local (a mesma que você instanciou no startCall)
    final localVideoPublication =
        room!.localParticipant?.videoTrackPublications
            .where((p) => p.source == TrackSource.camera)
            .firstOrNull;

    if (localVideoPublication != null) {
      final track = localVideoPublication.track;

      // 2. Extrai a MediaStreamTrack nativa e pede pro hardware inverter
      if (track != null) {
        await rtc.Helper.switchCamera(track.mediaStreamTrack);
      }
    }
  }

  // Chame sempre ao sair da tela para liberar a câmera do Android
  Future<void> finishCall() async {
    await room?.disconnect();
    _isConnected = false;
    localVideoTrack = null;
    remoteVideoTrack = null;
    notifyListeners();
  }
}
