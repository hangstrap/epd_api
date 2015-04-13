import 'package:unittest/unittest.dart';

import "../bin/caf_repository_downloader.dart" as downloader;
import 'dart:io';
import 'dart:async';

import 'package:http_server/http_server.dart' show VirtualDirectory;

main() {
  group("main", () {
    HttpServer testServer;

    Directory output;
    setUp(() {
      
      output = new Directory("temp/");
      if( output.existsSync()){
        output.deleteSync( recursive:true);
      }
      
      final MY_HTTP_ROOT_PATH = Platform.script.resolve('www').toFilePath();
      final virDir = new VirtualDirectory(MY_HTTP_ROOT_PATH)
        ..allowDirectoryListing = true;

      return HttpServer
          .bind(InternetAddress.LOOPBACK_IP_V4, 8080)
          .then((server) {
        testServer = server;
        server.listen((request) {
          virDir.serveRequest(request);
        });
      });
    });

    tearDown(() {
      print( "stopping server");
      return testServer.close();
    });

    Uri uri = new Uri.http("localhost:8080", "DLITE.html");
    
    
    test( "a long time ago", (){
        DateTime lastDownloaded = new DateTime( 2000);
        downloader.downloaderCafFilesFromWebSite( uri, output, lastDownloaded).then( (DateTime on){
          print( on.toIso8601String());
        });
        
        Duration d = new Duration( seconds:10);
        return new Future.delayed(d).then((_){
          File output = new File( 'temp/CityTownSpotForecasts/PDF-PROFOUND/201502150300Z/TTTTT/CityTownSpotForecasts.PDF-PROFOUND.201502150300Z.TTTTT.03772.caf');
          expect( output.exists(), isTrue);
        });
    });
    
  });
}
