library caf_repository_downloader;

import "dart:io";
import 'dart:core';
import 'dart:async';

import 'package:pool/pool.dart';
import "package:quiver/async.dart";
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';

import 'web_site_listing_crawler.dart' as crawler;
import 'caf_file_decoder.dart' as deconder;
import 'timeseries_catalogue.dart';
import 'json_converters.dart';

final Logger _log = new Logger('caf_repository_downloader');

Future<TimeseriesCatalogue> downloaderCafFilesFromWebSite(
    Uri url, Directory destination, TimeseriesCatalogue catalog) async {
  
  
  FutureGroup fg = new FutureGroup();

  Pool pool = new Pool(10);

  Future downloadCafFile(crawler.Link link) async {
    try {
      _log.fine("downloading caf file from ${link.url}");
      http.Response response = await pool.withResource(() => http.get(link.url));

      if (response.statusCode != 200) {
        throw "web request failed with code of ${response.statusCode}";
      }

      _log.fine("downloaded caf file ${link.url}");

      String contents = response.body;
      List<String> contentLines = contents.split("\n");
      String fileName;

      try {
        fileName = deconder.fileNameForCafFile(contentLines);
      } catch (e) {
        _log.warning( "could not parse ${link.url} due to ${e}");
      }
      File file = new File(destination.path + fileName);

      Directory newParent = file.parent;
      if (!await newParent.exists()) {
        await newParent.create(recursive: true);
      }

      await file.writeAsString(contents);

      catalog.addAnalysis(deconder.toTimeseiesAssembly(contentLines));

      _log.info("processed file ${file.path}");

      return new Future.value();
    } catch (onError) {
      print("error downloading caf file ${link.url} error='${onError}'");
    }
  }

  bool foundLink(crawler.Link link) {
    _log.fine("found link ${link.name}");
    if (link.isDirectory) {
      return true;
    }

    if (link.name.endsWith('.caf')) {
//      if (!catalog.isDownloaded(link.url)) {
        fg.add(downloadCafFile(link));
//      } else {
//        print("has been download");
//      }
    }
    return true;
  }

  await crawler.crawl(url, foundLink);

  //wait for everything to finish
  await fg.future;

  return new Future.value(catalog);
}

Future main() async {
  setUpJsonConverters();

  Uri url = new Uri.http("amps-caf-output.met.co.nz", "/ICE");
  Directory destination = new Directory("/temp/epdapi/");

  CataloguePersister persister = new CataloguePersister(destination);
  TimeseriesCatalogue catalog = new TimeseriesCatalogue(persister.load, persister.save);


  catalog = await downloaderCafFilesFromWebSite(url, destination, catalog);

  return null;
}
