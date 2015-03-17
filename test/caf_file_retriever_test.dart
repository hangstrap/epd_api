import 'package:unittest/unittest.dart';

import '../bin/caf_file_retriever.dart' as caf;
import '../bin/timeseries_data_cache.dart';


main(){
  group( "create correct file name based on CAF file contents", (){
    test( "check the pattern for a 99xxx station", (){
      String cafFileName = caf.fileNameForCafFile( cafFileHeader99xxxx);
      expect( cafFileName, equals( "CityTownSpotForecasts/PDF-PROFOUND/201502150300Z/TTTTT/CityTownSpotForecasts.PDF-PROFOUND.201502150300Z.TTTTT.99647-INTL.caf"));
    });
    test( "check the pattern for a non 99xxx station", (){
      String cafFileName = caf.fileNameForCafFile( cafFileHeader123456);
      expect( cafFileName, equals( "CityTownSpotForecasts/PDF-PROFOUND/201502150300Z/TTTTT/CityTownSpotForecasts.PDF-PROFOUND.201502150300Z.TTTTT.123456.caf"));
    });    
  });
  
  group( "create correct file name based on TimeseriesAnalysis", (){
    test( "check pattern for a 99xxx station", (){
      
      DateTime analysisAt = new DateTime.utc(2015, 2, 15, 3,0);
      TimeseriesRootAnalysis key = new TimeseriesRootAnalysis( new Product("City, Town & Spot Forecasts"), new Model( "PDF-PROFOUND"),analysisAt );
      
      String cafFileName = caf.fileNameForTimeseriesAnalysis( key);
      expect( cafFileName, equals( "CityTownSpotForecasts/PDF-PROFOUND/201502150300Z/TTTTT/CityTownSpotForecasts.PDF-PROFOUND.201502150300Z.TTTTT.99647-INTL.caf"));
    });
    
  });
}

List<String> cafFileHeader99xxxx = 
"""status:=ok
schema:=timeseries nwp vhapdf prognosis station amps-pdf
vha-code:=TTTTT
model-group:=PDF-PROFOUND
product:=City, Town & Spot Forecasts
issue-time:=20150215 0759 Z
station:=99647
station-99suffix:=INTL
init-time:=20150215 0300 Z
""".split("\n");

List<String> cafFileHeader123456 = 
"""status:=ok
schema:=timeseries nwp vhapdf prognosis station amps-pdf
vha-code:=TTTTT
model-group:=PDF-PROFOUND
product:=City, Town & Spot Forecasts
issue-time:=20150215 0759 Z
station:=123456
station-99suffix:=INTL
init-time:=20150215 0300 Z
""".split("\n");