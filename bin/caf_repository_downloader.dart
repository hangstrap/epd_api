library caf_repository_downloader;
import 'web_site_listing_crawler.dart' as crawler;
import "dart:io";
import 'dart:core';
import 'package:intl/intl.dart';


void downloaderCafFilesFromWebSite(Uri url,Directory destination, DateTime lastDownloaded){
  
  DateTime convertDate( String dateStr){
    //27-Mar-2015 22:13
    new DateFormat( )
  }
  

  void downloadIfNecessary( crawler.Link link){
    
  }

  bool foundLink(crawler.Link link){
    
    if( link.name.endsWith( '.caf')){
      downloadIfNecessary( link);
    } 
    return true;
  }

  

}
