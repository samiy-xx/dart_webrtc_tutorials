import 'dart:io';
import 'dart:async';
import 'dart:json' as json;

void main() {
  const String SOCKET_HOST = '127.0.0.1';
  const int SOCKET_PORT = 8888;
  List<WebSocket> _connections = new List<WebSocket>();

  HttpServer.bind(SOCKET_HOST, SOCKET_PORT).then((HttpServer server) {
    print("Binding server to address $SOCKET_HOST on port $SOCKET_PORT");
    server.transform(new WebSocketTransformer()).listen((WebSocket webSocket) {
      print("Received new connection");
      _connections.forEach((WebSocket ws) => ws.send(json.stringify({'join': 1})));
      _connections.add(webSocket);

      webSocket.listen((data) {
        print("Received data, forwarding");
        print(data);
        _connections.where((Websocket ws) => ws != webSocket).forEach((WebSocket ws) => ws.send(data));
      },
      onDone : () {
        _connections.remove(webSocket);
      },
      onError : (AsyncError e) {

      });
    });
  });
}

