library api;

import 'package:rpc/rpc.dart';
import 'timeseries_model.dart';
import 'dart:async';


import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_route/shelf_route.dart' as shelf_route;
//http://localhost:8080/api/epdApi/0.1/byAnalysis/City Town & Spot Forecasts/PDF-PROFOUND/201502150300Z

typedef  Future<List<TimeseriesAssemblyDTO>> GetTimeseriesAnalysisSet(List<TimeseriesNode> nodes, DateTime analysis, 
    DateTime from, Duration period);


@ApiClass(
  name: 'epdApi',
  version: '0.1',
  description: 'API for EPD da  ta' 
)
class EpdApi{
  
    final GetTimeseriesAnalysisSet loader;
    EpdApi( this.loader);
    

    @ApiMethod(method: 'GET', path: 'byAnalysis/{product}/{model}/{analysis}')
    
    Future<List<TimeseriesAssemblyDTO>> byAnalysis(String product, String model, String analysis) {
      print( "inside api");
      TimeseriesNode node = new TimeseriesNode(product, model, "TTTTT", "01492", "INTL");
      DateTime analysisAt = DateTime.parse( analysis);
      
      return loader( [node], analysisAt, null, null);  
    }
}

class TimeseriesAssemblyDTO{
  DateTime analysisAt;
  
  TimeseriesAssemblyDTO();
  TimeseriesAssemblyDTO.create( TimeseriesAssembly assembly){
    analysisAt = assembly.analysis;
  }
}

Future<List<TimeseriesAssemblyDTO>> dummyLoader(List<TimeseriesNode> nodes, DateTime analysis, 
    DateTime from, Duration period){
  
  TimeseriesAssembly assembly = new TimeseriesAssembly(nodes[0], analysis, []);
  TimeseriesAssemblyDTO dto = new TimeseriesAssemblyDTO.create( assembly);
  return new Future.value( [dto]);
}



const _API_PREFIX = '/api';
final ApiServer _apiServer = new ApiServer(_API_PREFIX);

void main() {
  _apiServer.addApi(new EpdApi( dummyLoader));
  
  
  var apiRouter = shelf_route.router();
  
  apiRouter.add(_API_PREFIX, ['GET', 'POST'], _apiHandler, exactMatch: false);
  
  
  var handler = const shelf.Pipeline()
       .addMiddleware(shelf.logRequests())
       .addHandler(apiRouter.handler);

  
  shelf_io.serve(handler, '0.0.0.0', 8080);
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



