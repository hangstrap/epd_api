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
  CataloguePersister(this.source) {
    if (source == null) {
      throw "Source cannot be null";
    }
  }
  Future<Map<DateTime, CatalogueItem>> load(TimeseriesNode node) async {
    //load from disk
    File catalogFile = _catalogFileName(node);
    
    if (await catalogFile.exists()) {
      try {
        String json = await catalogFile.readAsString();
        return new Future.value(_fromJson(json));
      } catch (e) {
        print("error load ${catalogFile} ${e}");
      }
    }
    return new Future.value({});
  }
  num count= 0;
  Future save(TimeseriesNode node, Map<DateTime, CatalogueItem> catalogueMap) async {

    //save to disk
    String json = _toJson(catalogueMap);
    File catalogFileName = _catalogFileName(node);
    
    
    Directory newParent = catalogFileName.parent;
    if (!await newParent.exists()) {
      await newParent.create(recursive: true);
    }    
    await catalogFileName.writeAsString(json);
    
    return new Future.value();
  }

  File _catalogFileName(TimeseriesNode node) {
    File catalogFile = new File('${source.path}/${pathNameForTimeseriesNode(node)}/catalog.json');
    return catalogFile;
  }

  Map<DateTime, CatalogueItem> _fromJson(String json) {
    List<CatalogueItem> temp = jsonx.decode(json, type: const jsonx.TypeHelper<List<CatalogueItem>>().type);

    Map<DateTime, CatalogueItem> result = {};
    temp.forEach((item) {
      result[item.analyis] = item;
    });
    return result;
  }

  String _toJson(Map<DateTime, CatalogueItem> catalogueMap) {
    var result = [];
    catalogueMap.forEach((analysis, item) {
      result.add(item);
    });

    return jsonx.encode(result, indent: " ");
  }
}

class CatalogueItem {
  DateTime analyis;
  Period fromTo;
  CatalogueItem.create(this.analyis, this.fromTo);
  CatalogueItem() {}

  int get hashCode {
    return analyis.hashCode;
  }

  bool operator ==(other) {
    if (other is! CatalogueItem) return false;
    CatalogueItem key = other;
    return (key.analyis == analyis);
  }
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
