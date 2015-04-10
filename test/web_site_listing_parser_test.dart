import 'package:unittest/unittest.dart';

import "dart:io";
import '../bin/web_site_listing_parser.dart';

void main(){
  
  test("throw exception when page doesnt contain a table", (){
    
    String html = """<!DOCTYPE html PUBLIC "<html>
  <head><meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
  </head><body></body></html>""";
  
    bool processItem( Item item){
      return false;
    }
       
    expect(()=>parseWebSite( html, processItem), throwsA( formatExceptionMatching("Html page did not contain one and only one table element")));
  });

  test("throw exception when table doesnt contain at least 4 rows", (){
    
    String html = """<!DOCTYPE html PUBLIC "<html>
  <head><meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
  </head><body>
  <table>
  <tr/><tr/><tr/>
  </table>
  </body></html>""";
  
    bool processItem( Item item){
      return false;
    }
       
    expect(()=>parseWebSite( html, processItem), throwsA( formatExceptionMatching("Html page did not contain a table with at least 4 rows")));
  });
  
  test("throw exception if any rows > 3 do not contain 5 table data cells", (){
    
    String html = """<!DOCTYPE html PUBLIC "<html>
  <head><meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
  </head><body>
  <table>
    <tr id="0"/>
    <tr id="1"/>
    <tr id="2"/>
    <tr id="3"><td/><td/><td/><td/><tr/>
  </table>
  </body></html>""";
  
    bool processItem( Item item){
      return false;
    }
       
    expect(()=>parseWebSite( html, processItem), throwsA( formatExceptionMatching("Html page contained a listing row without 5 cells but had 4")));
  });

  test("throw exception if any rows > 3 do not a link in the second cell", (){
    
    String html = """<!DOCTYPE html PUBLIC "<html>
  <head><meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
  </head><body>
  <table>
    <tr/><tr/><tr/>
    <tr><td/><td>This is not a link<td/><td/><td/><td/><tr/>
  </table>
  </body></html>""";
  
    bool processItem( Item item){
      return false;
    }
       
    expect(()=>parseWebSite( html, processItem), throwsA( formatExceptionMatching("Html page contained a listing row without a link in the second cell")));
  });

  test("processItem should be called back with the correct values for the row", (){
     
     String html = """<!DOCTYPE html PUBLIC "<html>
  <head><meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
  </head><body>
  <table>
    <tr/><tr/><tr/>
    <tr><td/><td><a href="urlToResource">nameOfResource</a></td><td>16-Feb-2015 02:00</td><td/><td/><tr/>
  </table>
  </body></html>""";
   
     Item result = null;
     bool processItem( Item item){
       result = item;
       return false;
     }
        
     parseWebSite( html, processItem);
     expect( result, isNotNull );
     expect( result.uri, equals( "urlToResource") );
     expect( result.name, equals( "nameOfResource") );
     expect( result.lastModifiedAt, equals( "16-Feb-2015 02:00") );
   });
  
  
}


class _FormatExceptionWithMessageMatcher extends Matcher  {
  final String expectedMessage;
  const _FormatExceptionWithMessageMatcher(this.expectedMessage );
  bool matches(item, Map matchState){
    if( item is FormatException){
      FormatException e = item;
      return ( e.message == expectedMessage);
    }
    return false;
  }
  Description describe(Description description) =>
    description.add('FormatException with a message of ').
        addDescriptionOf(expectedMessage);
}
Matcher formatExceptionMatching( message) => new _FormatExceptionWithMessageMatcher(message);
              