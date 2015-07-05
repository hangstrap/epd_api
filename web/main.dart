

import 'dart:async';

import 'package:http/browser_client.dart';
import 'package:epd_api_shelf/client/epd.dart';
import 'package:epd_api_shelf/common/timeseries_model.dart';


final BrowserClient _client = new BrowserClient();
Epd _api;

Future main() async {
  print( "inside main");
  _api = new Epd(_client, servicePath:"api/epd/v1/");
  List<TimeseriesBestSeries> result = await _api.byLatest("City, Town & Spot Forecasts", "PDF-PROFOUND",
  "20150215T0300Z", "20150215T0600Z", locations:"01492.INTL,03266.INTL",elements:"TTTTT");


  result.forEach( (series){

    print( "latest at ${series.latestAt}");
    series.editions.forEach( (edition) => print( "analysisAt=${edition.analysisAt}  validFrom=${edition.validFrom} mean=${edition.datum['mean']}"));
  });

  print( "done");
}