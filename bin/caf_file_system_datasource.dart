library caf_files_system_datasource;

import "dart:io";
import "dart:async";
import "timeseries_catalogue.dart";
import "package:quiver/io.dart";
import "caf_file_decoder.dart" as decoder;

Future<TimeseriesCatalogue>  generateCataloge (Directory source) async {
  TimeseriesCatalogue result = new TimeseriesCatalogue();

  Future<bool> _visit(FileSystemEntity f) {
    
//    print( f.path);
    if (f.path.endsWith(".caf")) {
    
      File cafFile = f;

      cafFile.readAsLines().then((cafFileContents) {
        result.addAnalysis(decoder.toTimeseiesAssembly(cafFileContents), new Uri.file( f.path));
      });
    }
    return new Future.value(true);
  }

  return visitDirectory(source, _visit).then((_) => new Future.value(result));
}
