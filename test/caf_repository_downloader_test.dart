import 'package:unittest/unittest.dart';

import 'package:intl/intl.dart';


main(){
  test( "Date formatter",(){
    
    //27-Mar-2015 22:13
    DateFormat df = new DateFormat( "d-MMM-y HH:mm");
    
    expect( df.parse( "27-Mar-2015 22:13"), equals( new DateTime(2015, 3,27,22,13)));
    
  });
}