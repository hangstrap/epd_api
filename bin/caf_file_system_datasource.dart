library caf_files_system_datasource;

import "dart:io";
import "dart:async";
import "timeseries_model.dart";
import "package:quiver/io.dart";
import "json_converters.dart";
import "caf_file_decoder.dart" as decoder;
import 'package:jsonx/jsonx.dart' as jsonx;

class CafFileSystemDatasource {
  Directory sourceDirectory;

  TimeseriesCatalogue catalogue = new TimeseriesCatalogue();

  CafFileSystemDatasource(this.sourceDirectory) {
    generateCataloge(sourceDirectory).then((cat) => this.catalogue = cat);
  }
}

Future<TimeseriesCatalogue>  generateCataloge (Directory source) async {
  TimeseriesCatalogue result = new TimeseriesCatalogue();

  Future<bool> _visit(FileSystemEntity f) {
    
    print( f.path);
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
/*
main(){
  
  setUpJsonConverters();
  
  CafFileSystemDatasource ds = new CafFileSystemDatasource( new Directory("data"));
  
  new Future.delayed( new Duration( seconds:20)).then( (_) => print( jsonx.encode( ds, indent:" ")));
  
}
*/