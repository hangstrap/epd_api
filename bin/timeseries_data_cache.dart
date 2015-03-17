
import "dart:async";
import "package:quiver/cache.dart";
import "package:quiver/async.dart";


class Product {
  final String name;
  Product(this.name);
}
class Model{
  final String name;
  Model(this.name);  
}


class Location{
  final String name;
  Location(this.name);  
}

class Element{
  final String name;
  Element(this.name);
}

class TimeseriesRootAnalysis{
  final Product product;
  final Model model;
  Location location;
  Element element;  
  final DateTime analysisAt;
  
  TimeseriesRootAnalysis( this.product, this.model, this.analysisAt );
}


class Edition{
  TimeseriesRootAnalysis key;
  DateTime analysisAt;
  DateTime validFrom;
  DateTime validTo;
  var dartum;
}

class TimeseriesAssembly{
  TimeseriesRootAnalysis key;
  List<Edition> editions;  
}

/**Used to load timeseres data when there is a cache miss*/
typedef   Future<TimeseriesAssembly> LoadTimeseres (TimeseriesRootAnalysis key);
 
class TimeseriesDataCache{

  LoadTimeseres loader;
  MapCache<TimeseriesRootAnalysis, TimeseriesAssembly> cache = new MapCache.lru();
  
  TimeseriesDataCache( this.loader);
  
  Future<TimeseriesAssembly> getTimeseries( TimeseriesRootAnalysis key, DateTime from, Duration period){

    print( "inside getTimeseries");
    
    //todo add a filter
    return cache.get( key, ifAbsent:loader);
   
  }
  
  
  Future<List<TimeseriesAssembly>> getTimeseriesSet( List<TimeseriesRootAnalysis> keys, DateTime from, Duration period){
    
    
    //Create a set of futures, wait for them to return, then produce the map.
    FutureGroup<TimeseriesAssembly> futures = new FutureGroup();
    keys.forEach( (TimeseriesRootAnalysis key) {
        futures.add( getTimeseries( key,  from, period));
      } 
    );
    
    return futures.future;
  }
  
}