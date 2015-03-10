
import "dart:async";
import "package:quiver/cache.dart";

class ProductSource{
  
}


class Location{
  
}

class ElementSource{
  
}
class Edition{
  DateTime analysisAt;
  DateTime validFrom;
  DateTime validTo;
  var dartum;
}
class TimeseriesKey{
  Location location;
  ProductSource productsource;
  ElementSource elementsource;  
  DateTime analysisAt;
}

class TimeseriesDataCache{

  MapCache<TimeseriesKey, List<Edition>> cache = new MapCache.lru();
  
  Future<List<Edition>> getTimeseries( TimeseriesKey key, DateTime from, Duration period){

    //todo add a filter
    return cache.get( key, ifAbsent:loaderOnCacheMiss  );
   
  }
  Future<Map<TimeseriesKey, Edition>> getTimeseriesSet( List<TimeseriesKey> key, DateTime from, Duration period){
    
    //Create a set of futures, wait for them to return, then produce the map.
    return null;
  }
  
  
  Future<List<Edition>> loaderOnCacheMiss (TimeseriesKey key){
    return null;
  }
}