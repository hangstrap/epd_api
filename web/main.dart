import 'dart:async';
import 'dart:html';

import 'package:google_charts/google_charts.dart'
    show AnnotationChart, Gauge, LineChart, DataTable, arrayToDataTable, SelectionObjects, SelectedObject;

import 'package:http/browser_client.dart';
import 'package:epd_api_shelf/client/epd.dart';
import 'package:epd_api_shelf/common/timeseries_model.dart';

final BrowserClient _client = new BrowserClient();
Epd _api;

TimeseriesBestSeries series;
Future main() async {
  await LineChart.load();

  print("loading epd data");
  var seriesList = await loadEpdData();
  series = seriesList.first;
  
  print("Extracting data set");

  DataTable dataTable = new DataTable();
  dataTable.addColumn("datetime", "Date");
  dataTable.addColumn("number", "Mean", "the average or mean");
  dataTable.addColumn("number", "10%");
  dataTable.addColumn("number", "50%");
  dataTable.addColumn("number", "90%");

  var data = extractDataSet(series);
  dataTable.addRows(data);

  print("drawing chart");

  LineChart chart = new LineChart(document.getElementById('pdfChartValues'));
  selectHandler(_) {
    SelectionObjects selectedItems = chart.getSelection();
    if (selectedItems != null) {
      selectedItems.moveNext();
      SelectedObject item = selectedItems.current;
      DateTime selectedTime = data[item.row][0];
      displayPdf(selectedTime);
    }
  }

  chart.onSelect.listen(selectHandler);
  var options = {'curveType': 'function', 'intervals': {'style': 'area'},};

  chart.draw(dataTable, options);
  print("done");

  return null;
}

void displayPdf(selectedTime) {
  Edition edition = series.editions.firstWhere((edition) =>edition.validFrom == selectedTime);

  DataTable dataTable = new DataTable();
  dataTable.addColumn("number", "x");
  dataTable.addColumn("number", "pdf");
  

  for (num x = 0; x < 50; x += 0.05) {
    num pdf = edition.pdf.pdf(x.roundToDouble());
    dataTable.addRow([x, pdf]);
  }

  new LineChart(document.getElementById('pdfChartPdf')).draw(dataTable, {});
}

List<List<Object>> extractDataSet(TimeseriesBestSeries series) {
  List<List<Object>> result = [];
  series.editions.forEach((edition) {
    List value = [];

    value.add(edition.validFrom);
    value.add(edition.mean);
    value.add(edition.pdf.cdfInverse(0.1));
    value.add(edition.pdf.cdfInverse(0.50));
    value.add(edition.pdf.cdfInverse(0.90));

    result.add(value);
  });
  print(result);
  return result;
}
Future<List<TimeseriesBestSeries>> loadEpdData() async {
  _api = new Epd(_client, servicePath: "api/epd/v1/");
  return _api.byLatest("City, Town & Spot Forecasts", "PDF-PROFOUND", "20150215T0000Z", "20150221T0000Z",
      locations: "93466.INTL", elements: "TTTTT");
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
