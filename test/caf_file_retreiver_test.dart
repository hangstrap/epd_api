import 'package:unittest/unittest.dart';
import '../bin/caf_file_retriever.dart';
import '../bin/timeseries_model.dart';

void main() {

  CafFileRetriever retriever = new CafFileRetriever("../data");

  test("Load real data", () {
    TimeseriesAnalysis analysis = new TimeseriesAnalysis(
        new Product("City Town & Spot Forecasts"), 
        new Model("PDF-PROFOUND"), 
        new DateTime.utc(2015, 02, 15, 03, 00), 
        new Element("TTTTT"), 
        new Location("01492", "INTL"));

    return retriever.loadTimeseres(analysis).then((TimeseriesAssembly assembly) {

      //test some arbitary data
      expect(assembly.key.analysisAt, equals(new DateTime.utc(2015, 02, 15, 03, 00)));
      expect(assembly.key.location.name, equals("01492"));
      expect(assembly.editions.length, equals(361));
      expect(assembly.editions[0].dartum["mean"], equals(-0.226023));
    });

  });

}
