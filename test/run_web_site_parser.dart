import '../bin/web_site_listing_parser.dart' ;


import 'package:http/http.dart' as http;

import "dart:async";
void main(){
  
  
  void processItem(Item item){
    
    print( "parsed ${item.name} ${item.uri} ${item.lastModifiedAt}");
  }
  
  
  Uri url = new Uri.http("amps-caf-output.met.co.nz", "ICE");
  
  http.get(url).then((response){ 
  
    parseWebSite( response.body, processItem);
    
    
  }).catchError((error) => print("response ${error}"));

}