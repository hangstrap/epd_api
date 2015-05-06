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

    Map<DateTime, CatalogueItem> analysis = analysissFor(node);
    if (analysis != null) {
      analysis.forEach((analysis, catalogueItem) {
        if (catalogueItem.fromTo.isPeriodsOverlaps(validFromTo)) {
          result.add(analysis);
        }
      });
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
