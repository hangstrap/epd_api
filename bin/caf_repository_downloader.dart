library caf_repository_downloader;
import 'web_site_listing_crawler.dart' as crawler;
import 'caf_file_decoder.dart' as deconder;
import "dart:io";
import 'dart:core';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
  

Future<DateTime> downloaderCafFilesFromWebSite(Uri url,Directory destination, DateTime timeOfLastFileDownloaded){
  
  DateFormat df = new DateFormat( "d-MMM-y HH:mm");
  DateTime latestLastModifiedTime = timeOfLastFileDownloaded;
 
  bool foundLink(crawler.Link link){
    
    print( "found link ${link.name}");
    DateTime lastModified = df.parse( link.lastModifiedAt);
    if(lastModified.isBefore( timeOfLastFileDownloaded)){
      return false;
    }
   if( latestLastModifiedTime.isBefore( lastModified)){
     latestLastModifiedTime = lastModified;
   }
   if( link.isDirectory){
     
        return true;
    }
    
    if( link.name.endsWith( '.caf')){
      print( "print downloading caf file from ${link.url}");
      http.get( link.url).then((response){
        
        String contents = response.body;
        String fileName = deconder.fileNameForCafFile( contents.split("\n"));
        File file = new File( destination.path + fileName);
        
        Directory newParent = file.parent;
        if( !newParent.existsSync()){
          newParent.createSync(recursive:true);
        }

        file.writeAsString(contents).then((file)=>print( "downloaded caf file ${file}"));
      });
    } 
    return true;
  }

   
  return crawler.crawl(url, foundLink).then( (_) => latestLastModifiedTime);
}
