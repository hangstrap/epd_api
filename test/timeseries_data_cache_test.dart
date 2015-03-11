import 'package:unittest/unittest.dart';
import '../bin/timeseries_data_cache.dart';
import 'dart:async';
import 'package:quiver/time.dart';

void main(){
  
  test( "basic", (){
    
    Future<TimeseriesAssembly> loadTimeseries (TimeseriesRootAnalysis key){
      
      print( "inside loadTimeseries");

      return null;
    }
    
    
    TimeseriesDataCache cache = new TimeseriesDataCache( loadTimeseries);
    
    TimeseriesRootAnalysis key;
    Clock clock  = new Clock();
    
    return new Future.value().then((_) {
      Future<TimeseriesAssembly> result = cache.getTimeseries(key, clock.now(), new Duration());
      expect( result, isNotNull);
         });

    
    
    
  });
  
}