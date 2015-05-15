import "package:quiver/io.dart" as io;
import "dart:io";
import "dart:async";
import '../bin/caf_file_decoder.dart' as caf;

//*Util method to move and rename CAF files

void main(){
  
  var source = "/home/hangstrap/Documents/GitHub/epd_api/data/";
  var desct = "/home/hangstrap/Documents/GitHub/epd_api/data2";
  
  io.visitDirectory( new Directory( source), (FileSystemEntity entity){
    
//    print( entity.path);
    
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
          
          file.copySync( newFileName);
      }
    }
    
    return new Future.value( true);
  });
  
}