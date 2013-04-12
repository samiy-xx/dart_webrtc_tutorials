import 'dart:html';
import 'dart:async';

void main() {
  const String CONNECTION_STRING = 'ws://127.0.0.1:8888/ws';
  WebSocket ws = new WebSocket(CONNECTION_STRING);
  RtcPeerConnection peer = new RtcPeerConnection(
      {"iceServers": [{"url": "stun:stun.l.google.com:19302"}]},
      {'optional' : []}
  );

  ws.onOpen.listen((Event e) {

  });

  ws.onClose.listen((CloseEvent e) {

  });

  ws.onError.listen((Event e) {

  });

  ws.onMessage.listen((MessageEvent e) {

  });
}



