import 'package:unittest/unittest.dart';
import '../bin/web_site_listing_crawler.dart' as crawler;

import 'dart:io';
import 'package:http_server/http_server.dart' show VirtualDirectory;

void main() {
  startTestServer();
  Uri uri = new Uri.http("localhost:8080", "DLITE.html");

  test("finds link in first page", () {
    crawler.Link result;

    bool foundLink(crawler.Link link) {
      expect(result, isNull);
      result = link;
      return false;
    }
    return crawler.crawl(uri, foundLink).then((_) {
      expect(result, isNotNull);
      expect(result.url, equals(new Uri.http("localhost:8080", "TTTTT.html")));
      expect(result.name, equals("TTTTT/"));
      expect(result.size, equals(""));
      expect(result.lastModifiedAt, equals("01-Apr-2015 01:19  "));
      expect(result.isDirectory, isTrue);
    });
  });
  solo_test("finds links in all pages", () {
    List<crawler.Link> result = [];

    bool foundLink(crawler.Link link) {
      result.add(link);
      return true;
    }
    return crawler.crawl(uri, foundLink).then((_) {
      expect(result.length, equals(3));
      expect(result[0].name, equals("TTTTT/"));
      expect(result[1].name, equals("20150327T22Z/"));
      expect(result[2].name, equals("TTTTT_20150327T18Z_03772.caf"));
    });
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
}