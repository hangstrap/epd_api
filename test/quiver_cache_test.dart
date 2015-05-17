import 'dart:async';
import 'package:unittest/unittest.dart';
import "package:quiver/cache.dart";
import "package:quiver/async.dart";
import "package:quiver/core.dart";


void main(){
  
      test( "test", () async{
    
        int count=0;
        Future<String> loader (String key){
          count ++;
          print( "inside");
          return new Future.delayed( new Duration( seconds:1), ()=>"Test");
        }
        
        MapCache<String, String> cache = new MapCache.lru();
        FutureGroup f = new FutureGroup();
        f.add( cache.get( "test", ifAbsent:loader));
        f.add( cache.get( "test", ifAbsent:loader));
        
        await f;
        expect( count, equals(1));
      });
}