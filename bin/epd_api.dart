library epd_api;

import 'package:rpc/rpc.dart';
import 'dart:io';
import 'dart:async';
import 'dart:core';
import "timeseries_model.dart";
import "caf_file_retriever.dart";
import "timeseries_data_cache.dart";
import 'package:shelf_route/shelf_route.dart' as shelf_route;
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as shelf_io;

//http://localhost:9090/api/discovery/v1/apis
//http://localhost:9090/api/epd/v1/index
//http://localhost:9090/api/epd/v1/byAnalysis/City Town & Spot Forecasts/PDF-PROFOUND/20150215T0300Z?locations=01492.INTL,03266.INTL&elements=TTTTT&validFrom=20150215T0400Z&validTo=20150215T0600Z


class MyMessage{
  String message;
}

@ApiClass(version: 'v1', description: 'Epd Api', name: 'epd')
class EpdApi {

  final TimeseriesDataCache cache;
  
  EpdApi( this.cache);
  
  @ApiMethod(method: 'GET', path: 'index')
  MyMessage index(){
    return new MyMessage()..message = "index message";
  }
  
  @ApiMethod(method: 'GET', path: 'byAnalysis/{product}/{model}/{analysis}')
  Future<List<TimeseriesAssembly>> byAnalysis(String product, String model, String analysis, {String locations, String elements, String validFrom, String validTo}) {
    if ((locations == null) || (elements == null)) {
      throw new ArgumentError("locationCSV and elementCSV are required query paramters");
    }
    product = Uri.decodeComponent(product);
    model = Uri.decodeComponent(model);
    analysis = Uri.decodeComponent(analysis);
    
    List<TimeseriesNode> nodes = [];
    List<String> locationList = locations.split(",");
    List<String> elementList = elements.split(",");  

    locationList.forEach((location) {
      elementList.forEach((element) {
        String locationName = location.split("\.")[0];
        String locationSuffix = location.split("\.")[1];
        nodes.add(new TimeseriesNode.create(product, model, element, locationName, locationSuffix));
      });
    });
    
    DateTime analysisAt = DateTime.parse( analysis);
    
      DateTime valid_From = null;
      Duration  period = null;
      if( validFrom !=null){
        valid_From = DateTime.parse( validFrom);
      }
      if( validTo !=null){
        DateTime valid_To = DateTime.parse( validTo);
        period = valid_To.difference( valid_From);
      }
  
      return cache.getTimeseriesAnalysisSet(nodes, analysisAt, valid_From, period);

  }
}
const _API_PREFIX = '/api';
final ApiServer _apiServer =
    new ApiServer(apiPrefix: _API_PREFIX, prettyPrint: true);

Future main() async {
  
  CafFileRetriever retriever = new CafFileRetriever("data");
  TimeseriesDataCache cache = new TimeseriesDataCache(retriever.loadTimeseres);

  _apiServer.addApi(new EpdApi( cache));
  var apiRouter = shelf_route.router();
  apiRouter.add(_API_PREFIX, ['GET', 'POST'], _apiHandler, exactMatch: false);
  
  var handler = const shelf.Pipeline()
      .addMiddleware(shelf.logRequests())
      .addHandler(apiRouter.handler);

  var server = await shelf_io.serve(handler, InternetAddress.ANY_IP_V6, 9090);
  var url = 'http://localhost:9090/';
  _apiServer.enableDiscoveryApi(url);
  print('Listening at port ${server.port}.');
}

Future<shelf.Response> _apiHandler(shelf.Request request) async {
  try {
    var apiRequest =
        new HttpApiRequest(request.method, request.url.path,
                           request.url.queryParameters,
                           request.headers, request.read());
    var apiResponse = await _apiServer.handleHttpApiRequest(apiRequest);
    return new shelf.Response(apiResponse.status, body: apiResponse.body,
                              headers: apiResponse.headers);
  } catch (e) {
    // Should never happen since the apiServer.handleHttpRequest method
    // always returns a response.
    return new shelf.Response.internalServerError(body: e.toString());
  }
}