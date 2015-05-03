library timeseries_catalogue;


import "timeseries_model.dart";
import 'utils.dart';


class CatalogueItem{
  Uri source;
  DateTime analyis;
  Period fromTo;
  CatalogueItem.create( this.source, this.analyis, this.fromTo);
  CatalogueItem();
}

class TimeseriesCatalogue {
  Map<TimeseriesNode, Map<DateTime, CatalogueItem>> catalogue = {};
  List<Uri> itemsDownloaded = [];

  int get numberOfNodes => catalogue.length;

  TimeseriesCatalogue();

  Map<DateTime, CatalogueItem> analysisFor(TimeseriesNode node) {
    return catalogue[node];
  }
//
//  Period periodFor(TimeseriesNode node, DateTime analysis) {
//    return catalogue[node.toNamespace()][analysis.toIso8601String()];
//  }

  void addAnalysis(TimeseriesAssembly assembly, Uri source) {

    CatalogueItem item = new CatalogueItem.create(source, assembly.analysis, assembly.timePeriodOfEditions);
    
    itemsDownloaded.add( source);
    
    Map<DateTime, CatalogueItem> analayisMap = catalogue.putIfAbsent(assembly.node, () => {});
    analayisMap[assembly.analysis] = item;
  }
  
  bool isDownloaded(Uri source) {
    return itemsDownloaded.contains(source);
  }
}
