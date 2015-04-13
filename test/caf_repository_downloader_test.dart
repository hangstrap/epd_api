import 'package:unittest/unittest.dart';

import 'package:intl/intl.dart';
import 'dart:io';
import 'package:http_server/http_server.dart' show VirtualDirectory;


main(){
  
  setUp((){
    startTestServer();  
  });

  test( "Date formatter",(){
    
    //27-Mar-2015 22:13
    DateFormat df = new DateFormat( "d-MMM-y HH:mm");
    
    expect( df.parse( "27-Mar-2015 22:13"), equals( new DateTime(2015, 3,27,22,13)));
    
  });
}


void startTestServer() {
  final MY_HTTP_ROOT_PATH = Platform.script.resolve('www').toFilePath();
  final virDir = new VirtualDirectory(MY_HTTP_ROOT_PATH)
    ..allowDirectoryListing = true;

  HttpServer.bind(InternetAddress.LOOPBACK_IP_V4, 8080).then((server) {
    server.listen((request) {
      virDir.serveRequest(request);
    });
  });
