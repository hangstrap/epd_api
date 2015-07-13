import 'dart:async';
import 'dart:html';

import 'package:google_charts/google_charts.dart'
show Gauge, LineChart, DataTable, arrayToDataTable;

import 'package:http/browser_client.dart';
import 'package:epd_api_shelf/client/epd.dart';
import 'package:epd_api_shelf/common/timeseries_model.dart';

final BrowserClient _client = new BrowserClient();
Epd _api;

Future main() async {
  await LineChart.load();
  var data = arrayToDataTable([[20, 80], [30, 55], [40, 68]], true);

  var chart = new LineChart(document.getElementById('pdfChart'));

  chart.draw(data);

  return null;
}

//List<List<num>> extractDataSet( TimeseriesBestSeries series){
//  List<List<num>>  result = [];
//  series.editions.forEach( (edition)=> result.add( edition.validFrom)); ///????
//}
Future<List<TimeseriesBestSeries>> loadEpdData() async{

  _api = new Epd(_client, servicePath: "api/epd/v1/");
  return _api.byLatest(
      "City, Town & Spot Forecasts", "PDF-PROFOUND", "20150215T0300Z",
      "20150215T0600Z", locations: "01492.INTL,03266.INTL", elements: "TTTTT");
}

Future main1() async {
  _api = new Epd(_client, servicePath: "api/epd/v1/");
  List<TimeseriesBestSeries> result = await _api.byLatest(
      "City, Town & Spot Forecasts", "PDF-PROFOUND", "20150215T0300Z",
      "20150215T0600Z", locations: "01492.INTL,03266.INTL", elements: "TTTTT");

  result.forEach((TimeseriesBestSeries series) {
    print("latest at ${series.latestAt} for ${series.node.locationName}");

    series.editions.forEach((Edition edition) {
      double mean = edition.datum['mean'];
      double cdfI_10 = edition.pdf.cdfInverse(0.1);
      double cdfI_50 = edition.pdf.cdfInverse(0.5);
      double cdfI_90 = edition.pdf.cdfInverse(0.9);
      print(
          "analysisAt=${edition.analysisAt}  validFrom=${edition.validFrom} mean=${mean} 10%=${cdfI_10.toStringAsFixed(6)} 50%=${cdfI_50.toStringAsFixed(6)} 50%=${cdfI_90.toStringAsFixed(6)}");
    });
  });
}
