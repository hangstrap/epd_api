import "../bin/timeseries_catalogue.dart";
import "../bin/timeseries_model.dart";
import 'package:unittest/unittest.dart';
import '../bin/json_converters.dart';
import 'package:jsonx/jsonx.dart' as jsonx;
import '../bin/utils.dart';


main(){

  setUpJsonConverters();

  TimeseriesNode node = new TimeseriesNode.create("City Town & Spot Forecasts", "PDF-PROFOUND", "TTTTT", "01492", "INTL");
  DateTime _0am = new DateTime.utc(2013, 4, 1, 00, 00);
  
  DateTime beforeAnalysis = _0am.subtract( new Duration( hours:1)); 
  DateTime wellBeforeAnalysis = _0am.subtract( new Duration( hours:2));
  
  DateTime _1am = _0am.add( new Duration( hours:1));
  DateTime _2am = _0am.add( new Duration( hours:2));
  DateTime _3am = _0am.add( new Duration( hours:3));
  DateTime _4am = _0am.add( new Duration( hours:4));
  DateTime _5am = _0am.add( new Duration( hours:5));
  DateTime _6am = _0am.add( new Duration( hours:6));
  
  DateTime afterAnalysis = _0am.add( new Duration( hours:100)); 
  DateTime wellAfterAnalysis = _0am.add( new Duration( hours:101));


  group("TimeseriesCatalog", () {
    Uri uri = new Uri.http("caf-server", "aCafFile.caf");
    test("Add a single Analysis with a single spot edition", () {
      TimeseriesCatalogue catalog = new TimeseriesCatalogue();
      TimeseriesAssembly assembly = new TimeseriesAssembly.create(node, _0am, [new Edition.createMean(_0am, _1am, _1am, {})]);
      catalog.addAnalysis(assembly, uri);

      expect(catalog.numberOfNodes, equals(1));
      Map<DateTime, CatalogueItem> analysisMap = catalog.analysissFor(node);
      expect(analysisMap.length, equals(1));
      expect(analysisMap[_0am].analyis, equals(_0am));      
      expect(analysisMap[_0am].fromTo, equals(new Period.create(_1am, _1am)));
      
    });

    test("Add a single Analysis with a two interval period editions", () {
      TimeseriesCatalogue catalog = new TimeseriesCatalogue();
      TimeseriesAssembly assembly = new TimeseriesAssembly.create(node, _0am, [new Edition.createMean(_0am, _1am, _2am, {}), new Edition.createMean(_0am, _2am, _3am, {})]);
      catalog.addAnalysis(assembly, uri);

      expect(catalog.numberOfNodes, equals(1));
      Map<DateTime, CatalogueItem> analysisMap = catalog.analysissFor(node);
      expect(analysisMap.length, equals(1));
      expect(analysisMap[_0am].analyis, equals(_0am));
      expect(analysisMap[_0am].fromTo, equals(new Period.create(_1am, _3am)));
    });

    test("Add a two Analysis for the same node", () {
      TimeseriesCatalogue catalog = new TimeseriesCatalogue();
      TimeseriesAssembly assembly = new TimeseriesAssembly.create(node, _0am, [new Edition.createMean(_0am, _1am, _1am, {}),]);
      catalog.addAnalysis(assembly, uri);

      DateTime analysisAt2 = _0am.add(new Duration(hours: 1));
      TimeseriesAssembly assembly2 = new TimeseriesAssembly.create(node, analysisAt2, [new Edition.createMean(analysisAt2, _2am, _2am, {}),]);
      catalog.addAnalysis(assembly2, new Uri.http("caf-server", "anotherCafFile.caf"));

      expect(catalog.numberOfNodes, equals(1));
      Map<DateTime, CatalogueItem> analysisMap = catalog.analysissFor(node);
      expect(analysisMap.length, equals(2));
      expect(analysisMap[_0am].fromTo, equals(new Period.create(_1am, _1am)));
      expect(analysisMap[analysisAt2].fromTo, equals(new Period.create(_2am, _2am)));
    });
    test("Json encoding of catalogue", () {
      TimeseriesCatalogue catalog = new TimeseriesCatalogue();
      TimeseriesAssembly assembly = new TimeseriesAssembly.create(node, _0am, [new Edition.createMean(_0am, _1am, _1am, {}),]);
      catalog.addAnalysis(assembly, uri);
      String json = jsonx.encode(catalog, indent: ' ');
      expect(json, equals(jsonCatalog));
    });
    test("Json decoding of catalog", () {
      TimeseriesCatalogue catalog = jsonx.decode(jsonCatalog, type: TimeseriesCatalogue);
      //test it by coverting it back again
      String json = jsonx.encode(catalog, indent: ' ');
      expect(json, equals(jsonCatalog));
    });
    group("isDownloaded should return correctly", () {
      TimeseriesCatalogue catalog = new TimeseriesCatalogue();
      TimeseriesAssembly assembly = new TimeseriesAssembly.create(node, _0am, [new Edition.createMean(_0am, _1am, _1am, {})]);
      test("Should return false when uri not been added", () {
        expect(catalog.isDownloaded(uri), isFalse);
      });
      test("Should return true when uri is added", () {
        catalog.addAnalysis(assembly, uri);
        expect(catalog.isDownloaded(uri), isTrue);
      });
    });
    
    group( "findAnalysisCoveredByPeriod", (){
      TimeseriesCatalogue catalog;
      TimeseriesAssembly assembly00 = new TimeseriesAssembly.create(node, _0am, [new Edition.createMean(_0am, _0am, _3am, {})]);
      TimeseriesAssembly assembly01 = new TimeseriesAssembly.create(node, _1am, [new Edition.createMean(_1am, _1am, _4am, {})]);
      TimeseriesAssembly assembly02 = new TimeseriesAssembly.create(node, _2am, [new Edition.createMean(_2am, _2am, _5am, {})]);      
      
      setUp((){        
        catalog = new TimeseriesCatalogue();
        catalog.addAnalysis( assembly00, uri);
        catalog.addAnalysis( assembly01, uri);
        catalog.addAnalysis( assembly02, uri);

      });
      
      test( "an unknown node should return a empty map", (){
        TimeseriesCatalogue catalog = new TimeseriesCatalogue();
        expect( catalog.findAnalysissForPeriod( node, new Period.create( _1am, _2am)),isEmpty);
      });
      test( "an period before the analysis should return a empty map", (){
        
        catalog.addAnalysis( assembly00, uri);        
        expect( catalog.findAnalysissForPeriod( node, new Period.create( wellBeforeAnalysis, beforeAnalysis)),isEmpty);
      });

      test( "an period after the analysis should return a empty map", (){
        
        expect( catalog.findAnalysissForPeriod( node, new Period.create( afterAnalysis, wellAfterAnalysis)),isEmpty);
      });
      test( "an period that covers all the anaysis period should return all analysis", (){
        
        List<DateTime> result = catalog.findAnalysissForPeriod( node, new Period.create( _0am, _5am));
        expect( result.length,equals(3));
        expect( result.elementAt(0),equals( _0am ));
        expect( result.elementAt(1),equals( _1am ));
        expect( result.elementAt(2),equals( _2am ));
      });
      test( "an period that is totally within the last anaysis period should only return the last analysis", (){
        
        List<DateTime> result = catalog.findAnalysissForPeriod( node, new Period.create( _2am, _5am));
        expect( result.length,equals(1));
        expect( result.elementAt(0),equals( _2am ));
      });
      test( "an period that intersects with the last two anaysis periods should return the last two analysis", (){

        TimeseriesAssembly assembly03 = new TimeseriesAssembly.create(node, _3am, [new Edition.createMean(_3am, _5am, _6am, {})]);      
        catalog.addAnalysis(assembly03, uri);

        List<DateTime> result = catalog.findAnalysissForPeriod( node, new Period.create( _4am, _6am));
        expect( result.length,equals(2));
        expect( result.elementAt(0),equals( _2am ));
        expect( result.elementAt(1),equals( _3am ));
      });

    });
  });  
  

}

String jsonCatalog = """{
 "catalogue": {
  "City Town & Spot Forecasts/PDF-PROFOUND/TTTTT/01492.INTL": {
   "2013-04-01T00:00:00.000Z": {
    "fromTo": {
     "from": "2013-04-01T01:00:00.000Z",
     "toEx": "2013-04-01T01:00:00.000Z"
    },
    "source": "http://caf-server/aCafFile.caf"
   }
  }
 }
}""";
