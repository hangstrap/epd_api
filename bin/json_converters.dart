library json_converters;

import 'package:jsonx/jsonx.dart' as jsonx;

void setUpJsonConverters() {
  print( "Setting up Json Coverters");
  jsonx.objectToJsons[DateTime] = (DateTime input) => input.toIso8601String();
  jsonx.jsonToObjects[DateTime] = (String input) => DateTime.parse(input);
  
  jsonx.objectToJsons[Uri] = (Uri input) => input.toString();
  jsonx.jsonToObjects[Uri] = (String input) => Uri.parse( input);

}
