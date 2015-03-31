// Copyright (c) 2015, <your name>. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as io;

import "timeseries_data_cache.dart";
import "caf_file_retriever.dart";
import "timeseries_model.dart";
import "dart:async";
import "dart:io";


import 'package:jsonx/jsonx.dart';

///epd/byAnalysis/product/model/201502150300Z?locations=01492.INTL,&elements=TTTTT

List<TimeseriesNode> extractNodes(List<String> pathSegments, Map<String, String> queryParams){
  
  String product = pathSegments[2];
  String model = pathSegments[3];
  
  List<TimeseriesNode> result = [];
  List<String> locations = queryParams["locations"].split(",");
  List<String> elements = queryParams["elements"].split( ",");
  
  locations.forEach((location){
    elements.forEach((element) {
      String locationName = location.split("\.")[0];
      String locationSuffix = location.split("\.")[1];      
      result.add( new TimeseriesNode(product, model, element, locationName, locationSuffix));
    });
  });
  
  return result;
}
 
void main(List<String> args) {

  CafFileRetriever retriever = new CafFileRetriever("data");
  TimeseriesDataCache cache = new TimeseriesDataCache(retriever.loadTimeseres);


  Future<shelf.Response> processRequest(shelf.Request request) {

    List<String> pathSegments = request.url.pathSegments;
    if(( pathSegments.length != 5)|| ( pathSegments[0] != "epd") || ( pathSegments[1] != "byAnalysis")){
      
      return new Future.value( new shelf.Response.internalServerError(
          body:'url must be like /epd/byAnalysis/City Town & Spot Forecasts/PDF-PROFOUND/20150215T0300Z?locations=01492.INTL,03266.INTL&elements=TTTTT'));
    }
  
    DateTime analysis = DateTime.parse( pathSegments[4]);
    List<TimeseriesNode> nodes = extractNodes( pathSegments, request.url.queryParameters);
    
    Future<List<TimeseriesAssembly>> futureAssembly = cache.getTimeseriesAnalysisSet(nodes, analysis, null, null);


    return futureAssembly.then((assembly) {

      //convert to json
      String json = encode(assembly);
      return new shelf.Response.ok(json);

    });
  }


  var port = 8080;
  var handler = const shelf.Pipeline().addMiddleware(shelf.logRequests()).addHandler(processRequest);

  io.serve(handler, InternetAddress.ANY_IP_V6, port).then((server) {
    print('Serving at http://${server.address.host}:${server.port}');
  });
}


