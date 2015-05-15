library timeseries_catalogue;

import "dart:io";
import 'dart:core';
import 'dart:async';

import 'package:jsonx/jsonx.dart' as jsonx;

import "timeseries_model.dart";
import "caf_file_decoder.dart" show pathNameForTimeseriesNode;
import 'utils.dart';

typedef Future<Map<DateTime, CatalogueItem>> CatalogForNodeLoader(TimeseriesNode node);
typedef Future CatalogForNodeSaver(TimeseriesNode node, Map<DateTime, CatalogueItem> catalogue);

class CataloguePersister {
  final Directory source;
  CataloguePersister(this.source){
    if( source ==null){
      throw "Source cannot be null";
    }
  }
  Future<Map<DateTime, CatalogueItem>> load(TimeseriesNode node) async {

    //load from disk
    File catalogFile = _catalogFileName(node);
    if (await catalogFile.exists()) {
      String json = await catalogFile.readAsString();
      return new Future.value(_fromJson(json));
    }
    return new Future.value({});
  }
  Future save(TimeseriesNode node, Map<DateTime, CatalogueItem> catalogueMap) async {

    //save to disk
    String json = _toJson(catalogueMap);
    File catalogFileName = _catalogFileName(node);
    Directory newParent = catalogFileName.parent;
    if (!await newParent.exists()) {
      await newParent.create(recursive: true);
    }

    return await catalogFileName.writeAsString(json);
  }

  File _catalogFileName(TimeseriesNode node) {
    File catalogFile = new File('${source.path}/${pathNameForTimeseriesNode(node)}/catalog.json');
    return catalogFile;
  }

  Map<DateTime, CatalogueItem> _fromJson(String json) {
    Map<String, CatalogueItem> temp =
        jsonx.decode(json, type: const jsonx.TypeHelper<Map<String, CatalogueItem>>().type);
    
    Map<DateTime, CatalogueItem> result ={};
    temp.forEach( (str, item){
      result[ DateTime.parse(str)] = item;
    });
    return result;
  }

  String _toJson(Map<DateTime, CatalogueItem> catalogueMap) {
    var result = {};
    catalogueMap.forEach((analysis, item) {
      result[analysis.toIso8601String()] = item;
    });

    return jsonx.encode(result, indent: " ");
  }
}

class CatalogueItem {
  DateTime analyis;
  Period fromTo;
  CatalogueItem.create(this.analyis, this.fromTo);
  CatalogueItem() {}
}

class TimeseriesCatalogue {
  final CatalogForNodeLoader loader;
  final CatalogForNodeSaver saver;

  final Map<TimeseriesNode, Map<DateTime, CatalogueItem>> catalogue = {};
  
  int get numberOfNodes => catalogue.length;

  TimeseriesCatalogue(this.loader, this.saver);

  Future<Map<DateTime, CatalogueItem>> analysissFor(TimeseriesNode node) async {
    if (catalogue.containsKey(node) == false) {
      catalogue[node] = await loader(node);
    }
    return new Future.value(catalogue[node]);
  }

  Future<List<DateTime>> findAnalysissForPeriod(TimeseriesNode node, Period validFromTo) async {
    List<DateTime> result = [];

    Map<DateTime, CatalogueItem> analysiss = await analysissFor(node);
    if (analysiss != null) {
      analysiss.forEach((analysis, catalogueItem) {
        if (catalogueItem.fromTo.isPeriodOverlapping(validFromTo)) {
          result.add(analysis);
        }
      });
    }
    result.sort();
    if (result.length > 0) {
      DateTime lastAnalysis = result.last;
      if (analysiss[lastAnalysis].fromTo.isPeriodInside(validFromTo)) {
        return new Future.value([lastAnalysis]);
      }
    }

    return new Future.value(result);
  }

  Future addAnalysis(TimeseriesAssembly assembly) async {
    CatalogueItem item = new CatalogueItem.create(assembly.analysis, assembly.timePeriodOfEditions);

    Map<DateTime, CatalogueItem> analayisMap = await analysissFor(assembly.node);
    analayisMap[assembly.analysis] = item;

    return await saver(assembly.node, analayisMap);
  }
}
