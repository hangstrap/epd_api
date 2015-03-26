// Copyright (c) 2015, <your name>. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as io;

import "timeseries_data_cache.dart";
import "caf_file_retriever.dart";
import "timeseries_model.dart";
import "dart:async";

void main(List<String> args) {

  CafFileRetriever retriever = new CafFileRetriever( "data");
  TimeseriesDataCache cache = new TimeseriesDataCache( retriever.loadTimeseres);

  
  Future<shelf.Response> _echoRequest(shelf.Request request) {
     
    TimeseriesAnalysis analysis = new TimeseriesAnalysis(
        new Product("City Town & Spot Forecasts"), 
        new Model("PDF-PROFOUND"), 
        new DateTime.utc(2015, 02, 15, 03, 00), 
        new Element("TTTTT"), 
        new Location("01492", "INTL"));
    
    Future<TimeseriesAssembly>  futureAssembly = cache.getTimeseries( analysis, null, null);
    
    
    return futureAssembly.then( (TimeseriesAnalysis assembly) => new shelf.Response.ok( assembly.toString()); 
  }

  
  
  
  
  
  var port = 8080;
  var handler = const shelf.Pipeline()
      .addMiddleware(shelf.logRequests())
      .addHandler(_echoRequest);

  io.serve(handler, 'localhost', port).then((server) {
    print('Serving at http://${server.address.host}:${server.port}');
  });


}