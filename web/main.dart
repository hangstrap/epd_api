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
  print("loading epd data");
  List<TimeseriesBestSeries> series = await loadEpdData();
//  dumpTimeseriesBestSeries(series);
  print("Extracting data set");

  DataTable dataTable = new DataTable();
  dataTable.addColumn("string", "time");
  dataTable.addColumn("number", "10%");
  dataTable.addColumn("number", "50%");
  dataTable.addColumn("number", "mean");
  dataTable.addColumn("number", "90%");

  var data = extractDataSet(series.first);
  dataTable.addRows(data);

  print("drawing chart");
  var chart = new LineChart(document.getElementById('pdfChart'));

  chart.draw(dataTable);
  print("done");
  return null;
}

List<List<Object>> extractDataSet(TimeseriesBestSeries series) {
  List<List<Object>> result = [];
  series.editions.forEach((edition) {
    List value = [];

    value.add(edition.validFrom.toIso8601String());
    value.add(edition.pdf.cdfInverse(0.1));
    value.add(edition.pdf.cdfInverse(0.5));
    value.add(edition.mean);
    value.add(edition.pdf.cdfInverse(0.9));

    result.add(value);
  });
  print(result);
  return result;
}
Future<List<TimeseriesBestSeries>> loadEpdData() async{

  _api = new Epd(_client, servicePath: "api/epd/v1/");
  return _api.byLatest(
      "City, Town & Spot Forecasts", "PDF-PROFOUND", "20150215T0000Z",
      "20150217T0000Z", locations: "93466.INTL", elements: "TTTTT");
}

void dumpTimeseriesBestSeries(List<TimeseriesBestSeries> seriesArray) {

  seriesArray.forEach((TimeseriesBestSeries series) {
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
