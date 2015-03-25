
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
  final String suffex;
  Location(this.name, this.suffex);
  
}

class Element{
  final String name;
  Element(this.name);
}

class TimeseriesAnalysis{
  final Product product;
  final Model model;
  final Location location;
  final Element element;  
  final DateTime analysisAt;
  
  TimeseriesAnalysis( this.product, this.model, this.analysisAt, this.element, this.location );
}


class Edition{ 
  final TimeseriesAnalysis analysis;
  final DateTime validFrom;
  final DateTime validTo;

  final Map dartum;
  
  Edition.createMean ( this.analysis, this.validFrom, this.validTo, this.dartum );
      
}

class TimeseriesAssembly{
  //TODO add a equals method
  
  final TimeseriesAnalysis key;
  final List<Edition> editions;
  TimeseriesAssembly( this.key, this.editions);
}

/**Used to load timeseres data when there is a cache miss*/
typedef   Future<TimeseriesAssembly> LoadTimeseres (TimeseriesAnalysis key);
 
class TimeseriesDataCache{

  LoadTimeseres loader;
  MapCache<TimeseriesAnalysis, TimeseriesAssembly> cache = new MapCache.lru();
  
  TimeseriesDataCache( this.loader);
  
  Future<TimeseriesAssembly> getTimeseries( TimeseriesAnalysis key, DateTime from, Duration period){

    print( "inside getTimeseries");
    
    //todo add a filter
    return cache.get( key, ifAbsent:loader);
   
  }
  
  
  Future<List<TimeseriesAssembly>> getTimeseriesSet( List<TimeseriesAnalysis> keys, DateTime from, Duration period){
    
    
    //Create a set of futures, wait for them to return, then produce the map.
    FutureGroup<TimeseriesAssembly> futures = new FutureGroup();
    keys.forEach( (TimeseriesAnalysis key) {
        futures.add( getTimeseries( key,  from, period));
      } 
    );
    
    return futures.future;
  }
  
}