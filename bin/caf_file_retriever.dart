import 'package:intl/intl.dart';
import "dart:async";
import "timeseries_data_cache.dart";

class CAF {

}

class CafFileRetriever {

  Future<CAF> getCafFor(String filename) {
    //TODO
    //check the file system
    //then extract for back end
    return null;
  }
}

String fileNameForTimeseriesAnalysis(TimeseriesAnalysis key) {

  String sanitise(String str) {
    return str.replaceAll(new RegExp("[^0-9a-zA-Z/-]"), "");
  }

  String product = sanitise(key.product.name);
  String model = sanitise(key.model.name);

  var formatter = new DateFormat('yyyyMMddHHmm');
  String analysisAt = formatter.format(key.analysisAt);
  String element = sanitise(key.element.name);
  String nameSuffix = _createLocationSuffix(sanitise(key.location.name), key.location.suffex);




  return "${product}/${model}/${analysisAt}Z/${element}/${product}.${model}.${analysisAt}Z.${element}.${nameSuffix}.caf";
}

String fileNameForCafFile(List<String> cafFileContents) {

  String findToken(String token) {
    String line = cafFileContents.firstWhere((String line) => line.indexOf(token) == 0);
    return line.substring(token.length + 2);
  }

  String sanitise(String str) {
    return str.replaceAll(new RegExp("[^0-9a-zA-Z/-]"), "");
  }

  String product = sanitise(findToken("product"));
  String model = sanitise(findToken("model-group"));
  String analysis = sanitise(findToken("init-time"));
  String element = sanitise(findToken("vha-code"));
  String location = sanitise(findToken("station"));
  String suffix = findToken("station-99suffix");
  String locationSuffix = _createLocationSuffix(location, suffix);

  return "${product}/${model}/${analysis}/${element}/${product}.${model}.${analysis}.${element}.${locationSuffix}.caf";

}
TimeseriesAnalysis toTimeseriesAnalysis(List<String> cafHeaderBlock) {

  String findToken(String token) {
      String line = cafHeaderBlock.firstWhere((String line) => line.indexOf(token) == 0);
      return line.substring(token.length + 2);
    }

    Product product = new Product( findToken("product"));
    Model model = new Model( findToken("model-group"));
    DateTime analysis = DateTime.parse( findToken("init-time"));
    Element element = new Element( findToken("vha-code"));
    Location location = new Location(findToken("station"), findToken("station-99suffix"));
    
    
    return new TimeseriesAnalysis( product, model, analysis, element, location);
  
}
Edition toEdition( List<String> cafBlock, TimeseriesAnalysis analysis){
  
    String findToken(String token) {
      String line = cafBlock.firstWhere((String line) => line.indexOf(token) == 0);
      return line.substring(token.length + 2);
    }
  
    String progPeriod = findToken( "prog");
    
      
}




TimeseriesAssembly toTimeseiesAssembly(List<String> cafFileContents) {


}
List<List<String>> breakIntoCafBlocks(List<String> cafFileContents) {

  List<List<String>> result = [];
  List<String> block = [];
  
  
  cafFileContents.forEach((String line) {

    if (line.length == 0) {
      if (block.length != 0) {
        result.add(block);
        block = [];
      }

    } else {
      block.add(line);
    }

  });

  if (block.length != 0) {
    result.add(block);
  }

  return result;
}



String _createLocationSuffix(String name, String suffix) {

  if (name.length == 5 || name.length == 6) {
    if (name.indexOf("99") == 0) {
      return "${name}-${suffix}";
    }
  }
  return name;
}
