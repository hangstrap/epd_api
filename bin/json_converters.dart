library json_converters;

import 'package:jsonx/jsonx.dart' as jsonx;
import 'timeseries_model.dart';



void setUpJsonConverters(){
  
  jsonx.objectToJsons[DateTime] = (DateTime input) => input.toIso8601String();  
  jsonx.jsonToObjects[DateTime] = (String input) => DateTime.parse( input);

  jsonx.objectToJsons[ TimeseriesCatalogue] = (TimeseriesCatalogue source) {          

    Map result = {};
    Map catalogue = {};
    result[ "catalogue"] = catalogue;  
    
    source.catalogue.forEach( (TimeseriesNode node, Map<DateTime, Period> analysiss){
      
      Map<String, Period> analysisMap = {};
      catalogue[ node.toNamespace()] = analysisMap;
      analysiss.forEach( (DateTime analysis, Period period){
          analysisMap[ analysis.toIso8601String()] = period;
      });
    });
    return result;
  
  };

  
  jsonx.jsonToObjects[ TimeseriesCatalogue] = (Map rawMap){
    
    TimeseriesCatalogue result = new TimeseriesCatalogue();
    
    Map catalogMap = rawMap ["catalogue"];
    
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
}
  