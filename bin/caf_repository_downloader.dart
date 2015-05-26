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
import 'json_converters.dart';

final Logger _log = new Logger('caf_repository_downloader');

class CafFileDownloader {
  final Uri url;
  final Directory destination;
  final TimeseriesCatalogue catalog;
  File jsonFile;
  final List<Uri> downloaded = [];
  int filedownloaded = 0;

  FutureGroup fg;

  Pool pool = new Pool(1);

  CafFileDownloader(this.url, this.destination, this.catalog) {

    //Load download list from disk
    jsonFile = new File(destination.path + "/downloadedList.json");
    if (jsonFile.existsSync()) {
      try{
      downloaded.addAll(jsonx.decode(jsonFile.readAsStringSync(), type: const jsonx.TypeHelper<List<Uri>>().type));
      }catch( e){
        _log.warning( "could not load ${jsonFile} from json ${e}");
      }
    }
  }

  Future download() async {
    _log.info("downloading latest data from repository");
    
    fg = new FutureGroup();
    await crawler.crawl(url, _foundLink);

    //Insure that FutureGroup does not wait forever if there is nothing to do
    fg.add( new Future.value());
    
    //wait for everything to finish
    await fg.future;
    _log.info("finshed downloading latest data from repository");
    //Save the final download list
    await writeDownloadedList();

    fg = null;
    
    return new Future.value();
  }
  
  Future writeDownloadedList()async{
    _log.info( "saving downloaded list ");
    return jsonFile.writeAsString(jsonx.encode(downloaded, indent:' '));
  }

  bool _foundLink(crawler.Link link) {
    _log.fine("found link ${link.url}");
    if (link.isDirectory) {
      return true;
    }

    if (link.name.endsWith('.caf')) {
      if (!downloaded.contains(link.url)) {
        fg.add(_downloadCafFile(link));
        _log.fine("${link.name} will be downloaded");
      } else {
        _log.fine("${link.name} has already been download");
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
      downloaded.add(link.url);

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

      _log.info("processed file ${file.path} ${filedownloaded}");
      
      filedownloaded++;
      if( filedownloaded % 10 == 0){
        await writeDownloadedList();
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
}

