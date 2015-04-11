library web_site_listing_parser;

import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart';

class Item {
  final String uri;
  final String name;
  final String size;
  final String lastModifiedAt;

  bool get isDirectory => name.endsWith("/");

  Item(this.uri, this.name, this.size, this.lastModifiedAt);
}

typedef void ProcessItem(Item item);

void parseWebSite(String htmlPage, ProcessItem callback) {
  Document document = parse(htmlPage);
  List<Element> table = document.getElementsByTagName('table');
  if (table.length != 1) {
    throw new FormatException(
        "Html page did not contain one and only one table element");
  }
  List<Element> rows = table[0].getElementsByTagName("tr");
  if (rows.length < 4) {
    throw new FormatException(
        "Html page did not contain a table with at least 4 rows");
  }
 
  //remove the header stuff
  rows = rows.sublist(3);
  
  rows.forEach((row) {

    List<Element> tableDatas = row.getElementsByTagName("td");

    //ignore empty rows
    if (tableDatas.length > 0) {
      if (tableDatas.length < 5) {
        throw new FormatException(
            "Html page contained a listing row without 5 cells but had ${tableDatas.length}");
      }
      
      List<Element> links = tableDatas[1].getElementsByTagName("a");
      if( links.length != 1){
        throw new FormatException( "Html page contained a listing row without a link in the second cell");
      }
      String url = links[0].attributes["href"];
      String name = links[0].text;
      
      String lastModified = tableDatas[2].text; 
      
      callback( new Item(url, name, "", lastModified));
      
    }
  });
}




