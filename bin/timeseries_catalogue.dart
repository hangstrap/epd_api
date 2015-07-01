library timeseries_catalogue;

import "dart:io";
import 'dart:core';
import 'dart:async';

import "package:quiver/cache.dart";
import 'package:logging/logging.dart';


import 'package:jsonx/jsonx.dart' as jsonx;

import "../lib/common/timeseries_model.dart";
import "caf_file_decoder.dart" show pathNameForTimeseriesNode;
import '../lib/common/utils.dart';

typedef Future Saver(TimeseriesNode node, Map<DateTime, CatalogueItem> catalogueMap);
typedef Future<Map<DateTime, CatalogueItem>> Loader( TimeseriesNode node);

final Logger _log = new Logger('timeseries_catalogue');

class CataloguePersister {
  final Directory source;
  CataloguePersister(this.source) {
    if (source == null) {
      throw "Source cannot be null";
    }
  }

  Future<Map<TimeseriesNode, Map<DateTime, CatalogueItem>>> _loadFromFile(File catalogFile) async {
    if (await catalogFile.exists()) {
      _log.info( "loading catalogue $catalogFile");      
      try {
        String json = await catalogFile.readAsString();
        return new Future.value(_fromJson(json));
      } catch (e) {
        _log.warning("error load ${catalogFile} ${e}");
      }
    }
    return new Future.value({});
  }

  Future<Map<DateTime, CatalogueItem>> load( TimeseriesNode node) async{
    File fileName = _catalogFileName(node);
    
    Map<TimeseriesNode, Map<DateTime, CatalogueItem>> map = await _loadFromFile( fileName);
    if( map.containsKey( node)){
      return new Future.value( map[node]);
    }
    else{
      return new Future.value({});
    }
      
  }
  
  Future save(TimeseriesNode node, Map<DateTime, CatalogueItem> catalogueMap) async {


    String json = _toJson(catalogueMap);
    File catalogFileName = _catalogFileName(node);
    _log.info( "saving catalogue $catalogFileName");
    
    Directory newParent = catalogFileName.parent;
    if (!await newParent.exists()) {
      await newParent.create(recursive: true);
    }

    catalogFileName.writeAsStringSync(json);

    return new Future.value();
  }

  File _catalogFileName(TimeseriesNode node) {
    File catalogFile = new File('${source.path}/${pathNameForTimeseriesNode(node)}/catalog.json');
    return catalogFile;
  }

  Map<TimeseriesNode, Map<DateTime, CatalogueItem>> _fromJson(String json) {
    List<CatalogueItem> temp = jsonx.decode(json, type: const jsonx.TypeHelper<List<CatalogueItem>>().type);

    Map<TimeseriesNode, Map<DateTime, CatalogueItem>> result = {};
    temp.forEach((item) {
      Map<DateTime, CatalogueItem> analysiss = result.putIfAbsent(item.node, () => {});

      analysiss[item.analyis] = item;
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
  TimeseriesNode node;
  DateTime analyis;
  Period fromTo;
  CatalogueItem.create(this.node, this.analyis, this.fromTo);
  CatalogueItem() {}

  int get hashCode {
    return analyis.hashCode + node.hashCode;
  }

  bool operator ==(other) {
    if (other is! CatalogueItem) return false;
    CatalogueItem key = other;
    return (key.node == node) && (key.analyis == analyis);
  }
}

class TimeseriesCatalogue {

  final Saver saver;
  final Loader loader;

  final MapCache<TimeseriesNode, Map<DateTime, CatalogueItem>> catalogue =new MapCache.lru();


  TimeseriesCatalogue(this.loader, this.saver);
  

  Future<Map<DateTime, CatalogueItem>> analysissFor(TimeseriesNode node) async {    
    return await catalogue.get( node, ifAbsent: loader);
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
    CatalogueItem item = new CatalogueItem.create(assembly.node, assembly.analysis, assembly.timePeriodOfEditions);
    Map<DateTime, CatalogueItem> analayisMap = await analysissFor(assembly.node);
    analayisMap[assembly.analysis] = item;
    return await saver(assembly.node, analayisMap);
  }
}
