import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:gina/presenter/home/home/store/home_controller.dart';
import 'package:provider/provider.dart';
import 'package:sdp_transform/sdp_transform.dart';

class CallPage extends StatefulWidget {
  const CallPage({super.key});

  @override
  State<CallPage> createState() => _CallPageState();
}

class _CallPageState extends State<CallPage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final controller = context.read<HomeController>();
      initRenderers();
      _localStream = await _getUserMedia();
      await controller.getCurrentAddress();
    });
  }

  final _localVideoRenderer = RTCVideoRenderer();
  final _remoteVideoRenderer = RTCVideoRenderer();
  final sdpController = TextEditingController();
  bool _offer = false;

  RTCPeerConnection? _peerConnection;
  Map<String, dynamic> configuration = {
    "iceServers": [
      {"url": "stun:stun.l.google.com:19302"},
    ],
  };
  final Map<String, dynamic> offerSdpConstraints = {
    "mandatory": {"OfferToReceiveAudio": true, "OfferToReceiveVideo": true},
    "optional": [],
  };

  void _createOffer() async {
    RTCSessionDescription description = await _peerConnection!.createOffer({
      'offerToReceiveVideo': 1,
    });
    var session = parse(description.sdp.toString());
    print(json.encode(session));
    _offer = true;

    _peerConnection!.setLocalDescription(description);
  }

  void _createAnswer() async {
    RTCSessionDescription description = await _peerConnection!.createAnswer({
      'offerToReceiveVideo': 1,
    });

    var session = parse(description.sdp.toString());
    print(json.encode(session));

    _peerConnection!.setLocalDescription(description);
  }

  void _setRemoteDescription() async {
    String jsonString = sdpController.text;
    dynamic session = await jsonDecode(jsonString);

    String sdp = write(session, null);

    RTCSessionDescription description = RTCSessionDescription(
      sdp,
      _offer ? 'answer' : 'offer',
    );
    print(description.toMap());

    await _peerConnection!.setRemoteDescription(description);
  }

  void _addCandidate() async {
    String jsonString = sdpController.text;
    dynamic session = await jsonDecode(jsonString);
    print(session['candidate']);
    dynamic candidate = RTCIceCandidate(
      session['candidate'],
      session['sdpMid'],
      session['sdpMlineIndex'],
    );
    await _peerConnection!.addCandidate(candidate);
  }

  late MediaStream _localStream;
  void initRenderers() async {
    await _localVideoRenderer.initialize();
    await _remoteVideoRenderer.initialize();
  }

  _getUserMedia() async {
    final Map<String, dynamic> mediaConstraints = {
      'audio': true,
      'video': {'facingMode': 'user'},
    };

    MediaStream stream = await navigator.mediaDevices.getUserMedia(
      mediaConstraints,
    );
    _localVideoRenderer.srcObject = stream;
  }

  @override
  void dispose() async {
    await _localVideoRenderer.dispose();
    await _remoteVideoRenderer.dispose();
    sdpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Chamada")),
      body: Column(
        children: [
          videoRenderers(),
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.4,
                  child: TextField(
                    controller: sdpController,
                    keyboardType: TextInputType.multiline,
                    maxLines: 4,
                    maxLength: TextField.noMaxLength,
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _createOffer,
                    child: const Text("Offer"),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _createAnswer,
                    child: const Text("Answer"),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _setRemoteDescription,
                    child: const Text("Set Remote Description"),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _addCandidate,
                    child: const Text("Set Candidate"),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  SizedBox videoRenderers() => SizedBox(
    height: 210,
    child: Row(
      children: [
        Flexible(
          child: Container(
            key: Key('local'),
            margin: EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
            decoration: BoxDecoration(color: Colors.black),
            child: RTCVideoView(_localVideoRenderer),
          ),
        ),
        Flexible(
          child: Container(
            key: Key('remote'),
            margin: EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
            decoration: BoxDecoration(color: Colors.black),
            child: RTCVideoView(_remoteVideoRenderer),
          ),
        ),
      ],
    ),
  );
}
