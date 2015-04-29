library timeseries_catalogue;


import "timeseries_model.dart";



class CatalogueItem{
  TimeseriesNode node;
  Uri source;
  DateTime analyis;
  Period fromTo;
  
  CatalogueItem( this.node, this.source, this.analyis, this.fromTo);
}

class TimeseriesCatalogue {
  Map<TimeseriesNode, Map<DateTime, CatalogueItem>> catalogue = {};
  Map<Uri, CatalogueItem> itemsDownloaded = {};

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

    CatalogueItem item = new CatalogueItem(assembly.node, source, assembly.analysis, assembly.timePeriodOfEditions);
    
    itemsDownloaded[ source] =  item;
    
    Map<DateTime, CatalogueItem> analayisMap = catalogue.putIfAbsent(assembly.node, () => {});
    analayisMap[assembly.analysis] = item;
  }
  
  bool isDownloaded(Uri source) {
    return itemsDownloaded.containsValue( source);
  }
}
