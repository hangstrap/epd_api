import 'dart:io';

import 'package:unittest/unittest.dart';
import 'package:http_server/http_server.dart' show VirtualDirectory;

import '../bin/json_converters.dart';
import "../bin/caf_repository_downloader.dart" as downloader;
import '../bin/timeseries_catalogue.dart';


main() {
  Directory  outputDirectory = new Directory("temp/");

  CataloguePersister persister = new CataloguePersister( outputDirectory);
  TimeseriesCatalogue catalogue = new TimeseriesCatalogue(persister.load, persister.save);

  
  setUpJsonConverters();  

  group("main", () {
    HttpServer testServer;

    setUp(() {
      if (outputDirectory.existsSync()) {
        outputDirectory.deleteSync(recursive: true);
      }

      final MY_HTTP_ROOT_PATH = Platform.script.resolve('www').toFilePath();
      final virDir = new VirtualDirectory(MY_HTTP_ROOT_PATH)..allowDirectoryListing = true;

      return HttpServer.bind(InternetAddress.LOOPBACK_IP_V4, 8080).then((server) {
        testServer = server;
        server.listen((request) {
          virDir.serveRequest(request);
        });
      });
    });

    tearDown(() {
      print("stopping server");
      return testServer.close();
    });

    Uri uri = new Uri.http("localhost:8080", "DLITE.html");

    solo_test("Empty catalog will download all caf files", () async {
      

      expect(await downloader.downloaderCafFilesFromWebSite(uri, outputDirectory, catalogue), same(catalogue));
      
      File output = new File('temp/CityTownSpotForecasts/PDF-PROFOUND/TTTTT/03772/CityTownSpotForecasts.PDF-PROFOUND.TTTTT.201502150300Z.03772.caf');
      expect(output.existsSync(), isTrue);

    });
//TODO make this work!
    test("No files have been downloaded as catalog contains entry", () async {

      await downloader.downloaderCafFilesFromWebSite(uri, outputDirectory, catalogue);

      File output = new File('temp/CityTownSpotForecasts/PDF-PROFOUND/201502150300Z/TTTTT/CityTownSpotForecasts.PDF-PROFOUND.201502150300Z.TTTTT.03772.caf');
      expect(output.existsSync(), isFalse);

    });
  });
  
  
}
