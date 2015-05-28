library epd_api_application;

import 'dart:io';
import 'dart:async';
import 'dart:core';

import 'package:shelf_route/shelf_route.dart' as shelf_route;
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:rpc/rpc.dart';
import 'package:logging/logging.dart';

import "timeseries_catalogue.dart";
import "caf_file_retriever.dart";
import "timeseries_data_cache.dart";
import "epd_api.dart";
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
  

  bool busy = false;
  new Timer.periodic(const Duration(minutes:1) , (_)async {
    
    if( !busy){
      busy = true;
      await downloader.findFilesToDownload();
      busy = false;
    }    
  });
}

Future startupServer(CafFileRetriever retriever, TimeseriesCatalogue catalogue) async {
  TimeseriesDataCache cache = new TimeseriesDataCache(retriever.loadTimeseres, catalogue.findAnalysissForPeriod);

  _apiServer.addApi(new EpdApi(cache));
  var apiRouter = shelf_route.router();
  apiRouter.add(_API_PREFIX, ['GET', 'POST'], _apiHandler, exactMatch: false);

  var handler = const shelf.Pipeline().addMiddleware(shelf.logRequests()).addHandler(apiRouter.handler);

  var server = await shelf_io.serve(handler, InternetAddress.ANY_IP_V6, 9090);
  var url = 'http://localhost:9090/';
  _apiServer.enableDiscoveryApi(url);
  _log.info('Listening at port ${server.port}.');
}

Future<shelf.Response> _apiHandler(shelf.Request request) async {
  try {
    var apiRequest = new HttpApiRequest(
        request.method, request.url.path, request.url.queryParameters, request.headers, request.read());
    var apiResponse = await _apiServer.handleHttpApiRequest(apiRequest);
    return new shelf.Response(apiResponse.status, body: apiResponse.body, headers: apiResponse.headers);
  } catch (e) {
    // Should never happen since the apiServer.handleHttpRequest method
    // always returns a response.
    return new shelf.Response.internalServerError(body: e.toString());
  }
}
