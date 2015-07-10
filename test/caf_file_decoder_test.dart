import 'package:test/test.dart';
import 'package:mock/mock.dart';

import 'matchers.dart';
import '../bin/caf_file_decoder.dart' as caf;
import '../lib/common/timeseries_model.dart';

@proxy
class MockTimeseriesNode extends Mock implements TimeseriesNode {
  noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

main() {
  group("create correct file name based on CAF file contents", () {
    test("check the pattern for a 99xxx station", () {
      String cafFileName = caf.fileNameForCafFile(cafFileHeader99xxxx);
      expect(cafFileName, equals(
          "CityTownSpotForecasts/PDF-PROFOUND/TTTTT/99647-INTL/CityTownSpotForecasts.PDF-PROFOUND.TTTTT.201502150300Z.99647-INTL.caf"));
    });
    test("check the pattern for a non 99xxx station", () {
      String cafFileName = caf.fileNameForCafFile(cafFileHeader123456);
      expect(cafFileName, equals(
          "CityTownSpotForecasts/PDF-PROFOUND/TTTTT/123456/CityTownSpotForecasts.PDF-PROFOUND.TTTTT.201502150300Z.123456.caf"));
    });
  });

  group("create correct file name based on TimeseriesAnalysis", () {
    DateTime analysis = new DateTime.utc(2015, 2, 15, 3, 0);
    TimeseriesNode node =
        new TimeseriesNode.create("City, Town & Spot Forecasts", "PDF-PROFOUND", "TTTTT", "99647", "INTL");

    
    test("check pattern for a 99xxx station", () {

      String cafFileName = caf.fileNameForTimeseriesAnalysis(node, analysis);
      expect(cafFileName, equals(
          "CityTownSpotForecasts/PDF-PROFOUND/TTTTT/99647-INTL/CityTownSpotForecasts.PDF-PROFOUND.TTTTT.201502150300Z.99647-INTL.caf"));
    });
    test("check path for a 9xxx status", (){
      String fileNamePath = caf.pathNameForTimeseriesNode(node);
           expect(fileNamePath, equals(
               "CityTownSpotForecasts/PDF-PROFOUND/TTTTT/99647-INTL"));
         
    });    
    
  });

  group("caf file parser", () {
    List<String> lines;
    group("break into blocks", () {
      setUp(() {
        lines = ["one", "two", "", "four", "five"];
      });

      checkResult(List<List<String>> result) {
        expect(result.length, equals(2));

        expect(result[0].length, equals(2));
        expect(result[1].length, equals(2));

        expect(result[0][0], equals("one"));
        expect(result[0][1], equals("two"));

        expect(result[1][0], equals("four"));
        expect(result[1][1], equals("five"));
      }
      test("should handle no blank line at end", () {
        checkResult(caf.breakIntoCafBlocks(lines));
      });
      test("should handle blank line at end", () {
        lines.add("");
        checkResult(caf.breakIntoCafBlocks(lines));
      });
      test("should handle extra blank lines in middle", () {
        lines.insert(3, "");
        checkResult(caf.breakIntoCafBlocks(lines));
      });
    });

    group("parse of header block", () {
      test("parse of 99XXXX header", () {
        TimeseriesNode analysis = caf.toTimeseriesNode(cafFileHeader99xxxx);

        check99647Node(analysis);
      });
    });

    group("parse of data block", () {
      test("", () {
        DateTime analysisAt = new DateTime.utc(2015, 2, 15, 3, 00);

        Edition edition = caf.toEdition(cafFileBlock, analysisAt);
        checkEdition(edition, analysisAt);
      });
    });

    group("parse of entire file", () {
      List<String> lines = [];
      lines.addAll(cafFileHeader99xxxx);
      lines.addAll(cafFileBlock);

      test("", () {
        TimeseriesAssembly assembly = caf.toTimeseiesAssembly(lines);
        check99647Node(assembly.node);
        DateTime analysis = new DateTime.utc(2015, 2, 15, 3, 00);
        expect(assembly.analysis, equals(analysis));
        checkEdition(assembly.editions[0], analysis);
      });
    });

    test("throw meaningful error message when token missing", () {
      List<String> lines = ["aaaa=aaaa,bbbb=bbbb"];
      expect(() => caf.toTimeseriesNode(lines),
          throwsA(exceptionMatching(FormatException, "Could not find token 'product'")));
    });
  });
}

void checkEdition(Edition edition, DateTime analysis) {
  expect(edition.analysisAt, equals(analysis));
  expect(edition.validFrom, equals(analysis.add(new Duration(hours: 1))));
  expect(edition.validTo, equals(analysis.add(new Duration(hours: 1))));
  expect(edition.datum['mean'], equals(5.516087));
  expect(edition.datum['control-points'], equals([7.000000, 7.000250, 7.018750, 7.045000, 7.105000, 7.258750, 7.675000, 9.500000, 10.750000]));
  expect(edition.datum['logn-pdf-values'], equals([-9.999820, -1.131157, -0.279547, -0.126680, -0.017522, -0.021517, -0.432122, -3.529888, -6.106577]));
  expect(edition.datum['curvature-values'], equals([3.920818, 0.337233, 0.019309, 0.018923, 0.024092, 0.036923, 0.154945, 0.000000]));
  expect(edition.datum['tail-left'], equals(0));
  expect(edition.datum['tail-right'], equals(1));
  expect(edition.datum['variance'], equals(1.111753));

  edition.pdf;
}

void check99647Node(TimeseriesNode analysis) {
  expect(analysis.product, equals('City, Town & Spot Forecasts'));
  expect(analysis.model, equals('PDF-PROFOUND'));
  expect(analysis.locationName, equals('99647'));
  expect(analysis.locationSuffix, equals('INTL'));
  expect(analysis.element, equals('TTTTT'));
}

List<String> cafFileHeader99xxxx = """status:=ok
schema:=timeseries nwp vhapdf prognosis station amps-pdf
vha-code:=TTTTT
model-group:=PDF-PROFOUND
product:=City, Town & Spot Forecasts
issue-time:=20150215 0759 Z
station:=99647
station-99suffix:=INTL
init-time:=20150215 0300 Z
""".split("\n");

List<String> cafFileHeader123456 = """status:=ok
schema:=timeseries nwp vhapdf prognosis station amps-pdf
vha-code:=TTTTT
model-group:=PDF-PROFOUND
product:=City, Town & Spot Forecasts
issue-time:=20150215 0759 Z
station:=123456
station-99suffix:=INTL
init-time:=20150215 0300 Z
""".split("\n");

List<String> cafFileBlock = """prog=1h
control-points=7.000000, 7.000250, 7.018750, 7.045000, 7.105000, 7.258750, 7.675000, 9.500000, 10.750000
logn-pdf-values=-9.999820, -1.131157, -0.279547, -0.126680, -0.017522, -0.021517, -0.432122, -3.529888, -6.106577
curvature-values=3.920818, 0.337233, 0.019309, 0.018923, 0.024092, 0.036923, 0.154945, 0.000000
tail-left=0
tail-right=1
mean=5.516087
variance=1.111753
""".split("\n");
