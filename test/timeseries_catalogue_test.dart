import "../bin/timeseries_catalogue.dart";
import "../bin/timeseries_model.dart";
import 'package:unittest/unittest.dart';
import '../bin/json_converters.dart';
import 'package:jsonx/jsonx.dart' as jsonx;
import '../bin/utils.dart';


main(){

  setUpJsonConverters();

  TimeseriesNode node = new TimeseriesNode.create("City Town & Spot Forecasts", "PDF-PROFOUND", "TTTTT", "01492", "INTL");
  DateTime analysisAt = new DateTime.utc(2013, 4, 1, 00, 00);
  DateTime am1 = new DateTime.utc(2013, 4, 1, 1, 0);
  DateTime am2 = new DateTime.utc(2013, 4, 1, 2, 0);
  DateTime am3 = new DateTime.utc(2013, 4, 1, 3, 0);


  group("TimeseriesCatalog", () {
    Uri uri = new Uri.http("caf-server", "aCafFile.caf");
    test("Add a single Analysis with a single spot edition", () {
      TimeseriesCatalogue catalog = new TimeseriesCatalogue();
      TimeseriesAssembly assembly = new TimeseriesAssembly.create(node, analysisAt, [new Edition.createMean(analysisAt, am1, am1, {})]);
      catalog.addAnalysis(assembly, uri);

      expect(catalog.numberOfNodes, equals(1));
      Map<DateTime, CatalogueItem> analysisMap = catalog.analysisFor(node);
      expect(analysisMap.length, equals(1));
      expect(analysisMap[analysisAt].analyis, equals(analysisAt));      
      expect(analysisMap[analysisAt].fromTo, equals(new Period.create(am1, am1)));
      
    });

    test("Add a single Analysis with a two interval period editions", () {
      TimeseriesCatalogue catalog = new TimeseriesCatalogue();
      TimeseriesAssembly assembly = new TimeseriesAssembly.create(node, analysisAt, [new Edition.createMean(analysisAt, am1, am2, {}), new Edition.createMean(analysisAt, am2, am3, {})]);
      catalog.addAnalysis(assembly, uri);

      expect(catalog.numberOfNodes, equals(1));
      Map<DateTime, CatalogueItem> analysisMap = catalog.analysisFor(node);
      expect(analysisMap.length, equals(1));
      expect(analysisMap[analysisAt].analyis, equals(analysisAt));
      expect(analysisMap[analysisAt].fromTo, equals(new Period.create(am1, am3)));
    });

    test("Add a two Analysis for the same node", () {
      TimeseriesCatalogue catalog = new TimeseriesCatalogue();
      TimeseriesAssembly assembly = new TimeseriesAssembly.create(node, analysisAt, [new Edition.createMean(analysisAt, am1, am1, {}),]);
      catalog.addAnalysis(assembly, uri);

      DateTime analysisAt2 = analysisAt.add(new Duration(hours: 1));
      TimeseriesAssembly assembly2 = new TimeseriesAssembly.create(node, analysisAt2, [new Edition.createMean(analysisAt, am2, am2, {}),]);
      catalog.addAnalysis(assembly2, new Uri.http("caf-server", "anotherCafFile.caf"));

      expect(catalog.numberOfNodes, equals(1));
      Map<DateTime, CatalogueItem> analysisMap = catalog.analysisFor(node);
      expect(analysisMap.length, equals(2));
      expect(analysisMap[analysisAt].fromTo, equals(new Period.create(am1, am1)));
      expect(analysisMap[analysisAt2].fromTo, equals(new Period.create(am2, am2)));
    });
    test("Json encoding of catalogue", () {
      TimeseriesCatalogue catalog = new TimeseriesCatalogue();
      TimeseriesAssembly assembly = new TimeseriesAssembly.create(node, analysisAt, [new Edition.createMean(analysisAt, am1, am1, {}),]);
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
      TimeseriesAssembly assembly = new TimeseriesAssembly.create(node, analysisAt, [new Edition.createMean(analysisAt, am1, am1, {})]);
      test("Should return false when uri not been added", () {
        expect(catalog.isDownloaded(uri), isFalse);
      });
      test("Should return true when uri is added", () {
        catalog.addAnalysis(assembly, uri);
        expect(catalog.isDownloaded(uri), isTrue);
      });
    });
  });  
  
  group( "", (){});
}

String jsonCatalog = """{
 "catalogue": {
  "City Town & Spot Forecasts/PDF-PROFOUND/TTTTT/01492.INTL": {
   "2013-04-01T00:00:00.000Z": {
    "fromTo": {
     "from": "2013-04-01T01:00:00.000Z",
     "to": "2013-04-01T01:00:00.000Z"
    },
    "source": "http://caf-server/aCafFile.caf"
   }
  }
 }
}""";
