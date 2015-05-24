import 'dart:io';

import 'package:unittest/unittest.dart';
import 'package:http_server/http_server.dart' show VirtualDirectory;
import 'package:logging/logging.dart';

import '../bin/json_converters.dart';
import "../bin/caf_repository_downloader.dart" ;
import '../bin/timeseries_catalogue.dart';


main() {
  
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((LogRecord rec) {
    print('${rec.level.name}: ${rec.time}: ${rec.message}');
  });
  
  Directory  outputDirectory = new Directory("temp/");
  
  CataloguePersister persister = new CataloguePersister( outputDirectory);
  TimeseriesCatalogue catalogue = new TimeseriesCatalogue({}, persister.save);

  
  setUpJsonConverters();  

  group("main", () {
    HttpServer testServer;

    setUp(() {
      if (outputDirectory.existsSync()) {
        outputDirectory.deleteSync(recursive: true);
      }
      outputDirectory.createSync();

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
      
      CafFileDownloader underTest = new CafFileDownloader(uri, outputDirectory, catalogue);
      await underTest.download();
      
      File output = new File('temp/CityTownSpotForecasts/PDF-PROFOUND/TTTTT/03772/CityTownSpotForecasts.PDF-PROFOUND.TTTTT.201502150300Z.03772.caf');
      expect(output.existsSync(), isTrue);

      File jsonFile = new File('temp/downloadedList.json');
      expect( jsonFile.readAsStringSync(), equals( '["http://localhost:8080/DLITE/TTTTT/20150327T22Z/TTTTT_20150327T18Z_03772.caf"]'));

    });

    test("Should not download file if in downloaded list", () async {

      File jsonFile = new File('temp/downloadedList.json');
      
      jsonFile.writeAsStringSync( '["http://localhost:8080/DLITE/TTTTT/20150327T22Z/TTTTT_20150327T18Z_03772.caf"]');
      
      CafFileDownloader underTest = new CafFileDownloader(uri, outputDirectory, catalogue);
      await underTest.download();

      File output = new File('temp/CityTownSpotForecasts/PDF-PROFOUND/TTTTT/03772/CityTownSpotForecasts.PDF-PROFOUND.TTTTT.201502150300Z.03772.caf');      
      expect(output.existsSync(), isFalse);

    });
  });
  
  
}
