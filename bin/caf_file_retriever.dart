library caf_file_retriever;

import "dart:async";
import "dart:io";

import 'package:logging/logging.dart';


import "../lib/common/timeseries_model.dart";
import "caf_file_decoder.dart" as decoder;

final Logger _log = new Logger('caf_file_retriever');

class CafFileRetriever {

  String pathToData;

  CafFileRetriever(this.pathToData);

  Future<TimeseriesAssembly> loadTimeseres(TimeseriesNode node, DateTime analysis) async {

    String cafFileName = decoder.fileNameForTimeseriesAnalysis(node, analysis);

    File cafFile = new File("${pathToData}/${cafFileName}");
    _log.info( "loading file ${cafFile.path}");
        
    List<String> lines = await cafFile.readAsLines();
    return decoder.toTimeseiesAssembly(lines);

  }
}
