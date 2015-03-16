import 'package:unittest/unittest.dart';

import '../bin/caf_file_retriever.dart' as caf;


main(){
  group( "create correct file name based on file contents", (){
    test( "check the pattern", (){
      String cafFileName = caf.createCafFileName( cafFileHeader);
      expect( cafFileName, equals( "cityTownSpotForecast/pdf-profound/201502150300/TTTTT/99647-INTL/cityTownSpotForecast.pdf-profound.201502150300.TTTTT.99647.INTL.caf"));
    });
    
  });
}

List<String> cafFileHeader = 
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