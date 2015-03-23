import 'package:unittest/unittest.dart';

import '../bin/utils.dart';

main( ){
  
  group("Duration decoder", (){
    test( "days", (){      
      expect( parseDuration( "2d"), equals( new Duration(days:2)));
      expect( parseDuration( "14d"), equals( new Duration(days:14)));
    });    
    test( "hours", (){      
      expect( parseDuration( "2h"), equals( new Duration(hours:2)));
      expect( parseDuration( "14h"), equals( new Duration(hours:14)));
    });
    test( "minutes", (){      
      expect( parseDuration( "2m"), equals( new Duration(minutes:2)));
      expect( parseDuration( "14m"), equals( new Duration(minutes:14)));
    });
    test( "seconds", (){      
      expect( parseDuration( "2s"), equals( new Duration(seconds:2)));
      expect( parseDuration( "14s"), equals( new Duration(seconds:14)));
    });
    test( "combined", (){      
      expect( parseDuration( "14d6h5m2s"), equals( new Duration(days:14, hours:6, minutes:5, seconds:2)));
      expect( parseDuration( "4h5s"), equals( new Duration(hours:4, seconds:5)));
    });
    
  });
  
  
}