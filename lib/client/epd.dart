// This is a generated file (see the discoveryapis_generator project).

library epd_api_shelf.epd.client;

import 'dart:core' as core;
import 'dart:async' as async;


import 'package:_discoveryapis_commons/_discoveryapis_commons.dart' as commons;
import 'package:http/http.dart' as http;
import 'package:epd_api_shelf/common/timeseries_model.dart';
export 'package:_discoveryapis_commons/_discoveryapis_commons.dart' show
    ApiRequestError, DetailedApiRequestError;

const core.String USER_AGENT = 'dart-api-client epd/v1';

/** Epd Api */
class Epd {

  final commons.ApiRequester _requester;

  Epd(http.Client client, {core.String rootUrl: "http://localhost:8080/", core.String servicePath: "epd/v1/"}) :
      _requester = new commons.ApiRequester(client, rootUrl, servicePath, USER_AGENT);

  /**
   * Request parameters:
   *
   * [product] - Path parameter: 'product'.
   *
   * [model] - Path parameter: 'model'.
   *
   * [analysis] - Path parameter: 'analysis'.
   *
   * [locations] - Query parameter: 'locations'.
   *
   * [elements] - Query parameter: 'elements'.
   *
   * [validFrom] - Query parameter: 'validFrom'.
   *
   * [validTo] - Query parameter: 'validTo'.
   *
   * Completes with a [core.List<TimeseriesAssembly>].
   *
   * Completes with a [commons.ApiRequestError] if the API endpoint returned an
   * error.
   *
   * If the used [http.Client] completes with an error when making a REST call,
   * this method will complete with the same error.
   */
  async.Future<core.List<TimeseriesAssembly>> byAnalysis(core.String product, core.String model, core.String analysis, {core.String locations, core.String elements, core.String validFrom, core.String validTo}) {
    var _url = null;
    var _queryParams = new core.Map();
    var _uploadMedia = null;
    var _uploadOptions = null;
    var _downloadOptions = commons.DownloadOptions.Metadata;
    var _body = null;

    if (product == null) {
      throw new core.ArgumentError("Parameter product is required.");
    }
    if (model == null) {
      throw new core.ArgumentError("Parameter model is required.");
    }
    if (analysis == null) {
      throw new core.ArgumentError("Parameter analysis is required.");
    }
    if (locations != null) {
      _queryParams["locations"] = [locations];
    }
    if (elements != null) {
      _queryParams["elements"] = [elements];
    }
    if (validFrom != null) {
      _queryParams["validFrom"] = [validFrom];
    }
    if (validTo != null) {
      _queryParams["validTo"] = [validTo];
    }

    _url = 'byAnalysis/' + commons.Escaper.ecapeVariable('$product') + '/' + commons.Escaper.ecapeVariable('$model') + '/' + commons.Escaper.ecapeVariable('$analysis');

    var _response = _requester.request(_url,
                                       "GET",
                                       body: _body,
                                       queryParams: _queryParams,
                                       uploadOptions: _uploadOptions,
                                       uploadMedia: _uploadMedia,
                                       downloadOptions: _downloadOptions);
    return _response.then((data) => data.map((value) => TimeseriesAssemblyFactory.fromJson(value)).toList());
  }

  /**
   * Request parameters:
   *
   * [product] - Path parameter: 'product'.
   *
   * [model] - Path parameter: 'model'.
   *
   * [validFrom] - Path parameter: 'validFrom'.
   *
   * [validTo] - Path parameter: 'validTo'.
   *
   * [locations] - Query parameter: 'locations'.
   *
   * [elements] - Query parameter: 'elements'.
   *
   * Completes with a [core.List<TimeseriesBestSeries>].
   *
   * Completes with a [commons.ApiRequestError] if the API endpoint returned an
   * error.
   *
   * If the used [http.Client] completes with an error when making a REST call,
   * this method will complete with the same error.
   */
  async.Future<core.List<TimeseriesBestSeries>> byLatest(core.String product, core.String model, core.String validFrom, core.String validTo, {core.String locations, core.String elements}) {
    var _url = null;
    var _queryParams = new core.Map();
    var _uploadMedia = null;
    var _uploadOptions = null;
    var _downloadOptions = commons.DownloadOptions.Metadata;
    var _body = null;

    if (product == null) {
      throw new core.ArgumentError("Parameter product is required.");
    }
    if (model == null) {
      throw new core.ArgumentError("Parameter model is required.");
    }
    if (validFrom == null) {
      throw new core.ArgumentError("Parameter validFrom is required.");
    }
    if (validTo == null) {
      throw new core.ArgumentError("Parameter validTo is required.");
    }
    if (locations != null) {
      _queryParams["locations"] = [locations];
    }
    if (elements != null) {
      _queryParams["elements"] = [elements];
    }

    _url = 'byLatest/' + commons.Escaper.ecapeVariable('$product') + '/' + commons.Escaper.ecapeVariable('$model') + '/' + commons.Escaper.ecapeVariable('$validFrom') + '/' + commons.Escaper.ecapeVariable('$validTo');

    var _response = _requester.request(_url,
                                       "GET",
                                       body: _body,
                                       queryParams: _queryParams,
                                       uploadOptions: _uploadOptions,
                                       uploadMedia: _uploadMedia,
                                       downloadOptions: _downloadOptions);
    return _response.then((data) => data.map((value) => TimeseriesBestSeriesFactory.fromJson(value)).toList());
  }

}



class EditionFactory {
  static Edition fromJson(core.Map _json) {
    var message = new Edition();
    if (_json.containsKey("analysisAt")) {
      message.analysisAt = core.DateTime.parse(_json["analysisAt"]);
    }
    if (_json.containsKey("datum")) {
      message.datum = _json["datum"];
    }
    if (_json.containsKey("validFrom")) {
      message.validFrom = core.DateTime.parse(_json["validFrom"]);
    }
    if (_json.containsKey("validTo")) {
      message.validTo = core.DateTime.parse(_json["validTo"]);
    }
    return message;
  }

  static core.Map toJson(Edition message) {
    var _json = new core.Map();
    if (message.analysisAt != null) {
      _json["analysisAt"] = (message.analysisAt).toIso8601String();
    }
    if (message.datum != null) {
      _json["datum"] = message.datum;
    }
    if (message.validFrom != null) {
      _json["validFrom"] = (message.validFrom).toIso8601String();
    }
    if (message.validTo != null) {
      _json["validTo"] = (message.validTo).toIso8601String();
    }
    return _json;
  }
}

class TimeseriesAssemblyFactory {
  static TimeseriesAssembly fromJson(core.Map _json) {
    var message = new TimeseriesAssembly();
    if (_json.containsKey("analysis")) {
      message.analysis = core.DateTime.parse(_json["analysis"]);
    }
    if (_json.containsKey("editions")) {
      message.editions = _json["editions"].map((value) => EditionFactory.fromJson(value)).toList();
    }
    if (_json.containsKey("node")) {
      message.node = TimeseriesNodeFactory.fromJson(_json["node"]);
    }
    return message;
  }

  static core.Map toJson(TimeseriesAssembly message) {
    var _json = new core.Map();
    if (message.analysis != null) {
      _json["analysis"] = (message.analysis).toIso8601String();
    }
    if (message.editions != null) {
      _json["editions"] = message.editions.map((value) => EditionFactory.toJson(value)).toList();
    }
    if (message.node != null) {
      _json["node"] = TimeseriesNodeFactory.toJson(message.node);
    }
    return _json;
  }
}

class TimeseriesBestSeriesFactory {
  static TimeseriesBestSeries fromJson(core.Map _json) {
    var message = new TimeseriesBestSeries();
    if (_json.containsKey("editions")) {
      message.editions = _json["editions"].map((value) => EditionFactory.fromJson(value)).toList();
    }
    if (_json.containsKey("latestAt")) {
      message.latestAt = core.DateTime.parse(_json["latestAt"]);
    }
    if (_json.containsKey("node")) {
      message.node = TimeseriesNodeFactory.fromJson(_json["node"]);
    }
    return message;
  }

  static core.Map toJson(TimeseriesBestSeries message) {
    var _json = new core.Map();
    if (message.editions != null) {
      _json["editions"] = message.editions.map((value) => EditionFactory.toJson(value)).toList();
    }
    if (message.latestAt != null) {
      _json["latestAt"] = (message.latestAt).toIso8601String();
    }
    if (message.node != null) {
      _json["node"] = TimeseriesNodeFactory.toJson(message.node);
    }
    return _json;
  }
}

class TimeseriesNodeFactory {
  static TimeseriesNode fromJson(core.Map _json) {
    var message = new TimeseriesNode();
    if (_json.containsKey("element")) {
      message.element = _json["element"];
    }
    if (_json.containsKey("locationName")) {
      message.locationName = _json["locationName"];
    }
    if (_json.containsKey("locationSuffix")) {
      message.locationSuffix = _json["locationSuffix"];
    }
    if (_json.containsKey("model")) {
      message.model = _json["model"];
    }
    if (_json.containsKey("product")) {
      message.product = _json["product"];
    }
    return message;
  }

  static core.Map toJson(TimeseriesNode message) {
    var _json = new core.Map();
    if (message.element != null) {
      _json["element"] = message.element;
    }
    if (message.locationName != null) {
      _json["locationName"] = message.locationName;
    }
    if (message.locationSuffix != null) {
      _json["locationSuffix"] = message.locationSuffix;
    }
    if (message.model != null) {
      _json["model"] = message.model;
    }
    if (message.product != null) {
      _json["product"] = message.product;
    }
    return _json;
  }
}

