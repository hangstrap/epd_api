import 'package:intl/intl.dart';
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
  
  var formatter = new DateFormat('yyyyMMddHHmm');
  String analysisAt = formatter.format(key.analysisAt);
  String element = sanitise( key.element.name);
  String nameSuffix  = _createLocationSuffix( sanitise( key.location.name), key.location.suffex);
  
  
  
  
  return "${product}/${model}/${analysisAt}Z/${element}/${product}.${model}.${analysisAt}Z.${element}.${nameSuffix}.caf";
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
  String suffix = findToken( "station-99suffix");  
  String locationSuffix  = _createLocationSuffix(location, suffix);
  
  return "${product}/${model}/${analysis}/${element}/${product}.${model}.${analysis}.${element}.${locationSuffix}.caf";
  
}

String _createLocationSuffix( String name, String suffix){

    if(name.length==5 || name.length==6){
      if( name.indexOf("99") ==0){
        return "${name}-${suffix}";
      }
    }
    return name;
}