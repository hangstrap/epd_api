import 'package:unittest/unittest.dart';
import '../bin/caf_file_system_datasource.dart';
import '../bin/timeseries_model.dart';
import '../bin/timeseries_catalogue.dart';
import '../bin/utils.dart';

import 'dart:io';

main(){


  
  group( "CafFileSystemDatasource", (){
    
    group( "generate datasouce", (){
      
      test( "Should create correct catalogue", () async{

          Directory source = new Directory("test/test-data");

          TimeseriesCatalogue timeseriesCatalogue = await generateCataloge( source);

          //Only expect to find one caf file
          expect( timeseriesCatalogue.numberOfNodes, equals(1));          
          Map<DateTime, CatalogueItem> ayalysiss = timeseriesCatalogue.analysissFor( new TimeseriesNode.create("City, Town & Spot Forecasts", "PDF-PROFOUND", "TTTTT", "99647", "INTL"));
          expect( ayalysiss.length, equals(1));
          DateTime analysis = new DateTime.utc(2015,02,15, 03, 00);
          DateTime prog1 = new DateTime.utc(2015,02,15, 04, 00);          
          expect( ayalysiss[analysis], equals(  new Period.create( analysis, prog1)));
          
        
      });
    });
    
  });
  
}