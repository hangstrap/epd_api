import 'package:unittest/unittest.dart';
import 'package:mock/mock.dart';
import 'matchers.dart';

import '../bin/caf_file_decoder.dart' as caf;
import '../bin/timeseries_model.dart';


@proxy
class MockTimeseriesNode extends Mock implements TimeseriesNode {}

main() {
  group("create correct file name based on CAF file contents", () {
    test("check the pattern for a 99xxx station", () {
      String cafFileName = caf.fileNameForCafFile(cafFileHeader99xxxx);
      expect(cafFileName, equals("CityTownSpotForecasts/PDF-PROFOUND/201502150300Z/TTTTT/CityTownSpotForecasts.PDF-PROFOUND.201502150300Z.TTTTT.99647-INTL.caf"));
    });
    test("check the pattern for a non 99xxx station", () {
      String cafFileName = caf.fileNameForCafFile(cafFileHeader123456);
      expect(cafFileName, equals("CityTownSpotForecasts/PDF-PROFOUND/201502150300Z/TTTTT/CityTownSpotForecasts.PDF-PROFOUND.201502150300Z.TTTTT.123456.caf"));
    });
  });

  group("create correct file name based on TimeseriesAnalysis", () {
    test("check pattern for a 99xxx station", () {

      DateTime analysis = new DateTime.utc(2015, 2, 15, 3, 0);
      TimeseriesNode node = new TimeseriesNode.create("City, Town & Spot Forecasts", "PDF-PROFOUND", "TTTTT", "99647", "INTL");

      String cafFileName = caf.fileNameForTimeseriesAnalysis(node, analysis);
      expect(cafFileName, equals("CityTownSpotForecasts/PDF-PROFOUND/201502150300Z/TTTTT/CityTownSpotForecasts.PDF-PROFOUND.201502150300Z.TTTTT.99647-INTL.caf"));
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
        DateTime analysis  = new DateTime.utc(2015, 2, 15, 3, 00);
        expect( assembly.analysis, equals( analysis));
        checkEdition( assembly.editions[0], analysis);
      });
    });
    
    test( "throw meaningful error message when token missing", (){
      List<String> lines = ["aaaa=aaaa,bbbb=bbbb"];
      expect(() =>  caf.toTimeseriesNode( lines),  throwsA( formatExceptionMatching( "Could not find token 'product'"))); 
      
      
    });
    
    test( "", (){
      List<String> lines = ["aa=1", "bb=2" ,"cc=3"];

      String line = lines.firstWhere((String line) => line.indexOf("bb") == 0, orElse: throw "could not find 'bb'");
      expect( line, equals( "bb=2"));
    });
  });

  
}

void checkEdition( Edition edition,  DateTime analysis){

  expect(edition.analysisAt, equals(analysis));
  expect(edition.validFrom, equals(analysis.add(new Duration(hours: 1))));
  expect(edition.validTo, equals(analysis.add(new Duration(hours: 1))));
  expect(edition.datum['mean'], equals(5.516087));
  expect(edition.datum['control-points'], equals([1.587835,4.687500,5.524008]));
  expect(edition.datum['logn-pdf-values'], equals([-6.502432,-1.297167,-0.893834]));  
  expect(edition.datum['curvature-values'], equals([0.416317,0.094229,0.000001]));
  expect(edition.datum['tail-left'], equals(1));
  expect(edition.datum['tail-right'], equals(1));
  expect(edition.datum['variance'], equals(1.111753));
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
control-points=1.587835,4.687500,5.524008
logn-pdf-values=-6.502432,-1.297167,-0.893834
curvature-values=0.416317,0.094229,0.000001
tail-left=1
tail-right=1
mean=5.516087
variance=1.111753
""".split("\n");
