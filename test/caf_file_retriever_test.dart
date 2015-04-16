import 'package:unittest/unittest.dart';
import '../bin/caf_file_retriever.dart';
import '../bin/timeseries_model.dart';

void main() {
  CafFileRetriever retriever = new CafFileRetriever("data");

  test("Load real data", () async {
    TimeseriesNode node = new TimeseriesNode("City Town & Spot Forecasts", "PDF-PROFOUND", "TTTTT", "01492", "INTL");

    DateTime analysis = new DateTime.utc(2015, 02, 15, 03, 00);

    TimeseriesAssembly assembly = await retriever.loadTimeseres(node, analysis);

    //test some arbitary data
    expect(assembly.analysis, equals(new DateTime.utc(2015, 02, 15, 03, 00)));
    expect(assembly.node.locationName, equals("01492"));
    expect(assembly.node.locationSuffix, equals("INTL"));
    expect(assembly.editions.length, equals(361));
    expect(assembly.editions[0].datum["mean"], equals(-0.226023));
  });
}
