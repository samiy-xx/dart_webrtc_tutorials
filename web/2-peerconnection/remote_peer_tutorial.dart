import 'dart:html';
import 'dart:async';
import 'dart:json' as json;

const String CONNECTION_STRING = 'ws://127.0.0.1:8888/ws';
RtcPeerConnection peer;
VideoElement localVideo;
VideoElement remoteVideo;
LocalMediaStream localMediaStream;
WebSocket ws;
bool hasLocalOffer = false;
bool host = false;

void main() {

  localVideo = query("#local_video");
  remoteVideo = query("#remote_video");

  window.navigator.getUserMedia(audio: true, video: true).then((LocalMediaStream ms) {
    localMediaStream = ms;
    localVideo.src = Url.createObjectUrl(ms);
    ws = new WebSocket(CONNECTION_STRING);

    ws.onOpen.listen((Event e) {

    });

    ws.onClose.listen((CloseEvent e) {

    });

    ws.onError.listen((Event e) {

    });

    ws.onMessage.listen((MessageEvent e) {

      Map map = json.parse(e.data);

      if (map.containsKey('candidate')) {
        //print("Received remote ice candidate from server");
        RtcIceCandidate ice = new RtcIceCandidate(map);
      } else if (map.containsKey('sdp')) {
        peer = new RtcPeerConnection(
            {"iceServers": [{"url": "stun:stun.l.google.com:19302"}]},
            {'optional' : []}
        );
        setEvents();
        peer.addStream(localMediaStream);
        print("Received remote session description answer from server");
        RtcSessionDescription desc = new RtcSessionDescription(map);

        print("Setting remote description");
        peer.setRemoteDescription(desc).then((val) {
          if (!hasLocalOffer) {
            print("Creating answer");
            peer.createAnswer().then((RtcSessionDescription sd) {
              print("Setting local description");
              peer.setLocalDescription(sd).then((val) {
                hasLocalOffer = true;
                print("Sending local description via websocket");
                ws.send(json.stringify({
                  'sdp':sd.sdp,
                  'type':sd.type
                }));
              });
            });
          }
        });
      } else {
        host = true;
        peer = new RtcPeerConnection(
            {"iceServers": [{"url": "stun:stun.l.google.com:19302"}]},
            {'optional' : []}
        );
        peer.addStream(localMediaStream);
        setEvents();
        // Assume someone joined channel
        print("Channel joined, creating offer session description");

      }
    });
  });
}

void setEvents() {
  peer.on['onsignalingstatechange'].listen((Event e) {
    print("-- Signaling state changed to ${peer.signalingState}");
  });

  peer.on['oniceconnectionstatechange'].listen((Event e) {
    print("-- Ice connection state changed to ${peer.iceConnectionState}");
  });

  peer.onIceCandidate.listen((RtcIceCandidateEvent e) {
    print("New Ice candidate was generated");

    if (e.candidate == null) {
      print("Generated Ice candidate was null marking the end of ice candidate generation");
      return;
    }

    print("Sending the generated ice candidate via websocket");
    ws.send(json.stringify({
      'candidate': e.candidate.candidate,
      'sdpMid': e.candidate.sdpMid,
      'sdpMLineIndex': e.candidate.sdpMLineIndex
    }));
  });

  peer.onAddStream.listen((MediaStreamEvent e) {
    print("Received remote mediastream");
    remoteVideo.src = Url.createObjectUrl(e.stream);
  });

  peer.onNegotiationNeeded.listen((Event e) {
    print("--- onNegotiationNeeded");
    if (host) {
      peer.createOffer().then((RtcSessionDescription sd) {
        print("Setting local description");
        peer.setLocalDescription(sd).then((val) {
          hasLocalOffer = true;
          print("Sending offer via websocket");
          ws.send(json.stringify({
            'sdp':sd.sdp,
            'type':sd.type
          }));
        }).catchError((AsyncError e) {

        });
      }).catchError((AsyncError e) {

      });
    }
  });
}



