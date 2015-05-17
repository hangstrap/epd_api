library caf_files_system_datasource;

import "dart:io";
import "dart:async";
import "timeseries_catalogue.dart";
import "package:quiver/io.dart";
import "caf_file_decoder.dart" as decoder;


///Create catalogue on a existing file structure
Future<TimeseriesCatalogue> generateCataloge(Directory source) async {
  
  CataloguePersister persister = new CataloguePersister(source);
  TimeseriesCatalogue result = new TimeseriesCatalogue(persister.load, persister.save);

  Future<bool> _visit(FileSystemEntity f) {


    if (f.path.endsWith(".caf")) {
      
      File cafFile = f;

      cafFile.readAsLines().then((cafFileContents) {
        result.addAnalysis(decoder.toTimeseiesAssembly(cafFileContents));
      });
    }
    return new Future.value(true);
  }

  return visitDirectory(source, _visit).then((_) => new Future.value(result));
}


Future main()async{
  Directory base = new Directory( "data");
  return await generateCataloge(base);
  
}