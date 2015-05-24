library caf_files_system_datasource;

import "dart:io";
import "dart:async";

import "package:quiver/io.dart";

import "timeseries_catalogue.dart";
import "caf_file_decoder.dart" as decoder;

///Create catalogue on a existing file structure
Future<TimeseriesCatalogue> generateCataloge(Directory source) async {
  List<File> cafFiles = [];

  CataloguePersister persister = new CataloguePersister(source);
  TimeseriesCatalogue result = new TimeseriesCatalogue({}, persister.save);

  Future<bool> _visit(FileSystemEntity f) {
    if (f.path.endsWith(".caf")) {
      cafFiles.add(f);
    }
    return new Future.value(true);
  }

  await visitDirectory(source, _visit);

  cafFiles.forEach((cafFile) {
    List<String> cafFileContents = cafFile.readAsLinesSync();
    result.addAnalysis(decoder.toTimeseiesAssembly(cafFileContents));
  });

  return new Future.value(result);
}

Future main() async {
  Directory base = new Directory("data");
  return await generateCataloge(base);
}
