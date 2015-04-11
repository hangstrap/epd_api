library web_site_listing_crawler;

import "web_site_listing_parser.dart" as parser;
import "dart:async";
//import "dart:core";
import 'package:http/http.dart' as http;
import 'package:quiver/async.dart';


class Link {
  final Uri _baseUrl;
  final parser.Item _item;x
  Link(this._baseUrl, this._item);

  Uri get url => _baseUrl.resolve(_item.uri);
  String get name => _item.name;
  String get size => _item.size;
  String get lastModifiedAt => _item.lastModifiedAt;
  bool get isDirectory => _item.isDirectory;
}
///Callback fuction used by the web site listing crawler function.
typedef bool FoundLink(Link link);


///Itterates through the links on the web site, optionally  decending into subpages
Future crawl(Uri url, FoundLink callback) {
  print("about to crawl ${url}");

  FutureGroup fg = new FutureGroup();
  fg.add(http.get(url).then((response) {
    parser.parseWebSite(response.body, (parser.Item item) {
      Link link = new Link(url, item);
      bool goInto = callback(link);
      if ((item.isDirectory) && (goInto)) {
        fg.add(crawl(link.url, callback));
      }
    });
  }));

  return fg.future;
}
