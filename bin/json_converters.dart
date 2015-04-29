library json_converters;

import 'package:jsonx/jsonx.dart' as jsonx;
import 'timeseries_catalogue.dart';
import 'timeseries_model.dart';

void setUpJsonConverters() {
  
  jsonx.objectToJsons[DateTime] = (DateTime input) => input.toIso8601String();
  jsonx.jsonToObjects[DateTime] = (String input) => DateTime.parse(input);
  
  jsonx.objectToJsons[Uri] = (Uri input) => input.toString();
  jsonx.jsonToObjects[Uri] = (String input) => Uri.parse( input);

  
  jsonx.objectToJsons[TimeseriesCatalogue] = (TimeseriesCatalogue source) {
    Map result = {};
    Map catalogue = {};
    result["catalogue"] = catalogue;

    source.catalogue.forEach((TimeseriesNode node, Map<DateTime, CatalogueItem> analysiss) {
      Map<String, Object> analysisMap = {};
      catalogue[node.toNamespace()] = analysisMap;

      analysiss.forEach((DateTime analysis, CatalogueItem item) {
        var v = {"fromTo": item.fromTo, "source": item.source};
        analysisMap[analysis.toIso8601String()] = v;
      });
    });
    return result;
  };

  jsonx.jsonToObjects[TimeseriesCatalogue] = (Map rawMap) {
    TimeseriesCatalogue result = new TimeseriesCatalogue();

    Map catalogMap = rawMap ["catalogue"];

    catalogMap.forEach(( String nodeKey, Map  analysisis){
      TimeseriesNode node = new TimeseriesNode.fromNamespace( nodeKey);
      result.catalogue[node]=  {};

      analysisis.forEach( (String analysisStr, Map periodMap ){

        DateTime analysis = DateTime.parse(analysisStr);
        CatalogueItem item = jsonx.decode( jsonx.encode(periodMap), type:CatalogueItem);
        result.catalogue[node][analysis]= item;
      });

    });

    return result;
  };
}
