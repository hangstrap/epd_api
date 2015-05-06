import 'package:unittest/unittest.dart';

import '../bin/json_converters.dart';

import "../bin/caf_repository_downloader.dart" as downloader;
import '../bin/timeseries_catalogue.dart';
import 'dart:io';
import "package:mock/mock.dart";

import 'package:http_server/http_server.dart' show VirtualDirectory;



@proxy
class MockTimeseriesCatalogue extends Mock implements TimeseriesCatalogue {}

main() {
  setUpJsonConverters();  
  group("main", () {
    HttpServer testServer;

    Directory outputDirectory;
    setUp(() {
      outputDirectory = new Directory("temp/");
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

    test("Empty catalog will download all caf files", () async {
      MockTimeseriesCatalogue catalogue = new MockTimeseriesCatalogue();
      catalogue.when(callsTo("isDownloaded")).thenReturn(false, 0);

      expect(await downloader.downloaderCafFilesFromWebSite(uri, outputDirectory, catalogue), same(catalogue));

      File output = new File('temp/CityTownSpotForecasts/PDF-PROFOUND/201502150300Z/TTTTT/CityTownSpotForecasts.PDF-PROFOUND.201502150300Z.TTTTT.03772.caf');
      expect(output.existsSync(), isTrue);

      //catalog should have been updated
      catalogue.getLogs(callsTo("addAnalysis")).verify(happenedExactly(1));
    });

    test("No files have been downloaded as catalog contains entry", () async {
      MockTimeseriesCatalogue catalogue = new MockTimeseriesCatalogue();
      catalogue.when(callsTo("isDownloaded")).thenReturn(true);

      await downloader.downloaderCafFilesFromWebSite(uri, outputDirectory, catalogue);

      File output = new File('temp/CityTownSpotForecasts/PDF-PROFOUND/201502150300Z/TTTTT/CityTownSpotForecasts.PDF-PROFOUND.201502150300Z.TTTTT.03772.caf');
      expect(output.existsSync(), isFalse);

      //catalog should not be updated
      catalogue.getLogs(callsTo("addAnalysis")).verify(neverHappened);
    });
    
    solo_test("full monty", () async {
      
      print( await downloader.download(uri, outputDirectory));
      
    });
  });
  
  
}
