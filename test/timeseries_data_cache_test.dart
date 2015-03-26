import 'package:unittest/unittest.dart';
import 'package:mock/mock.dart';
import '../bin/timeseries_model.dart';
import '../bin/timeseries_data_cache.dart';
import 'dart:async';
import 'package:quiver/time.dart';

@proxy
class MockTimeseriesAssemply extends Mock implements TimeseriesAssembly {}
@proxy
class MockTimeseriesAnalysis extends Mock implements TimeseriesAnalysis {}


void main() {

  group("getTimeseries", () {

    MockTimeseriesAnalysis key = new MockTimeseriesAnalysis();
    MockTimeseriesAssemply assembly = new MockTimeseriesAssemply();
    Clock clock = new Clock();
    Duration period = new Duration();

    test("on cache miss should return assembly instance provided by loaded", () {

      TimeseriesDataCache cache = new TimeseriesDataCache((_) => new Future.value(assembly));

      Future<TimeseriesAssembly> future = cache.getTimeseries(key, clock.now(), period);


        //test the future returned by getTimeseries
      return future.then((TimeseriesAssembly a) {
          expect(a, isNotNull);
          expect(a, same(assembly));
        });
    });

    test("on cache hit, should not access the loader", () {

      TimeseriesDataCache cache = new TimeseriesDataCache((_) {
        return new Future.error("cache accessed loader");
      });
      //add item to cache
    cache.cache.set(key, assembly);

      Future<TimeseriesAssembly> future = cache.getTimeseries(key, clock.now(), period);

        //test the future returned by getTimeseries
        return future.then((TimeseriesAssembly a) {
          expect(a, isNotNull);
          expect(a, same(assembly));
        });
    });
    test("exceptions", () {

      TimeseriesDataCache cache = new TimeseriesDataCache((_) {
        return new Future.error( "back end failure");
      });

      Future<TimeseriesAssembly> future = cache.getTimeseries(key, clock.now(), period);

      return future.catchError((a) {

        //test the future returned by getTimeseries
          expect(a, isNotNull);
          expect(a, equals("back end failure"));
      });
    });
 
    group("getTimeseriesSet", () {

      MockTimeseriesAnalysis key1 = new MockTimeseriesAnalysis();
      MockTimeseriesAssemply assembly1 = new MockTimeseriesAssemply();

      MockTimeseriesAnalysis key2 = new MockTimeseriesAnalysis();
      MockTimeseriesAssemply assembly2 = new MockTimeseriesAssemply();


      Clock clock = new Clock();
      Duration period = new Duration();


      test("will call getTimeseries for each key", () {

        TimeseriesDataCache cache = new TimeseriesDataCache((key) {
          if (key == key1) {
            return new Future.value(assembly1);
          }
          if (key == key2) {
            return new Future.value(assembly2);
          }
        });


        Future<List<TimeseriesAssembly>> future = cache.getTimeseriesSet([key1, key2], clock.now(), period);

        return future.then((List<TimeseriesAssembly> results) {
          expect(results, isNotNull);
          expect(results.length, equals(2));
          expect(results[0], same(assembly1));
          expect(results[1], same(assembly2));
        });

      });

      test("when backend returns failing future, then entire set fails ", () {

        TimeseriesDataCache cache = new TimeseriesDataCache((key) {
          if (key == key1) {
            return new Future.value(assembly1);
          }
          if (key == key2) {
            return new Future.error( "bugger");
                
          }
        });


        Future<List<TimeseriesAssembly>> future = cache.getTimeseriesSet([key1, key2], clock.now(), period);

        return future.catchError(( e) {
          expect(e, equals( "bugger"));
        });

      });

    });
  });

}
