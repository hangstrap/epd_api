
import "dart:async";

class ProductSource{
  
}


class Location{
  
}

class ElementSource{
  
}
class Edition{
  DateTime analysisAt;
  DateTime validFrom;
  DateTime validTo;
  var dartum;
}
class Timeseries{
  Location location;
  ProductSource productsource;
  ElementSource elementsource;
  List<Edition> editions;
}

class TimeseriesDataCache{
    
  Future<List<Timeseries>> getTimeseriesForAnalysis( ProductSource ps, Location l, ElementSource es, DateTime analysis, DateTime from, Duration period){
    return null;
  }

  Future<List<Timeseries>> getLatestTimeseries( ProductSource ps, Location l, ElementSource es, DateTime from, Duration period){
    return null;
  }
}