library web_site_listing_parser;

import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart';


class Item{
  final Uri uri;
  final String name;
  final String size;
  
  bool get isDirectory => name.endsWith("/");
  
  Item( this.uri, this.name, this.size);
}


typedef bool ProcessItem( Item item);

void parseWebSite( String htmlPage, ProcessItem callback){

  Document document = parse(htmlPage);
  List<Element> table = document.getElementsByTagName('table');
  if( table.length !=1){
    throw new FormatException("Html page did not contain one and only one table element");
  }
  List<Element> rows = table[0].getElementsByTagName("tr");
  if( rows.length <4){
    throw new FormatException("Html page did not contain a table with at least 4 rows");
  }
  
  rows.forEach( (row)=>print("${row.outerHtml} ${row.innerHtml}"));
  
  rows = rows.sublist( 4);
  rows.forEach((row){

    
    List<Element> tableDatas = row.getElementsByClassName("td");
    if( tableDatas.length != 5){
      throw new FormatException("Html page contained a listing row without 5 cells but had ${tableDatas.length}");
    }   
    
  });
  
}
