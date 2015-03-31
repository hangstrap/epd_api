import 'package:unittest/unittest.dart';
import 'package:jsonx/jsonx.dart';



main(){
  
  test("format of DateTime objects",() {
    
    
    TestDate testDate =  new TestDate()..time = new DateTime.utc(2015, 4, 1, 11, 26);
    
    objectToJsons[DateTime] = (DateTime input) => input.toIso8601String();
    
    
    String json = encode( testDate);
    expect( json, equals( '{"time":"2015-04-01T11:26:00.000Z"}'));
    
    
    
    print( json);
  });
  
}


class TestDate{
  DateTime time;
  
}
