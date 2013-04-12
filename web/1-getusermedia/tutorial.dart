import 'dart:html';
import 'dart:async';

void main() {
  
  window.navigator.getUserMedia(audio: true, video:true).then((LocalMediaStream stream) {
    
  }).catchError((AsyncError e) {
    
  });
}

