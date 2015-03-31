// Copyright (c) 2015, <your name>. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as io;

import "timeseries_data_cache.dart";
import "caf_file_retriever.dart";
import "timeseries_model.dart";
import "dart:async";

import 'package:jsonx/jsonx.dart';

void main(List<String> args) {

  CafFileRetriever retriever = new CafFileRetriever("data");
  TimeseriesDataCache cache = new TimeseriesDataCache(retriever.loadTimeseres);


  Future<shelf.Response> _echoRequest(shelf.Request request) {

    TimeseriesNode node = new TimeseriesNode("City Town & Spot Forecasts", "PDF-PROFOUND", "TTTTT", "01492", "INTL");

    DateTime analysis = new DateTime.utc(2015, 02, 15, 03, 00);


    Future<TimeseriesAssembly> futureAssembly = cache.getTimeseriesAnalysis(node, analysis, null, null);


    return futureAssembly.then((TimeseriesAssembly assembly) {


      //convert to json
      String json = encode(assembly);

      return new shelf.Response.ok(json);

    });
  }






  var port = 8080;
  var handler = const shelf.Pipeline().addMiddleware(shelf.logRequests()).addHandler(_echoRequest);

  io.serve(handler, 'localhost', port).then((server) {
    print('Serving at http://${server.address.host}:${server.port}');
  });


}
