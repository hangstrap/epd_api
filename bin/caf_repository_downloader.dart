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
import 'timeseries_model.dart';
import 'json_converters.dart';


final Logger _log = new Logger('caf_repository_downloader');

class CafFileDownloader {
  final Uri url;
  final Directory destination;
  final TimeseriesCatalogue catalog;
  
  final List<Uri> downloaded = [];

  FutureGroup fg = new FutureGroup();

  Pool pool = new Pool(1);

  CafFileDownloader(this.url, this.destination, this.catalog);

  Future download() async {
    
    _log.info("downloading latest data from repository");
    await crawler.crawl(url, _foundLink);

    //wait for everything to finish
    await fg.future;
    _log.info("finshed downloading latest data from repository");
    return new Future.value();
  }

  bool _foundLink(crawler.Link link) {
    _log.fine("found link ${link.name}");
    if (link.isDirectory) {
      return true;
    }

    if (link.name.endsWith('.caf')) {
      if( !downloaded.contains( link.url)){
      fg.add(_downloadCafFile(link));
      _log.fine( "${link.name} has been download");
}
    }
    return true;
  }

  Future _downloadCafFile(crawler.Link link) async {
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
        throw "could not parse ${link.url} due to ${e}";
      }
      
      TimeseriesAssembly assembly = deconder.toTimeseiesAssembly(contentLines);
      File file = new File(destination.path + fileName);

      await _insureDirectoryExists(file);

      await file.writeAsString(contents);

      catalog.addAnalysis(assembly);

      _log.info("processed file ${file.path}");

      return new Future.value();
    } catch (onError) {
      _log.warning("error downloading caf file ${link.url} error='${onError}'");
    }
  }

  Future _insureDirectoryExists(File file) async {
    Directory newParent = file.parent;
    if (!await newParent.exists()) {
      await newParent.create(recursive: true);
    }
  }
}

Future main() async {
  setUpJsonConverters();

  Uri url = new Uri.http("amps-caf-output.met.co.nz", "/ICE");
  Directory destination = new Directory("/temp/epdapi/");

  CataloguePersister persister = new CataloguePersister(destination);
  TimeseriesCatalogue catalog = new TimeseriesCatalogue(persister.load, persister.save);

  CafFileDownloader downloader = new CafFileDownloader(url, destination, catalog);
  return await downloader.download();
}
