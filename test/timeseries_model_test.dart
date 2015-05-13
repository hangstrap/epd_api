import 'package:unittest/unittest.dart';
import 'package:jsonx/jsonx.dart' as jsonx;

import '../bin/timeseries_model.dart';
import '../bin/json_converters.dart';

import 'matchers.dart';

TimeseriesNode node = new TimeseriesNode.create("City Town & Spot Forecasts", "PDF-PROFOUND", "TTTTT", "01492", "INTL");
DateTime analysisAt = new DateTime.utc(2013, 4, 1, 00, 00);
DateTime am1 = new DateTime.utc(2013, 4, 1, 1, 0);
DateTime am2 = new DateTime.utc(2013, 4, 1, 2, 0);
DateTime am3 = new DateTime.utc(2013, 4, 1, 3, 0);
DateTime am4 = new DateTime.utc(2013, 4, 1, 4, 0);

void main() {
  setUpJsonConverters();

  test("JSON encode node", () {
    String json = jsonx.encode(node, indent: ' ');
    expect(json, equalsIgnoringWhitespace(jsonNode));
  });
  group("TimeseriesNode", () {
    test("convert to namespace string", () {
      expect(node.toNamespace(), equals("City Town & Spot Forecasts/PDF-PROFOUND/TTTTT/01492.INTL"));
    });
    test("convert from namespace string", () {
      expect(new TimeseriesNode.fromNamespace("City Town & Spot Forecasts/PDF-PROFOUND/TTTTT/01492.INTL"), equals(node));
    });
  });

  group("Timeseries Analysis", () {
    group("Filter Editions of spot data", () {
      List<Edition> editions = [
        new Edition.createMean(analysisAt, am1, am1, {}),
        new Edition.createMean(analysisAt, am2, am2, {}),
        new Edition.createMean(analysisAt, am3, am3, {}),
      ];
      TimeseriesAssembly assembly = new TimeseriesAssembly.create(node, analysisAt, editions);

      test("Null does not filter", () {
        TimeseriesAssembly result = new TimeseriesAssembly.filter(assembly, null, null);
        expect(result.editions, equals(editions));
        expect(result.node, same(node));
        expect(result.analysis, equals(analysisAt));
      });

      test("On edge of limits", () {
        List<Edition> result = new TimeseriesAssembly.filter(assembly, am1, new Duration(hours: 3)).editions;
        expect(result.length, equals(3));
        expect(result[0], equals(editions[0]));
        expect(result[1], equals(editions[1]));
        expect(result[2], equals(editions[2]));
      });

      test("Interval of one hour", () {
        List<Edition> result = new TimeseriesAssembly.filter(assembly, am2, new Duration(hours: 1)).editions;

        expect(result.length, equals(2));
        expect(result[0], equals(editions[1]));
        expect(result[1], equals(editions[2]));
      });
    });
    group("Filter Edition of interval data", () {
      List<Edition> editions = [
        new Edition.createMean(analysisAt, am1, am2, {}),
        new Edition.createMean(analysisAt, am2, am3, {}),
        new Edition.createMean(analysisAt, am3, am4, {}),
      ];
      TimeseriesAssembly assembly = new TimeseriesAssembly.create(node, analysisAt, editions);
      test("Null does not filter", () {
        List<Edition> result = new TimeseriesAssembly.filter(assembly, null, null).editions;
        expect(result, equals(editions));
      });

      test("On edge of limits", () {
        List<Edition> result = new TimeseriesAssembly.filter(assembly, am1, new Duration(hours: 3)).editions;
        expect(result.length, equals(3));
        expect(result[0], equals(editions[0]));
        expect(result[1], equals(editions[1]));
        expect(result[2], equals(editions[2]));
      });

      test("Interval of one hour", () {
        List<Edition> result = new TimeseriesAssembly.filter(assembly, am2, new Duration(hours: 1)).editions;

        expect(result.length, equals(3));
        expect(result[0], equals(editions[0]));
        expect(result[1], equals(editions[1]));
        expect(result[2], equals(editions[2]));
      });
    });
  });
  group("TimeseriesBestSeries", () {
    test("Should be able to have empty set of analysis", () {
      TimeseriesBestSeries underTest = new TimeseriesBestSeries.create(node, analysisAt, []);
      expect(underTest.editions.length, equals(0));
    });
    test("Should be able to have an analysis with a set of editions", () {
      TimeseriesAssembly assembly = new TimeseriesAssembly.create(node, analysisAt, []);
      TimeseriesBestSeries underTest = new TimeseriesBestSeries.create(node, analysisAt, [assembly]);
      expect(underTest.editions.length, equals(0));
    });
    test("If only have one analys then use the editions in that analysis", () {
      Edition edition = new Edition.createMean(analysisAt, am1, am1, {});
      TimeseriesAssembly assembly = new TimeseriesAssembly.create(node, analysisAt, [edition]);
      TimeseriesBestSeries underTest = new TimeseriesBestSeries.create(node, analysisAt, [assembly]);
      expect(underTest.editions.length, equals(1));
      expect(underTest.editions.elementAt(0), equals(edition));
    });
    test("If have multiple analys and editions independed then result will contain all the edttions", () {
      Edition earlyEdition = new Edition.createMean(analysisAt, am1, am1, {});
      TimeseriesAssembly earlyAssembly = new TimeseriesAssembly.create(node, analysisAt, [earlyEdition]);

      DateTime assemblyAt2 = analysisAt.add(new Duration(hours: 1));
      Edition laterEdition = new Edition.createMean(assemblyAt2, am2, am2, {});
      TimeseriesAssembly laterAssembly = new TimeseriesAssembly.create(node, assemblyAt2, [laterEdition]);

      TimeseriesBestSeries underTest = new TimeseriesBestSeries.create(node, analysisAt, [earlyAssembly, laterAssembly]);
      expect(underTest.editions.length, equals(2));
      expect(underTest.editions.elementAt(0), equals(earlyEdition));
      expect(underTest.editions.elementAt(1), equals(laterEdition));
    });

    test("If have multiple analys then the editions in the last analysis must be used if have overlap", () {
      Edition earlyAssemblyEdition = new Edition.createMean(analysisAt, am1, am1, {});
      TimeseriesAssembly earlyAssembly = new TimeseriesAssembly.create(node, analysisAt, [earlyAssemblyEdition]);

      DateTime assemblyAt2 = analysisAt.add(new Duration(hours: 1));
      Edition laterAssemblyEdition = new Edition.createMean(assemblyAt2, am1, am1, {});
      TimeseriesAssembly laterAssembly = new TimeseriesAssembly.create(node, assemblyAt2, [laterAssemblyEdition]);

      TimeseriesBestSeries underTest = new TimeseriesBestSeries.create(node, analysisAt, [earlyAssembly, laterAssembly]);
      expect(underTest.editions.length, equals(1));
      expect(underTest.editions.elementAt(0), equals(laterAssemblyEdition));
    });
    test("All assemblies must be for the same node", () {
      TimeseriesNode anotherNode = new TimeseriesNode.create("Another Product", "PDF-PROFOUND", "TTTTT", "01492", "INTL");
      TimeseriesAssembly assemblyForAnotherNode = new TimeseriesAssembly.create(anotherNode, analysisAt, []);

      expect(()=>new TimeseriesBestSeries.create(node, analysisAt, [assemblyForAnotherNode]), throwsA(exceptionMatching(ArgumentError, "An assembly is for the wrong node")));
    });
  });
}

String jsonNode = """{
 "product": "City Town & Spot Forecasts",
 "model": "PDF-PROFOUND",
 "element": "TTTTT",
 "locationName": "01492",
 "locationSuffix": "INTL"
}""";
