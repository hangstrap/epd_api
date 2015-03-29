import 'package:unittest/unittest.dart';
import '../bin/timeseries_model.dart';
import 'package:jsonx/jsonx.dart' as jsonx;

void main(){
  
  test( "JSON encode node", (){
    
    
     TimeseriesNode  node = new TimeseriesNode("City Town & Spot Forecasts", "PDF-PROFOUND","TTTTT","01492", "INTL");
    
     
    String json = jsonx.encode(node, indent: ' ');
    
    expect( json, equalsIgnoringWhitespace( jsonNode));
  
    
  });
  
}

String jsonNode = """{
 "product": "City Town & Spot Forecasts",
 "model": "PDF-PROFOUND",
 "element": "TTTTT",
 "locationName": "01492",
 "locationSuffix": "INTL"
}""";
