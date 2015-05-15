import 'matchers.dart';

import 'package:unittest/unittest.dart';
import 'package:mock/mock.dart';

import 'package:rpc/rpc.dart';


import '../bin/timeseries_data_cache.dart';
import '../bin/epd_api.dart';

@proxy
class MockTimeseriesDataCache extends Mock implements TimeseriesDataCache {}

main() {
  EpdApi underTest;
  MockTimeseriesDataCache cache;

  setUp(() {
    cache = new MockTimeseriesDataCache();
    underTest = new EpdApi(cache);
  });

  group("byAnalysis", () {
    test("locations and elements must be query parameters", () {
      expect(() => underTest.byAnalysis("product", "model", "20150215T0300Z", elements: "aa"),
          throwsA(exceptionMatching(ApplicationError, "Exception: FormatException: locations and elements are required query paramters")));
      expect(() => underTest.byAnalysis("product", "model", "20150215T0300Z", locations: "aa"),
          throwsA(exceptionMatching(ApplicationError, "Exception: FormatException: locations and elements are required query paramters")));
    });
    test("analysis time must be valid ", (){
      expect(() => underTest.byAnalysis("product", "model", "junk", elements: "aa", locations:"9999.INTL"),
          throwsA(exceptionMatching(ApplicationError, "Exception: FormatException: Time value of 'junk' is invalid, must be ISO time format")));
      
      
    });
  
  });
}
