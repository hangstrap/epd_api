import 'package:unittest/unittest.dart';
import 'package:mock/mock.dart';

import '../bin/timeseries_data_cache.dart';
import 'dart:async';
import 'package:quiver/time.dart';

@proxy
class MockTimeseriesAssemply extends Mock implements TimeseriesAssembly{}

void main() {



  
  test("basic", () {
    
    MockTimeseriesAssemply assembly = new MockTimeseriesAssemply();

    Future<TimeseriesAssembly> loadTimeseries(TimeseriesRootAnalysis key) {
      print("inside loadTimeseries");      
      return new Future.value( assembly);
    }


    TimeseriesDataCache cache = new TimeseriesDataCache(loadTimeseries);

    TimeseriesRootAnalysis key;
    Clock clock = new Clock();

    return new Future.value().then((_) {
      Future<TimeseriesAssembly> future = cache.getTimeseries(key, clock.now(), new Duration());
      expect(future, isNotNull);
      future.then( (TimeseriesAssembly a){
        
        expect( a, isNotNull);
        expect( a, same( assembly));
      } );
    });




  });

}
