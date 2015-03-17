import "dart:async";
import "timeseries_data_cache.dart";

class CAF{
  
}

class CafFileRetriever{
  
  Future<CAF> getCafFor( String filename){
    //TODO 
    //check the file system
    //then extract for back end
    return null;
  }
}

String fileNameForTimeseriesAnalysis( TimeseriesRootAnalysis key){
  
  String sanitise( String str){
    return str.replaceAll( new RegExp("[^0-9a-zA-Z/-]"), "");
  }
  
  String product = sanitise( key.product.name);
  String model = sanitise( key.model.name);
  String analysisAt = key.analysisAt.toIso8601String();
  return "${product}/${model}/${analysisAt}";
}

String fileNameForCafFile( List<String> cafFileContents){
  
  String findToken( String token){
    String line  = cafFileContents.firstWhere( (String line)=>line.indexOf( token)==0);
    return line.substring( token.length + 2);
  }
 
  String sanitise( String str){
    return str.replaceAll( new RegExp("[^0-9a-zA-Z/-]"), "");
  }
  
  String product = sanitise( findToken("product"));
  String model = sanitise( findToken("model-group"));
  String analysis = sanitise( findToken("init-time"));
  String element = sanitise( findToken("vha-code"));
  String location = sanitise( findToken( "station"));
  if( 5 == location.length || 6 == location.length ){
    if( location.indexOf( "99") == 0){
      String suffix = findToken( "station-99suffix");
      location = "${location}-${suffix}";
    }
  }
  
  return "${product}/${model}/${analysis}/${element}/${product}.${model}.${analysis}.${element}.${location}.caf";
  
}