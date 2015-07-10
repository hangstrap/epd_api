library epd_api_application;

import 'dart:io';
import 'dart:async';
import 'dart:core';

import 'package:logging/logging.dart';
import 'package:rpc/rpc.dart';

import "timeseries_catalogue.dart";
import "caf_file_retriever.dart";
import "../lib/server/timeseries_data_cache.dart";
import "../lib/server/epd_api.dart";
import "json_converters.dart";
import "caf_repository_downloader.dart";

const _API_PREFIX = '/api';
final ApiServer _apiServer = new ApiServer(apiPrefix: _API_PREFIX, prettyPrint: true);
final Logger _log = new Logger('epd_app_application');

Future main(List<String> arguments) async {
  Logger.root.level = Level.INFO;
  Logger.root.onRecord.listen((LogRecord rec) {
    print('${rec.level.name}: ${rec.time}: ${rec.message}');
  });
  
  Uri uri = new Uri.http("amps-caf-output.met.co.nz", "/ICE/PDF-PROFOUND/");

  Directory dataDirectory = new Directory("/temp/epdapi/");
//  Directory dataDirectory = new Directory("data");

  setUpJsonConverters();

  _log.info("Starting up application, dataDirectory at ${dataDirectory}");

  CataloguePersister persister = new CataloguePersister(dataDirectory);

  TimeseriesCatalogue catalogue = new TimeseriesCatalogue(persister.load, persister.save);

  startCafRepositoryDownloader(uri, dataDirectory, catalogue);

  CafFileRetriever retriever = new CafFileRetriever(dataDirectory.path);
  await startupServer(retriever, catalogue);

  _log.info("server now running");

  return new Future.value();
}

void startCafRepositoryDownloader(Uri uri, Directory destination, TimeseriesCatalogue catalogue) {
  CafFileDownloader downloader = new CafFileDownloader(uri, destination, catalogue);
  
  new Timer.periodic(const Duration(minutes:1) , (_)async {
    
    if( !downloader.busy){
      await downloader.findFilesToDownload();
      await downloader.downloadFiles();
    }    
  });
}

Future startupServer(CafFileRetriever retriever, TimeseriesCatalogue catalogue) async {
  TimeseriesDataCache cache = new TimeseriesDataCache(retriever.loadTimeseres, catalogue.findAnalysissForPeriod);

  _apiServer.addApi(new EpdApi.create(cache));
  _apiServer.enableDiscoveryApi();

  HttpServer server = await HttpServer.bind(InternetAddress.ANY_IP_V4, 8080);
  server.listen(_apiServer.httpRequestHandler);
  _log.info('Listening at port ${server.port}.');
}

