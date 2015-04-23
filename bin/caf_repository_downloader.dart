library caf_repository_downloader;

import 'web_site_listing_crawler.dart' as crawler;
import 'caf_file_decoder.dart' as deconder;
import "dart:io";
import 'dart:core';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:async';

Future<DateTime> downloaderCafFilesFromWebSite(Uri url, Directory destination, DateTime timeOfLastFileDownloaded) async {
  DateFormat df = new DateFormat("d-MMM-y HH:mm");
  DateTime latestLastModifiedTime = timeOfLastFileDownloaded;

  downloadCafFile(crawler.Link link) async {
    try {
      http.Response response = await http.get(link.url);
      if (response.statusCode != 200) {
        throw "web request failed with code of ${response.statusCode}";
      }

      print("downloaded caf file ${link.url}");
      
      String contents = response.body;
      String fileName ;
      try{
        fileName = deconder.fileNameForCafFile(contents.split("\n"));
      }catch( e){
        print( "could not parse ${link.url} due to ${e}");
      }
      File file = new File(destination.path + fileName);

      Directory newParent = file.parent;
      if (!await newParent.exists()) {
        await newParent.create(recursive: true);
      }

      await file.writeAsString(contents);
      print("saved caf file ${file}");
    } catch (onError) {
      print("error downloading caf file ${link.url} error='${onError}'");
    }
  }

  bool foundLink(crawler.Link link) {
 //  print("found link ${link.name}");
    DateTime lastModified = df.parse(link.lastModifiedAt);
    if (lastModified.isBefore(timeOfLastFileDownloaded)) {
      return false;
    }
    if (latestLastModifiedTime.isBefore(lastModified)) {
      latestLastModifiedTime = lastModified;
    }
    if (link.isDirectory) {
      return true;
    }

    if (link.name.endsWith('.caf')) {
      print("downloading caf file from ${link.url}");
      downloadCafFile(link);
    }
    return true;
  }

  await crawler.crawl(url, foundLink);

  return latestLastModifiedTime;
}

void main() {
  Uri url = new Uri.http("amps-caf-output.met.co.nz", "/ICE/DLITE");
  DateTime timeOfLastFileDownloaded = new DateTime(2015);
  Directory destination = new Directory("/temp/epdapi/");

  downloaderCafFilesFromWebSite(url, destination, timeOfLastFileDownloaded);
}
