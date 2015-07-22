import 'package:test/test.dart';

import 'dart:async';
import 'matchers.dart';
import '../bin/web_site_listing_parser.dart';

void main() {
//  test("throw exception when page doesnt contain a table", () {
//    String html = """<!DOCTYPE html PUBLIC "<html>
//  <head><meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
//  </head><body></body></html>""";
//
//    Future processItem(Item item) {
//      return new Future();
//    }
//
//    expect(() => parseWebSite(html, processItem), throwsA(exceptionMatching(FormatException,"Html page did not contain one and only one table element")));
//  });
//
//  test("throw exception when table doesnt contain at least 4 rows", () {
//    String html = """<!DOCTYPE html PUBLIC "<html>
//  <head><meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
//  </head><body>
//  <table>
//  <tr/><tr/><tr/>
//  </table>
//  </body></html>""";
//
//    Future processItem(Item item) {
//      return new Future();
//    }
//
//    expect(() => parseWebSite(html, processItem), throwsA(exceptionMatching(FormatException,"Html page did not contain a table with at least 4 rows")));
//  });
//
//  test("throw exception if any rows > 3 do not contain 5 table data cells", () {
//    String html = """<!DOCTYPE html PUBLIC "<html>
//  <head><meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
//  </head><body>
//  <table>
//    <tr id="0"/>
//    <tr id="1"/>
//    <tr id="2"/>
//    <tr id="3"><td/><td/><td/><td/><tr/>
//  </table>
//  </body></html>""";
//
//    Future processItem(Item item) {
//      return new Future();
//    }
//
//    expect(() => parseWebSite(html, processItem), throwsA(exceptionMatching(FormatException,"Html page contained a listing row without 5 cells but had 4")));
//  });
//
//  test("throw exception if any rows > 3 do not a link in the second cell", () {
//
//    String html = """<!DOCTYPE html PUBLIC "<html>
//  <head><meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
//  </head><body>
//  <table>
//    <tr/><tr/><tr/>
//    <tr><td/><td>This is not a link<td/><td/><td/><td/><tr/>
//  </table>
//  </body></html>""";
//
//    Future processItem(Item item) {
//      return new Future.value();
//    }
//
//    expect( () async{ await parseWebSite(html, processItem);}, throwsA(exceptionMatching(FormatException,"Html page contained a listing row without a link in the second cell")));
//  });

  test("processItem should be called back with the correct values for the row", () async {

    String html = """<!DOCTYPE html PUBLIC "<html>
  <head><meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
  </head><body>
  <table>
    <tr/><tr/><tr/>
    <tr><td/><td><a href="urlToResource">nameOfResource</a></td><td>16-Feb-2015 02:00</td><td/><td/><tr/>
  </table>
  </body></html>""";

    Item result = null;

    Future processItem(Item item) {
      result = item;
      return new Future.value();
    }

    await parseWebSite(html, processItem);
    print("done!");
    expect(result, isNotNull);
    expect(result.uri, equals("urlToResource"));
    expect(result.name, equals("nameOfResource"));
    expect(result.lastModifiedAt, equals("16-Feb-2015 02:00"));
  });
}
