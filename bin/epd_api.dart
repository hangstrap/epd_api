library epd_api;

import 'dart:async';
import 'dart:core';

import 'package:rpc/rpc.dart';

import "timeseries_model.dart";
import "timeseries_data_cache.dart";

//http://localhost:9090/api/discovery/v1/apis
//http://localhost:9090/api/epd/v1/index
//http://localhost:9090/api/epd/v1/byAnalysis/City, Town & Spot Forecasts/PDF-PROFOUND/20150215T0300Z?locations=01492.INTL,03266.INTL&elements=TTTTT&validFrom=20150215T0400Z&validTo=20150215T0600Z
//http://localhost:9090/api/epd/v1/byLatest/City, Town & Spot Forecasts/PDF-PROFOUND/20150215T0300Z/20150215T0600Z?locations=01492.INTL,03266.INTL&elements=TTTTT
class MyMessage {
  String message;
}

@ApiClass(version: 'v1', description: 'Epd Api', name: 'epd')
class EpdApi {
  final TimeseriesDataCache cache;

  EpdApi(this.cache);

  @ApiMethod(method: 'GET', path: 'index')
  MyMessage index() {
    return new MyMessage()..message = "index message";
  }

  @ApiMethod(method: 'GET', path: 'byAnalysis/{product}/{model}/{analysis}')
  Future<List<TimeseriesAssembly>> byAnalysis(String product, String model, String analysis, {String locations, String elements, String validFrom, String validTo}) {
      if ((locations == null) || (elements == null)) {
        throw new FormatException("locations and elements are required query paramters");
      }
      product = Uri.decodeComponent(product);
      model = Uri.decodeComponent(model);
      analysis = Uri.decodeComponent(analysis);

      List<TimeseriesNode> nodes = _extractNodes(locations, elements, product, model);

      DateTime analysisAt = _parseDateTime(analysis);

      DateTime valid_From = null;
      Duration period = null;
      if (validFrom != null) {
        valid_From = _parseDateTime(validFrom);
        if (validTo != null) {
          DateTime valid_To = _parseDateTime(validTo);
          period = valid_To.difference(valid_From);
        }
      }

      return cache.getTimeseriesAnalysisSet(nodes, analysisAt, valid_From, period);
  }


  @ApiMethod(method: 'GET', path: 'byLatest/{product}/{model}/{validFrom}/{validTo}')
  Future<List<TimeseriesBestSeries>> byLatest(String product, String model, String validFrom, String validTo, {String locations, String elements}) {
    try{
      if ((locations == null) || (elements == null)) {
        throw new FormatException("locations and elements are required query paramters");
      }
      product = Uri.decodeComponent(product);
      model = Uri.decodeComponent(model);

      DateTime validFromAt = _parseDateTime(Uri.decodeComponent(validFrom));
      DateTime validToAt = _parseDateTime(Uri.decodeComponent(validTo));
      Duration duration = validToAt.difference(validFromAt);

      List<TimeseriesNode> nodes = _extractNodes(locations, elements, product, model);

      return cache.getTimeseriesBestSeriesSet(nodes, validFromAt, duration);
    }catch( e){
      print( "had exception ${e}");
      throw new ApplicationError( new Exception(e));      
    }
  }

  List<TimeseriesNode> _extractNodes(String locations, String elements, String product, String model) {
    List<TimeseriesNode> nodes = [];
    List<String> locationList = locations.split(",");
    List<String> elementList = elements.split(",");

    locationList.forEach((location) {
      elementList.forEach((element) {
        String locationName = location.split("\.")[0];
        String locationSuffix = location.split("\.")[1];
        nodes.add(new TimeseriesNode.create(product, model, element, locationName, locationSuffix));
      });
    });
    return nodes;
  }

  DateTime _parseDateTime(String time) {
    try {
      return DateTime.parse(time);
    } catch (a) {
      throw new FormatException("Time value of '${time}' is invalid, must be ISO time format");
    }
  }
  
}
