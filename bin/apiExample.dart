library api;

import 'package:rpc/rpc.dart';

import 'dart:async';


import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_route/shelf_route.dart' as shelf_route;
//http://localhost:8080/api/epdApi/0.1/byAnalysis/product


@ApiClass(
  name: 'epdApi',
  version: '0.1',
  description: 'API for EPD da  ta' 
)


class MyApi {
  @ApiMethod(method: 'GET', path: 'byAnalysis/{product}')
  MyResponse findAge(String product) {
    return new MyResponse()..result="request for product ${product}";
  }
}

class MyResponse {
  String result;
  MyResponse();
}

const _API_PREFIX = '/api';
final ApiServer _apiServer = new ApiServer(_API_PREFIX);

void main() {
  _apiServer.addApi(new MyApi());
  
  
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
