library epd_api_application;

import 'dart:io';
import 'dart:async';
import 'dart:core';

import 'package:shelf_route/shelf_route.dart' as shelf_route;
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:rpc/rpc.dart';

import "timeseries_model.dart";
import "timeseries_catalogue.dart";

import "caf_file_retriever.dart";
import "timeseries_data_cache.dart";
import "epd_api.dart";


const _API_PREFIX = '/api';
final ApiServer _apiServer = new ApiServer(apiPrefix: _API_PREFIX, prettyPrint: true);

void main(){
  setUpJsonConverters();
  Directory destination = new Directory("/temp/epdapi/");
  
}



void downloadRepsotory( Directory destination ) async{
  
Uri url = new Uri.http("amps-caf-output.met.co.nz", "/ICE");


await download(url, destination);
 
print( "Download finished");
}

Future startupServer( CafFileRetriever retriever, TimeseriesCatalogue catalogue) async {

  TimeseriesDataCache cache = new TimeseriesDataCache(retriever.loadTimeseres, catalogue.findAnalysissForPeriod);

  _apiServer.addApi(new EpdApi(cache));
  var apiRouter = shelf_route.router();
  apiRouter.add(_API_PREFIX, ['GET', 'POST'], _apiHandler, exactMatch: false);

  var handler = const shelf.Pipeline().addMiddleware(shelf.logRequests()).addHandler(apiRouter.handler);

  var server = await shelf_io.serve(handler, InternetAddress.ANY_IP_V6, 9090);
  var url = 'http://localhost:9090/';
  _apiServer.enableDiscoveryApi(url);
  print('Listening at port ${server.port}.');
}

Future<shelf.Response> _apiHandler(shelf.Request request) async {
  try {
    var apiRequest = new HttpApiRequest(request.method, request.url.path, request.url.queryParameters, request.headers, request.read());
    var apiResponse = await _apiServer.handleHttpApiRequest(apiRequest);
    return new shelf.Response(apiResponse.status, body: apiResponse.body, headers: apiResponse.headers);
  } catch (e) {
    // Should never happen since the apiServer.handleHttpRequest method
    // always returns a response.
    return new shelf.Response.internalServerError(body: e.toString());
  }
}