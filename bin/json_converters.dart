library json_converters;

import 'package:jsonx/jsonx.dart' as jsonx;
import 'timeseries_model.dart';


void setUpJsonConverters(){
  
  jsonx.objectToJsons[DateTime] = (DateTime input) => input.toIso8601String();  
  jsonx.jsonToObjects[DateTime] = (String input) => DateTime.parse( input);
/*
  //TimeseriesCatalog cannot directly be converted to JSON, as keys in maps are objects, not strings.
  //Hence this messy convertsion
  jsonx.objectToJsons[ TimeseriesCatalog] = (TimeseriesCatalog timeseriesCatalog) {

     
    var result = {};
    result["catalog"] = {};
    
    timeseriesCatalog.catalogue.forEach( (TimeseriesNode node, Map<DateTime, Period> analysies){
      
      Map<String, Period>  map ={};
      
      analysies.forEach( (analysis, period){
        map[ analysis.toIso8601String()] = period;          
      });
      
      result["catalog"][node.toString()]= map;
      
    });
    
    return result;
  };
  ///
  ///
  ///
  jsonx.jsonToObjects[ TimeseriesCatalog] = (Map rawMap){
    
    TimeseriesCatalog result = new TimeseriesCatalog();
    
    Map catalogMap = rawMap ["catalog"];
    
    catalogMap.forEach(( String nodeKey, Map  analysisis){
      TimeseriesNode node = new TimeseriesNode.fromNamespace( nodeKey);
      result.catalogue[node]=  {};
      
      analysisis.forEach( (String analysisStr, Map periodMap ){
        
        DateTime analysis = DateTime.parse(analysisStr);
        Period period = jsonx.decode( jsonx.encode(periodMap), type:Period);
        result.catalogue[node][analysis]= period;
      });
      
    });
    
    return result;
  };
*/
}

