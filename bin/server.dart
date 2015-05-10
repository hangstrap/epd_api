// Copyright (c) 2015, <your name>. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as io;

import "timeseries_data_cache.dart";
import "timeseries_catalogue.dart";
import "caf_file_retriever.dart";
import'json_converters.dart';

import "timeseries_model.dart";
import "dart:async";
import "dart:io";


import 'package:jsonx/jsonx.dart';

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
      result.add( new TimeseriesNode.create(product, model, element, locationName, locationSuffix));
    });
  });
  
  return result;
}
 
void main(List<String> args) {

  setUpJsonConverters();
  
  CafFileRetriever retriever = new CafFileRetriever("data");
  TimeseriesDataCache cache = new TimeseriesDataCache(retriever.loadTimeseres, new TimeseriesCatalogue().findAnalysissForPeriod);


  Future<shelf.Response> processRequest(shelf.Request request) {

    List<String> pathSegments = request.url.pathSegments;
    if(( pathSegments.length != 5)|| ( pathSegments[0] != "epd") || ( pathSegments[1] != "byAnalysis")){
      
      return new Future.value( new shelf.Response.internalServerError(
          body:'url must be like /epd/byAnalysis/City Town & Spot Forecasts/PDF-PROFOUND/20150215T0300Z?locations=01492.INTL,03266.INTL&elements=TTTTT&validFrom=20150215T0400Z&validTo=20150215T0600Z\nvalidFrom and validTo are optional'));
    }
  
    DateTime analysis = DateTime.parse( pathSegments[4]);
    Map<String, String> queryParams = request.url.queryParameters;
    List<TimeseriesNode> nodes = extractNodes( pathSegments, queryParams);
    
    DateTime validFrom = null;
    Duration  period = null;
    if( queryParams["validFrom"]!=null){
      validFrom = DateTime.parse( queryParams["validFrom"]);
    }
    if( queryParams["validTo"]!=null){
      DateTime validTo = DateTime.parse( queryParams["validTo"]);
      period = validTo.difference( validFrom);
    }
    
    
    Future<List<TimeseriesAssembly>> futureAssembly = cache.getTimeseriesAnalysisSet(nodes, analysis, validFrom, period);


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


