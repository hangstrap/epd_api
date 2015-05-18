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
        //      print( "loading ${catalogFile}");
        String json = catalogFile.readAsStringSync();
        //      print( "loaded  ${catalogFile}");
        return new Future.value(_fromJson(json));
      } catch (e) {
        print("error load ${catalogFile} ${e}");
      }
    }
    return new Future.value({});
  }
  num count = 0;
  Future save(TimeseriesNode node, Map<DateTime, CatalogueItem> catalogueMap) async {

    //save to disk
    String json = _toJson(catalogueMap);
    File catalogFileName = _catalogFileName(node);

    Directory newParent = catalogFileName.parent;
    if (!await newParent.exists()) {
      await newParent.create(recursive: true);
    }

    count++;
//    print( "saving ${count} ${catalogFileName}");

//    if( node.locationName=='01492'){
    //     print( json);
//    }
    catalogFileName.writeAsStringSync(json);
//    print( "saved  ${count} ${catalogFileName}");

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
  final Map<TimeseriesNode, Future> loading = {};

  final Map<TimeseriesNode, Map<DateTime, CatalogueItem>> catalogue = {};

  int get numberOfNodes => catalogue.length;

  TimeseriesCatalogue(this.loader, this.saver);

  Future<Map<DateTime, CatalogueItem>> analysissFor(TimeseriesNode node) async {
    if (catalogue.containsKey(node) == false) {
      return _loadAnalysissFor(node);
    }
    return new Future.value(catalogue[node]);
  }

  Future<Map<DateTime, CatalogueItem>> _loadAnalysissFor(TimeseriesNode node) {
    if (loading.containsKey(node)) {
      //are we currently  loading the data?
      return loading[node].whenComplete(() {
        return analysissFor(node);
      });
    } else {
      //Start loading the data, keeping a record that we are busy
      Future<Map<DateTime, CatalogueItem>> future = loader(node);
      loading[node] = future;
      return future.then((data) {
        //No longer loading data
        loading.remove(node);
        //Store it in the catalogue
        catalogue[node] = data;
        //return it
        return data;
      });
    }
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

//    if( assembly.node.locationName=='01492'){
//print ("about to load");
//    }

    CatalogueItem item = new CatalogueItem.create(assembly.analysis, assembly.timePeriodOfEditions);

    Map<DateTime, CatalogueItem> analayisMap = await analysissFor(assembly.node);
//    if( assembly.node.locationName=='01492'){
//print ("map has ${analayisMap.length}");
//    }

    analayisMap[assembly.analysis] = item;

//    if( assembly.node.locationName=='01492'){
//print ("map now has ${analayisMap.length}");
//    }

    return await saver(assembly.node, analayisMap);
  }
}
