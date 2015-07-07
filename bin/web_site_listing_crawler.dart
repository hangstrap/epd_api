library web_site_listing_crawler;

import "dart:async";

import 'package:http/http.dart' as http;
import 'package:quiver/async.dart';
import 'package:logging/logging.dart';

import "web_site_listing_parser.dart" as parser;

final Logger _log = new Logger('caf_repository_downloader');

class Link {
  final Uri _baseUrl;
  final parser.Item _item;

  Link(this._baseUrl, this._item);

  ///Given http://server/path/name.txt
  ///will return /path/name.txt
  String get pathName {
    String path = _baseUrl.path;
    //Remove any extentions
    if (path.lastIndexOf(".") > 0) {
      path = path.substring(0, path.lastIndexOf("."));
    }
    if (path[0] != "/") {
      path = "/${path}";
    }
    return "${path}/${_item.uri}";
  }

  Uri get url {
    return new Uri.http(_baseUrl.authority, pathName);
  }
  String get name => _item.name;
  String get size => _item.size;
  String get lastModifiedAt => _item.lastModifiedAt;
  bool get isDirectory => _item.isDirectory;
  bool get isFile => !_item.isDirectory;
}
///Callback fuction used by the web site listing crawler function.
typedef bool FoundLink(Link link);

///Itterates through the links on the web site, optionally  decending into subpages
Future crawl(Uri url, FoundLink callback) {
  _log.fine("about to crawl ${url}");

  FutureGroup fg = new FutureGroup();

  fg.add(http.get(url).then((response) {
    if( response.statusCode != 200){
      throw "request return status of ${response.statusCode}";
    }
    parser.parseWebSite(response.body, (parser.Item item) {
      Link link = new Link(url, item);
      bool goInto = callback(link);
      if ((item.isDirectory) && (goInto)) {
        fg.add(crawl(link.url, callback));
      }
    });
  }).catchError((onError) => _log.warning("Error ${url}  ${onError}")));

  return fg.future;
}
