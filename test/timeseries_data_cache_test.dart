import 'package:unittest/unittest.dart';
import 'package:mock/mock.dart';

import '../bin/timeseries_data_cache.dart';
import 'dart:async';
import 'package:quiver/time.dart';

@proxy
class MockTimeseriesAssemply extends Mock implements TimeseriesAssembly {}
class MockTimeseriesRootAnalysis extends Mock implements TimeseriesRootAnalysis{} 
void main() {

  group("getTimeseries", () {
    
    MockTimeseriesRootAnalysis key  = new MockTimeseriesRootAnalysis();
    MockTimeseriesAssemply assembly = new MockTimeseriesAssemply();
    Clock clock = new Clock();
    Duration period = new Duration();
    
    test("on cache miss should return assembly instance provided by loaded", () {

      TimeseriesDataCache cache = new TimeseriesDataCache((_) => new Future.value(assembly));

      Future<TimeseriesAssembly> future = cache.getTimeseries(key, clock.now(), period);

      return future.then((_) {

        //test the future returned by getTimeseries
        future.then((TimeseriesAssembly a) {
          expect(a, isNotNull);
          expect(a, same(assembly));
        });
      });
    });
  });

}
