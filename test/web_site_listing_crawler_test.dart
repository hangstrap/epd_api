
import 'dart:io';
import 'dart:async';

import 'package:http_server/http_server.dart' show VirtualDirectory;
import 'package:test/test.dart';
import 'package:logging/logging.dart';

import '../bin/web_site_listing_crawler.dart' as crawler;


void main() {

  Logger.root.level = Level.INFO;
  Logger.root.onRecord.listen((LogRecord rec) {
    print('${rec.level.name}: ${rec.time}: ${rec.message}');
  });

  group("main", () {
    HttpServer testServer;

    setUp(() {
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
      return testServer.close();
    });

    Uri uri = new Uri.http("localhost:8080", "DLITE.html");

//    test("finds link in first page", () async {
//      crawler.Link result;
//
//      bool foundLink(crawler.Link link) {
//        expect(result, isNull);
//        result = link;
//        return false;
//      }
//
//      await crawler.crawl(uri, foundLink);
//      expect(result, isNotNull);
//      expect(result.url, equals(new Uri.http("localhost:8080", "DLITE/TTTTT.html")));
//      expect(result.name, equals("TTTTT/"));
//      expect(result.size, equals(""));
//      expect(result.lastModifiedAt, equals("01-Apr-2015 01:19  "));
//      expect(result.isDirectory, isTrue);
//    });
    test("finds links in all pages", () async {
      List<crawler.Link> result = [];

      bool foundLink(crawler.Link link) {
        result.add(link);
        return true;
      }

      Future f = crawler.crawl(uri, foundLink);

      f.then((__) => print("Main craller has finished"));

      await new Future.delayed(new Duration(seconds:10));
      print("delay has passed");

      expect(result.length, equals(3));
      expect(result[0].name, equals("TTTTT/"));
      expect(result[1].name, equals("20150327T22Z/"));
      expect(result[2].name, equals("TTTTT_20150327T18Z_03772.caf"));
    });
  });
}

void startTestServer() {
  final MY_HTTP_ROOT_PATH = Platform.script.resolve('www').toFilePath();
  final virDir = new VirtualDirectory(MY_HTTP_ROOT_PATH)..allowDirectoryListing = true;

  HttpServer.bind(InternetAddress.LOOPBACK_IP_V4, 8080).then((server) {
    server.listen((request) {
      virDir.serveRequest(request);
    });
  });
}
