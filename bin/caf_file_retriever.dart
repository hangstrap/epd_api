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

String createCafFileName( List<String> cafFileContents){
  
  String findToken( String token){
    String line  = cafFileContents.firstWhere( (String line)=>line.indexOf( "product")==0);
    return line.substring( token.length + 2);
  }
 
  String sanitise( String str){
    return str.toLowerCase().replaceAll("[ ,&]", "");
  }
  
  String product = sanitise( findToken("product"));
  
  return product;
}