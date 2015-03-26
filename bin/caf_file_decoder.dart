library caf_file_decoder;

import 'package:intl/intl.dart';
import "timeseries_model.dart";
import "utils.dart" as utils;


TimeseriesAssembly toTimeseiesAssembly(List<String> cafFileContents) {

  List<List<String>> blocks = breakIntoCafBlocks(cafFileContents);

  TimeseriesAnalysis analysis;
  List<Edition> editions = [];

  blocks.forEach((List<String> block) {
    if (analysis == null) {
      analysis = toTimeseriesAnalysis(block);
    } else {
      editions.add(toEdition(block, analysis));
    }
  });
  return new TimeseriesAssembly(analysis, editions);
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

  String sanitise(String str) {
    return str.replaceAll(new RegExp("[^0-9a-zA-Z/-]"), "");
  }

  String product = sanitise(_findToken("product", cafFileContents));
  String model = sanitise(_findToken("model-group", cafFileContents));
  String analysis = sanitise(_findToken("init-time", cafFileContents));
  String element = sanitise(_findToken("vha-code", cafFileContents));
  String location = sanitise(_findToken("station", cafFileContents));
  String suffix = _findToken("station-99suffix", cafFileContents);
  String locationSuffix = _createLocationSuffix(location, suffix);

  return "${product}/${model}/${analysis}/${element}/${product}.${model}.${analysis}.${element}.${locationSuffix}.caf";

}
TimeseriesAnalysis toTimeseriesAnalysis(List<String> cafHeaderBlock) {


  Product product = new Product(_findToken("product", cafHeaderBlock));
  Model model = new Model(_findToken("model-group", cafHeaderBlock));
  DateTime analysis = DateTime.parse(_findToken("init-time", cafHeaderBlock));
  Element element = new Element(_findToken("vha-code", cafHeaderBlock));
  Location location = new Location(_findToken("station", cafHeaderBlock), _findToken("station-99suffix", cafHeaderBlock));


  return new TimeseriesAnalysis(product, model, analysis, element, location);

}
Edition toEdition(List<String> cafBlock, TimeseriesAnalysis analysis) {

  Duration progPeriod = utils.parseDuration(_findToken("prog", cafBlock));
  DateTime validFrom = analysis.analysisAt.add(progPeriod);

  var mean = num.parse(_findToken("mean", cafBlock));

  Map datum = {
    'mean': mean
  };

  return new Edition.createMean(analysis, validFrom, validFrom, datum);
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

String _findToken(String token, List<String> lines) {
  String line = lines.firstWhere((String line) => line.indexOf(token) == 0);
  return line.substring(line.indexOf("=") + 1);
}
