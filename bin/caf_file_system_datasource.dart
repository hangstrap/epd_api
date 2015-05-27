library caf_files_system_datasource;

import "dart:io";
import "dart:async";

import "package:quiver/io.dart";
import 'package:logging/logging.dart';

import "timeseries_catalogue.dart";
import "caf_file_decoder.dart" as decoder;


final Logger _log = new Logger('caf_files_system_datasource');

///Create catalogue on a existing file structure
Future<TimeseriesCatalogue> generateCataloge(Directory source) async {
  List<File> cafFiles = [];

  CataloguePersister persister = new CataloguePersister(source);
  TimeseriesCatalogue result = new TimeseriesCatalogue(persister.load, persister.save);

  Future<bool> _visit(FileSystemEntity f) {
    if (f.path.endsWith(".caf")) {
      cafFiles.add(f);
    }
    return new Future.value(true);
  }

  await visitDirectory(source, _visit);

  cafFiles.forEach((cafFile) {
    _log.info( "about to process ${cafFile}");
    List<String> cafFileContents = cafFile.readAsLinesSync();
    result.addAnalysis(decoder.toTimeseiesAssembly(cafFileContents));
  });

  return new Future.value(result);
}

Future main() async {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((LogRecord rec) {
    print('${rec.level.name}: ${rec.time}: ${rec.message}');
  });
  
  Directory base = new Directory("data");
  return await generateCataloge(base);
}
