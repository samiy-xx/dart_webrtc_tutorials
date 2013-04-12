import 'dart:html';
import 'dart:async';

void main() {
// Get reference to VideoElement
  AudioElement localAudio = query("#local_audio");

  if (MediaStream.supported) {
    // Ask navigator for access to webcam and microphone
    Future userMediaFuture = window.navigator.getUserMedia(audio: true);

    // When access granted, generate object url and assign it to video element src property
    userMediaFuture.then((LocalMediaStream stream) {
      String url = Url.createObjectUrl(stream);
      localAudio.src = url;
    });

    // Catch errors
    userMediaFuture.catchError((AsyncError e) {
      NavigatorUserMediaError error = e.error;
      if (error.code == NavigatorUserMediaError.PERMISSION_DENIED) {
        window.alert("User denied access to media");
      } else {
        window.alert("Some other error");
      }
    });
  }
}


