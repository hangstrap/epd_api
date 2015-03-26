import 'package:unittest/unittest.dart';
import 'package:mock/mock.dart';


import '../bin/caf_file_retriever.dart' as caf;
import '../bin/timeseries_data_cache.dart';


@proxy
class MockTimeseriesAnalysis extends Mock implements TimeseriesAnalysis {}

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

      DateTime analysisAt = new DateTime.utc(2015, 2, 15, 3, 0);
      TimeseriesAnalysis key = new TimeseriesAnalysis(new Product("City, Town & Spot Forecasts"), new Model("PDF-PROFOUND"), analysisAt, new Element("TTTTT"), new Location("99647", "INTL"));

      String cafFileName = caf.fileNameForTimeseriesAnalysis(key);
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


        TimeseriesAnalysis analysis = caf.toTimeseriesAnalysis(cafFileHeader99xxxx);

        check99647Analysis(analysis);
      });
    });

    group("parse of data block", () {
      test("", () {
        MockTimeseriesAnalysis analysis = new MockTimeseriesAnalysis();
        DateTime analysisAt = new DateTime.utc(2015, 2, 15, 3, 00);
        analysis.when(callsTo("get analysisAt")).thenReturn(analysisAt, 3);

        Edition edition = caf.toEdition(cafFileBlock, analysis);
        checkEdition(edition, analysis);
      });
    });

    group("parse of entire file", () {
      List<String> lines = [];
      lines.addAll(cafFileHeader99xxxx);
      lines.addAll(cafFileBlock);


      test("", () {

        TimeseriesAssembly assembly = caf.toTimeseiesAssembly(lines);
        check99647Analysis(assembly.key);
        checkEdition( assembly.editions[0], assembly.key);
      });
    });
  });

  group( "CafFileRetriever", (){
    caf.CafFileRetriever retriever = new caf.CafFileRetriever("../data");
    
    test("Load real data",(){
      TimeseriesAnalysis analysis = new TimeseriesAnalysis( new Product("City Town & Spot Forecasts"), new Model("PDF-PROFOUND"), 
          new DateTime.utc( 2015, 02, 15, 03, 00), 
          new Element("TTTTT"), 
          new Location("01492", "INTL"));
      
      return retriever.loadTimeseres( analysis).then((TimeseriesAssembly assembly){
        
        //test some arbitary data
        expect( assembly.key.analysisAt, equals( new DateTime.utc(2015, 02, 15, 03, 00)));
        expect( assembly.key.location.name, equals( "01492"));
        expect( assembly.editions.length, equals(361));
        expect( assembly.editions[0].dartum["mean"], equals(-0.226023));
      });
      
    });    
    
  });
}

void checkEdition( Edition edition,  TimeseriesAnalysis analysis){

  expect(edition.analysis, same(analysis));
  expect(edition.validFrom, equals(analysis.analysisAt.add(new Duration(hours: 1))));
  expect(edition.validTo, equals(analysis.analysisAt.add(new Duration(hours: 1))));
  expect(edition.dartum['mean'], equals(5.516087));

}

void check99647Analysis(TimeseriesAnalysis analysis) {
  expect(analysis.product.name, equals('City, Town & Spot Forecasts'));
  expect(analysis.model.name, equals('PDF-PROFOUND'));
  expect(analysis.location.name, equals('99647'));
  expect(analysis.location.suffex, equals('INTL'));
  expect(analysis.element.name, equals('TTTTT'));
  expect(analysis.analysisAt, equals(new DateTime.utc(2015, 2, 15, 3, 00)));
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
control-points=1.587835,4.687500,5.524008,5.572896,5.621868,5.671056,5.720611,5.770676,5.821387,5.872947,5.925555,5.979398,6.034721,6.091823,6.151055,9.233932
logn-pdf-values=-6.502432,-1.297167,-0.893834,-0.894224,-0.897291,-0.903001,-0.912123,-0.923514,-0.937722,-0.956673,-0.977992,-1.002985,-1.032189,-1.066187,-1.105389,-6.431419
curvature-values=0.416317,0.094229,0.000001,-0.000002,-0.000003,-0.000020,-0.000029,-0.000051,-0.000086,-0.000111,-0.000154,-0.000211,-0.000290,-0.000381,0.608794
tail-left=1
tail-right=1
mean=5.516087
variance=1.111753
""".split("\n");
