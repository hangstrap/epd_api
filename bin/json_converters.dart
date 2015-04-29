library json_converters;

import 'package:jsonx/jsonx.dart' as jsonx;
import 'timeseries_catalogue.dart';
import 'timeseries_model.dart';



void setUpJsonConverters(){
  
  jsonx.objectToJsons[DateTime] = (DateTime input) => input.toIso8601String();  
  jsonx.jsonToObjects[DateTime] = (String input) => DateTime.parse( input);

  jsonx.objectToJsons[ TimeseriesCatalogue] = (TimeseriesCatalogue source) {          

    Map result = {};
    List catalogue = [];
    result[ "catalogue"] = catalogue;  
    
    source.catalogue.forEach( (TimeseriesNode node, Map<DateTime, CatalogueItem> analysiss){

      
    analysiss.forEach( (DateTime analysis, CatalogueItem item){
      catalogue.add(item);  
    });
    });
    return result;
  
  };

  
  jsonx.jsonToObjects[ TimeseriesCatalogue] = (Map rawMap){
    
    TimeseriesCatalogue result = new TimeseriesCatalogue();
    
//    Map catalogMap = rawMap ["catalogue"];
//    
//    catalogMap.forEach(( String nodeKey, Map  analysisis){
//      TimeseriesNode node = new TimeseriesNode.fromNamespace( nodeKey);
//      result.catalogue[node]=  {};
//      
//      analysisis.forEach( (String analysisStr, Map periodMap ){
//        
//        DateTime analysis = DateTime.parse(analysisStr);
//        Period period = jsonx.decode( jsonx.encode(periodMap), type:Period);
//        result.catalogue[node][analysis]= period;
//      });
//      
//    });
    
    return result;
  };
}
  