import 'package:unittest/unittest.dart';

import '../bin/timeseries_model.dart';
import '../bin/timeseries_data_cache.dart';
import 'dart:async';

DateTime analysisAt = new DateTime.utc(2013, 04, 07, 20, 23);

void main() {
  group("getTimeseries", () {
    TimeseriesNode node = new TimeseriesNode.create("City Town & Spot Forecasts", "PDF-PROFOUND", "TTTTT", "01492", "INTL");
    TimeseriesAssembly assembly = new TimeseriesAssembly.create(node, analysisAt, []);

    DateTime analysis = new DateTime.now();
    DateTime validFrom = new DateTime.now();
    Duration period = new Duration();

    test("on cache miss should return assembly instance provided by loaded", () async {
      Future<TimeseriesAssembly> timeseriesLoader(TimeseriesNode key, DateTime analysis) {
        return new Future.value(assembly);
      }

      TimeseriesDataCache cache = new TimeseriesDataCache(timeseriesLoader);

      TimeseriesAssembly result = await cache.getTimeseriesAnalysis(node, analysis, validFrom, period);

      expect(result, isNotNull);
      expect(result.node, equals(node));
    });

    test("on cache hit, should not access the loader", () async {
      Future<TimeseriesAssembly> timeseriesLoader(TimeseriesNode key, DateTime analysis) {
        return new Future.error("cache accessed loader");
      }

      TimeseriesDataCache cache = new TimeseriesDataCache(timeseriesLoader);
      //preloader add item to cache
      cache.cache.set(new Key(node, analysis), assembly);

      TimeseriesAssembly a = await cache.getTimeseriesAnalysis(node, analysis, validFrom, period);

      expect(a, isNotNull);
      expect(a, equals(assembly));
    });
    test("exceptions", () async {
      Future<TimeseriesAssembly> timeseriesLoader(TimeseriesNode key, DateTime analysis) {
        return new Future.error("back end failure");
      }

      TimeseriesDataCache cache = new TimeseriesDataCache(timeseriesLoader);
      try {
        await cache.getTimeseriesAnalysis(node, analysis, validFrom, period);
        fail("exception not thrown");
      } catch (a) {
        expect(a, isNotNull);
        expect(a, equals("back end failure"));
      }
    });

    group("getTimeseriesSet", () {
      TimeseriesNode node1 = new TimeseriesNode.create("City Town & Spot Forecasts", "PDF-PROFOUND", "TTTTT", "01492", "INTL");

      TimeseriesNode node2 = new TimeseriesNode.create("City Town & Spot Forecasts", "PDF-PROFOUND", "BBBBB", "01492", "INTL");

      TimeseriesAssembly assembly1 = new TimeseriesAssembly.create(node1, analysisAt, []);
      TimeseriesAssembly assembly2 = new TimeseriesAssembly.create(node2, analysisAt, []);

      DateTime analysis = new DateTime.now();
      DateTime validFrom = new DateTime.now();
      Duration period = new Duration();

      test("will call getTimeseries for each key", () async {
        TimeseriesDataCache cache = new TimeseriesDataCache((key, analysis) {
          if (key == node1) {
            return new Future.value(assembly1);
          }
          if (key == node2) {
            return new Future.value(assembly2);
          }
        });

        List<TimeseriesAssembly> results = await cache.getTimeseriesAnalysisSet([node1, node2], analysis, validFrom, period);

        expect(results, isNotNull);
        expect(results.length, equals(2));
        expect(results[0], equals(assembly1));
        expect(results[1], equals(assembly2));
      });

      test("when backend returns failing future, then entire set fails ", () async {
        TimeseriesDataCache cache = new TimeseriesDataCache((key, analysis) {
          if (key == node1) {
            return new Future.value(assembly1);
          }
          if (key == node2) {
            return new Future.error("bugger");
          }
        });
        try {
          await cache.getTimeseriesAnalysisSet([node1, node2], analysis, validFrom, period);
          fail("no exception from backend");
        } catch (e) {
          expect(e, equals("bugger"));
        }
        ;
      });
    });
  });
}
