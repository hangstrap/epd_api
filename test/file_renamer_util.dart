import "package:quiver/io.dart" as io;
import "dart:io";
import "dart:async";
import '../bin/caf_file_retriever.dart' as caf;

void main(){
  
  var source = "/home/richard/Downloads/TTTTT";
  var desct = "/home/richard/Documents/GitHub/epd_api_shelf/data";
  
  io.visitDirectory( new Directory( source), (FileSystemEntity entity){
    
    print( entity.path);
    
    if( entity is File){
      if( entity.path.endsWith( ".caf")){
          
          File file = entity;
          String newFileName = caf.fileNameForCafFile( file.readAsLinesSync());
          newFileName = "${desct}/${newFileName}";          
          print( newFileName);

          
          File newFile = new File( newFileName);
          Directory newParent = newFile.parent;
          if( !newParent.existsSync()){
            newParent.createSync(recursive:true);
          }
          
          file.renameSync( newFileName);
      }
    }
    
    return new Future.value( true);
  });
  
}