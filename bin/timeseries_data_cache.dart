library timeseries_data_cache;


import "dart:async";
import "package:quiver/cache.dart";
import "package:quiver/async.dart";
import "timeseries_model.dart";


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