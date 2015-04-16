library caf_file_retriever;

import "dart:async";
import "timeseries_model.dart";

import "caf_file_decoder.dart" as decoder;
import "dart:io";


class CafFileRetriever {

  String pathToData;

  CafFileRetriever(this.pathToData);

  Future<TimeseriesAssembly> loadTimeseres(TimeseriesNode node, DateTime analysis) async {

    String cafFileName = decoder.fileNameForTimeseriesAnalysis(node, analysis);
    File cafFile = new File("${pathToData}/${cafFileName}");

    List<String> lines = await cafFile.readAsLines();
    return decoder.toTimeseiesAssembly(lines);

  }
}
