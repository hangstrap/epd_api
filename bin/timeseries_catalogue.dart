library timeseries_catalogue;

import "timeseries_model.dart";
import 'utils.dart';

class CatalogueItem {
  Uri source;
  DateTime analyis;
  Period fromTo;
  CatalogueItem.create(this.source, this.analyis, this.fromTo);
  CatalogueItem();
}

class TimeseriesCatalogue {
  Map<TimeseriesNode, Map<DateTime, CatalogueItem>> catalogue = {};
  List<Uri> itemsDownloaded = [];

  int get numberOfNodes => catalogue.length;

  TimeseriesCatalogue();

  Map<DateTime, CatalogueItem> analysissFor(TimeseriesNode node) {
    return catalogue[node];
  }

  List<DateTime> findAnalysissForPeriod(TimeseriesNode node, Period validFromTo) {
    List<DateTime> result = [];

    Map<DateTime, CatalogueItem> analysiss = analysissFor(node);
    if (analysiss != null) {
      analysiss.forEach((analysis, catalogueItem) {
        if (catalogueItem.fromTo.isPeriodOverlapping(validFromTo)) {
          result.add(analysis);
        }
      });
    }
    result.sort();
    if( result.length >0){
      DateTime lastAnalysis = result.last;
      if( analysiss[ lastAnalysis].fromTo.isPeriodInside( validFromTo)){
        return [ lastAnalysis];
      }
    }
    
    
    return result;
  }

  void addAnalysis(TimeseriesAssembly assembly, Uri source) {
    CatalogueItem item = new CatalogueItem.create(source, assembly.analysis, assembly.timePeriodOfEditions);

    itemsDownloaded.add(source);

    Map<DateTime, CatalogueItem> analayisMap = catalogue.putIfAbsent(assembly.node, () => {});
    analayisMap[assembly.analysis] = item;
  }

  bool isDownloaded(Uri source) {
    return itemsDownloaded.contains(source);
  }
}
