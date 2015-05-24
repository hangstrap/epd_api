import 'dart:io';


import 'package:unittest/unittest.dart';


import '../bin/timeseries_catalogue.dart';
import '../bin/timeseries_model.dart';
import '../bin/utils.dart';
import '../bin/json_converters.dart';

void main(){
  setUpJsonConverters();
  File jsonFile = new File( "temp/product/model/element/01492/catalog.json");

  TimeseriesNode node =
      new TimeseriesNode.create("product", "model", "element", "01492", "INTL");

  
Directory outputDirectory;
  CataloguePersister underTest;
  setUp(() {
    outputDirectory = new Directory("temp/");
    if (outputDirectory.existsSync()) {
      outputDirectory.deleteSync(recursive: true);
    }
    
    underTest = new CataloguePersister(outputDirectory);
  });
  
  test( "when no catalog.json file exist should return empty map",() async{
    
    Map<TimeseriesNode, Map<DateTime, CatalogueItem>> result = await underTest.loadFromDisk();
    expect( result.length, equals(0));
    
  });
  
  test( "saving the map should store it on the disk", () async{
    
    DateTime analysis = new DateTime(2015, 5,15);
    CatalogueItem item = new CatalogueItem.create(node, analysis, new Period.create(analysis, analysis));
    DateTime analysis2 = new DateTime(2015, 5,16);
    CatalogueItem item2 = new CatalogueItem.create(node, analysis2, new Period.create(analysis2, analysis2));

    
    Map<DateTime, CatalogueItem> map = { analysis: item, 
      analysis2:item2}; 
    
    await underTest.save(node, map);
    
    expect( jsonFile.existsSync(),isTrue);
    expect( jsonFile.readAsStringSync(), equals( JSON));
    
  });
  test( "should load the map if it on the disk", () async{
    Directory newParent = jsonFile.parent;
    if( ! await newParent.exists()){
      await newParent.create(recursive:true);
    }
    jsonFile.writeAsStringSync( JSON);

    Map<TimeseriesNode, Map<DateTime, CatalogueItem>> result = await underTest.loadFromDisk();
    expect( result.length, equals(1));
    Map<DateTime, CatalogueItem> analysisis = result[node];
    expect( analysisis.length, equals(2));
    DateTime analysis = new DateTime(2015, 5,15);
    CatalogueItem item = analysisis[analysis];
    expect( item.analyis, equals(analysis));
    expect( item.fromTo, equals(new Period.create(analysis, analysis)));
  });  
}

String JSON = """[
 {
  "node": {
   "product": "product",
   "model": "model",
   "element": "element",
   "locationName": "01492",
   "locationSuffix": "INTL"
  },
  "analyis": "2015-05-15T00:00:00.000",
  "fromTo": {
   "from": "2015-05-15T00:00:00.000",
   "toEx": "2015-05-15T00:00:00.000"
  }
 },
 {
  "node": {
   "product": "product",
   "model": "model",
   "element": "element",
   "locationName": "01492",
   "locationSuffix": "INTL"
  },
  "analyis": "2015-05-16T00:00:00.000",
  "fromTo": {
   "from": "2015-05-16T00:00:00.000",
   "toEx": "2015-05-16T00:00:00.000"
  }
 }
]""";
