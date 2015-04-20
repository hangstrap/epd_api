library epd_api;

import 'package:rpc/rpc.dart';
import 'dart:async';
import 'dart:core';
import "timeseries_model.dart";
import "caf_file_retriever.dart";
import "timeseries_data_cache.dart";


@ApiClass(version: 'v1', description: 'Epd Api', name: 'epd')
class EpdApi {

  final TimeseriesDataCache cache;
  
  EpdApi( this.cache);
  
  @ApiMethod(method: 'GET', path: 'byAnalysis/{product}/{model}/{analysis}')
  Future<List<TimeseriesAssembly>> byAnalysis(String product, String model, String analysis, {String locationCSV, String elementCSV, String validFrom, String validTo}) {
    if ((locationCSV == null) || (elementCSV == null)) {
      throw new ArgumentError("locationCSV and elementCSV are required query paramters");
    }

    List<TimeseriesNode> nodes = [];
    List<String> locations = locationCSV.split(",");
    List<String> elements = elementCSV.split(",");

    locations.forEach((location) {
      elements.forEach((element) {
        String locationName = location.split("\.")[0];
        String locationSuffix = location.split("\.")[1];
        nodes.add(new TimeseriesNode(product, model, element, locationName, locationSuffix));
      });
    });
    
    DateTime analysisAt = DateTime.parse( analysis);
    
      DateTime valid_From = null;
      Duration  period = null;
      if( validFrom !=null){
        valid_From = DateTime.parse( validFrom);
      }
      if( validTo !=null){
        DateTime valid_To = DateTime.parse( validTo);
        period = valid_To.difference( valid_From);
      }

      Future<List<TimeseriesAssembly>> futureAssembly = cache.getTimeseriesAnalysisSet(nodes, analysisAt, valid_From, period);
      return futureAssembly;

//      return futureAssembly.then((assembly) {
//
//        //convert to json
//        String json = encode(assembly);
//        return new shelf.Response.ok(json);
//
//      });      
  }
}
