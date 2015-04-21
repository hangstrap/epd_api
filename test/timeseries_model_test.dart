import 'package:unittest/unittest.dart';
import '../bin/timeseries_model.dart';
import 'package:jsonx/jsonx.dart' as jsonx;
import'../bin/json_converters.dart';

TimeseriesNode node = new TimeseriesNode.create(
    "City Town & Spot Forecasts", "PDF-PROFOUND", "TTTTT", "01492", "INTL");
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
  group("TimeseriesNode", (){
     
     test("convert to namespace string", (){
       expect( node.toNamespace(), equals( "City Town & Spot Forecasts/PDF-PROFOUND/TTTTT/01492.INTL"));       
     });
     test("convert from namespace string", (){
       expect( new TimeseriesNode.fromNamespace("City Town & Spot Forecasts/PDF-PROFOUND/TTTTT/01492.INTL"), equals( node));       
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
        TimeseriesAssembly  result = new  TimeseriesAssembly.filter(assembly, null, null);
        expect(result.editions, equals(editions));
        expect(result.node, same( node));
        expect( result.analysis, equals( analysisAt));
      });

      test("On edge of limits", () {
        
        
        List<Edition> result = new  TimeseriesAssembly.filter(assembly, am1, new Duration(hours: 3)).editions;
        expect(result.length, equals(3));
        expect(result[0], equals(editions[0]));
        expect(result[1], equals(editions[1]));
        expect(result[2], equals(editions[2]));
      });

      test("Interval of one hour", () {
        List<Edition> result = new  TimeseriesAssembly.filter(assembly, am2, new Duration(hours: 1)).editions;

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
        List<Edition> result = new  TimeseriesAssembly.filter(assembly,null, null).editions;
        expect(result, equals(editions));
      });

      test("On edge of limits", () {
        List<Edition> result = new  TimeseriesAssembly.filter(assembly,am1, new Duration(hours: 3)).editions;
        expect(result.length, equals(3));
        expect(result[0], equals(editions[0]));
        expect(result[1], equals(editions[1]));
        expect(result[2], equals(editions[2]));
      });

      test("Interval of one hour", () {
        List<Edition> result = new  TimeseriesAssembly.filter(assembly, am2, new Duration(hours: 1)).editions;

        expect(result.length, equals(3));
        expect(result[0], equals(editions[0]));
        expect(result[1], equals(editions[1]));
        expect(result[2], equals(editions[2]));
      });
    });
  });
  group( "TimeseriesCatalog", (){

    test("Add a single Analysis with a single spot edition", (){
      TimeseriesCatalogue catalog = new TimeseriesCatalogue();
      TimeseriesAssembly assembly = new TimeseriesAssembly.create(node, analysisAt,[ 
        new  Edition.createMean(analysisAt, am1, am1, {})]);
      catalog.addAnalysis( assembly);
      
      expect( catalog.numberOfNodes, equals( 1));
      Map<DateTime, Period> analysisMap = catalog.analysisFor( node);
      expect( analysisMap.length, equals( 1));
      expect( analysisMap[ analysisAt], equals( new Period.create( am1, am1)));
      
      
    });

    test("Add a single Analysis with a two interval period editions", (){
      TimeseriesCatalogue catalog = new TimeseriesCatalogue();
      TimeseriesAssembly assembly = new TimeseriesAssembly.create(node, analysisAt,[ 
        new  Edition.createMean(analysisAt, am1, am2, {}),
        new  Edition.createMean(analysisAt, am2, am3, {})
        ]);
      catalog.addAnalysis( assembly);
      
      expect( catalog.numberOfNodes, equals( 1));
      Map<DateTime, Period> analysisMap = catalog.analysisFor( node);
      expect( analysisMap.length, equals( 1));
      expect( analysisMap[ analysisAt], equals( new Period.create(am1, am3)));      
    });


    test("Add a two Analysis for the same node", (){
      TimeseriesCatalogue catalog = new TimeseriesCatalogue();
      TimeseriesAssembly assembly = new TimeseriesAssembly.create(node, analysisAt,[ 
        new  Edition.createMean(analysisAt, am1, am1, {}),
        ]);      
      catalog.addAnalysis( assembly);
      
      DateTime analysisAt2 = analysisAt.add( new Duration(hours:1));
      TimeseriesAssembly assembly2 = new TimeseriesAssembly.create(node, analysisAt2,[ 
        new  Edition.createMean(analysisAt, am2, am2, {}),
        ]);
       catalog.addAnalysis(assembly2);
      
      expect( catalog.numberOfNodes, equals( 1));
      Map<DateTime, Period> analysisMap = catalog.analysisFor( node);
      expect( analysisMap.length, equals( 2));
      expect( analysisMap[ analysisAt], equals( new Period.create( am1, am1)));      
      expect( analysisMap[ analysisAt2], equals( new Period.create( am2, am2)));         
      
    });
    test("Json encoding of catalogue", (){
               
      TimeseriesCatalogue catalog = new TimeseriesCatalogue();
      TimeseriesAssembly assembly = new TimeseriesAssembly.create(node, analysisAt,[ 
        new  Edition.createMean(analysisAt, am1, am1, {}),
        ]);      
      catalog.addAnalysis( assembly);
      String json = jsonx.encode( catalog, indent:' ');
      expect( json,equals(  jsonCatalog)); 
    });
    test( "Json decoding of catalog", (){
      TimeseriesCatalogue catalog = jsonx.decode( jsonCatalog, type:TimeseriesCatalogue);
      //test it by coverting it back again
      String json = jsonx.encode( catalog, indent:' ');
      expect( json,equals(  jsonCatalog)); 
      
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

String jsonCatalog="""{
 "catalogue": {
  "City Town & Spot Forecasts/PDF-PROFOUND/TTTTT/01492.INTL": {
   "2013-04-01T00:00:00.000Z": {
    "from": "2013-04-01T01:00:00.000Z",
    "to": "2013-04-01T01:00:00.000Z"
   }
  }
 }
}""";

