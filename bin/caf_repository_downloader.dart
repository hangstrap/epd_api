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
import 'package:jsonx/jsonx.dart' as jsonx;

import 'web_site_listing_crawler.dart' as crawler;
import 'caf_file_decoder.dart' as deconder;
import 'timeseries_catalogue.dart';
import 'timeseries_model.dart';

final Logger _log = new Logger('caf_repository_downloader');

class CafFileDownloader {
  final Uri url;
  final Directory destination;

  final TimeseriesCatalogue catalog;
  File jsonFile;
  final Map<Uri, Object> downloaded = {};
  final List<crawler.Link> toDownload = [];
  int filedownloaded = 0;
  bool _busy = false;
  bool get busy => _busy || toDownload.length > 0;

  CafFileDownloader(this.url, this.destination, this.catalog) {

    //Load download list from disk
    jsonFile = new File(destination.path + "/downloadedList.json");
    _extractDownloadedListFromDisk();
  }

  Future<int> findFilesToDownload() async {
    try {
      _log.info("checking what needs to be downloaded");
      _busy = true;
      await crawler.crawl(url, _foundLink);
      _log.info("finshed. ${downloaded.length} files to download");
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
    await _writeDownloadedList();
    return new Future.value();
  }

  Future _writeDownloadedList() async {
    _log.info("saving downloaded list ");
    List<Uri> urls = [];
    urls.addAll(downloaded.keys);
    return jsonFile.writeAsString(jsonx.encode(urls, indent: ' '));
  }

  bool _foundLink(crawler.Link link) {
    _log.fine("found link ${link.url}");
    if (link.isDirectory) {
      return true;
    }

    if (link.name.endsWith('.caf')) {
      if (!downloaded.containsKey(link.url)) {
        toDownload.add(link);
        _log.fine("${link.name} still to downloaded");
      } else {
        _log.fine("${link.name} has already been download");
      }
    }
    return true;
  }

  Future _downloadCafFile(crawler.Link link) async {
    try {
      _log.fine("downloading caf file from ${link.url}");
      http.Response response = await http.get(link.url);

      if (response.statusCode != 200) {
        throw "web request failed with code of ${response.statusCode}";
      }

      _log.fine("downloaded caf file ${link.url}");
      downloaded[link.url] = true;
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

      _log.info("processed file ${file.path} ${filedownloaded}");

      filedownloaded++;
      if (filedownloaded % 10 == 0) {
        await _writeDownloadedList();
      }

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
  void _extractDownloadedListFromDisk() {
    try {
      if (jsonFile.existsSync()) {
        try {
          _log.info("loading list downloaded locations ");
          List<Uri> urls = jsonx.decode(jsonFile.readAsStringSync(), type: const jsonx.TypeHelper<List<Uri>>().type);
          urls.forEach((url) => downloaded[url] = true);
        } catch (e) {
          _log.warning("could not load ${jsonFile} from json ${e}");
        }
      }
    } catch (e) {
      _log.warning("could not load list of downloaded urls ${e}");
    }
  }
}
