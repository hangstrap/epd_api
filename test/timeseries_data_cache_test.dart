import 'package:unittest/unittest.dart';
import 'package:mock/mock.dart';
import '../bin/timeseries_model.dart';
import '../bin/timeseries_data_cache.dart';
import 'dart:async';

@proxy
class MockTimeseriesAssemply extends Mock implements TimeseriesAssembly {}
@proxy
class MockTimeseriesNode extends Mock implements TimeseriesNode {}


void main() {

  group("getTimeseries", () {

    MockTimeseriesNode node = new MockTimeseriesNode();
    MockTimeseriesAssemply assembly = new MockTimeseriesAssemply();
    DateTime analysis = new DateTime.now();
    DateTime validFrom = new DateTime.now();
    Duration period = new Duration();

    test("on cache miss should return assembly instance provided by loaded", () {

      Future<TimeseriesAssembly> timeseriesLoader (TimeseriesNode key, DateTime analysis){
        return new Future.value(assembly);
      }

      
      TimeseriesDataCache cache = new TimeseriesDataCache(timeseriesLoader);

      Future<TimeseriesAssembly> future = cache.getTimeseriesAnalysis(node, analysis, validFrom, period);


        //test the future returned by getTimeseries
      return future.then((TimeseriesAssembly a) {
          expect(a, isNotNull);
          expect(a, same(assembly));
        });
    });

    test("on cache hit, should not access the loader", () {

      
      Future<TimeseriesAssembly> timeseriesLoader (TimeseriesNode key, DateTime analysis){
        return new Future.error("cache accessed loader");
      }
      
      
      TimeseriesDataCache cache = new TimeseriesDataCache(timeseriesLoader);
      //preloader add item to cache      
      cache.cache.set( new Key( node, analysis), assembly);

      Future<TimeseriesAssembly> future = cache.getTimeseriesAnalysis(node, analysis, validFrom, period);

        //test the future returned by getTimeseries
        return future.then((TimeseriesAssembly a) {
          expect(a, isNotNull);
          expect(a, same(assembly));
        });
    });
    test("exceptions", () {

      Future<TimeseriesAssembly> timeseriesLoader (TimeseriesNode key, DateTime analysis){
        return new Future.error( "back end failure");
      }

      TimeseriesDataCache cache = new TimeseriesDataCache(timeseriesLoader);
      
      Future<TimeseriesAssembly> future = cache.getTimeseriesAnalysis(node, analysis, validFrom, period);

      return future.catchError((a) {

        //test the future returned by getTimeseries
          expect(a, isNotNull);
          expect(a, equals("back end failure"));
      });
    });
 
    group("getTimeseriesSet", () {

      MockTimeseriesNode key1 = new MockTimeseriesNode();
      MockTimeseriesAssemply assembly1 = new MockTimeseriesAssemply();

      MockTimeseriesNode key2 = new MockTimeseriesNode();
      MockTimeseriesAssemply assembly2 = new MockTimeseriesAssemply();


      DateTime analysis = new DateTime.now();
      DateTime validFrom = new DateTime.now();
      Duration period = new Duration();


      test("will call getTimeseries for each key", () {

        TimeseriesDataCache cache = new TimeseriesDataCache((key, analysis) {
          if (key == key1) {
            return new Future.value(assembly1);
          }
          if (key == key2) {
            return new Future.value(assembly2);
          }
        });


        Future<List<TimeseriesAssembly>> future = cache.getTimeseriesAnalysisSet([key1, key2], analysis, validFrom, period);

        return future.then((List<TimeseriesAssembly> results) {
          expect(results, isNotNull);
          expect(results.length, equals(2));
          expect(results[0], same(assembly1));
          expect(results[1], same(assembly2));
        });

      });

      test("when backend returns failing future, then entire set fails ", () {

        TimeseriesDataCache cache = new TimeseriesDataCache((key, analysis) {
          if (key == key1) {
            return new Future.value(assembly1);
          }
          if (key == key2) {
            return new Future.error( "bugger");
                
          }
        });


        Future<List<TimeseriesAssembly>> future = cache.getTimeseriesAnalysisSet([key1, key2], analysis, validFrom, period);

        return future.catchError(( e) {
          expect(e, equals( "bugger"));
        });

      });

    });
  });

}
