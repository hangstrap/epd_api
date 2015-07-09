library caf_repository_downloader;

//http://localhost:8080/DLITE/TTTTT/20150327T22Z/TTTTT_20150327T18Z_03772.caf
//http://localhost:8080/DLITE/TTTTT/20150327T22Z/TTTTT_20150327T18Z_03772.caf
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
import '../lib/common/timeseries_model.dart';

final Logger _log = new Logger('caf_repository_downloader');

class CafFileDownloader {
  final Uri url;
  final Directory destination;
  final TimeseriesCatalogue catalog;

  final List<crawler.Link> toDownload = [];
  int filesDownloaded = 0;
  bool _busy = false;
  bool get busy => _busy || toDownload.length > 0;

  CafFileDownloader(this.url, this.destination, this.catalog) {
  }

  Future<int> findFilesToDownload() async {
    try {
      _log.info("checking what needs to be downloaded");
      _busy = true;
      await crawler.crawl(url, _foundLink);
      _log.info("finshed. ${toDownload.length} files to download");
      return new Future.value();
    } finally {
      _busy = false;
    }
  }

  Future downloadFiles() async {
    if (toDownload.isEmpty) {
      return new Future.value();
    }
    FutureGroup fg = new FutureGroup();
    Pool pool = new Pool(10);

    toDownload.forEach((link) {
      Future futureDownloaded = pool.withResource(() => _downloadCafFile(link));
      fg.add(futureDownloaded);
    });
    await fg.future;
    return new Future.value();
  }

  bool _foundLink(crawler.Link link) {
    _log.fine("found link ${link.url}");
    if (link.isDirectory) {
      return true;
    }

    if (link.name.endsWith('.caf')) {
      _checkAndDownload(link);
    }
    return true;
  }

  void _checkAndDownload(crawler.Link link) {
    if (!_checkIfDownloaded(link.pathName)) {
      toDownload.add(link);
      _log.fine("${link.name} still to downloaded");
    } else {
      _log.fine("${link.name} has already been download");
    }
  }

  Future _downloadCafFile(crawler.Link link) async {
    try {
      _log.fine("downloading caf file from ${link.url}");
      http.Response response = await http.get(link.url);

      if (response.statusCode != 200) {
        throw "web request failed with code of ${response.statusCode}";
      }

      _log.fine("downloaded caf file ${link.url}");
      toDownload.remove(link);

      String contents = response.body;
      contents = contents.replaceAll('\r', '');
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

      _log.info("processed file ${file.path} ${filesDownloaded}");

      filesDownloaded++;
      await _markFileAsDownloaded(link.pathName);

      return new Future.value();
    } catch (onError) {
      _log.warning("error downloading caf file ${link.url} error='${onError}'");
    }
  }

  Future _markFileAsDownloaded(String fileName) async {
    return createDownloadedFlagFile(fileName).create(recursive: true);
  }

  bool _checkIfDownloaded(String fileName) {
    return createDownloadedFlagFile(fileName).existsSync();
  }

  File createDownloadedFlagFile(String fileName) {
    return new File("${destination.path}\downloaded${fileName}");
  }
  Future _insureDirectoryExists(File file) async {
    Directory newParent = file.parent;
    if (!await newParent.exists()) {
      await newParent.create(recursive: true);
    }
  }
}
