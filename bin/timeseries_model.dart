library timeseries_model;

import "package:quiver/core.dart";


class TimeseriesNode{
  String product;
  String model;
  String element;
  String locationName;
  String locationSuffix;
  
  TimeseriesNode( this.product, this.model, this.element, this.locationName, this.locationSuffix);
   
  int get hashCode {
    return hashObjects([product, model, element, locationName, locationSuffix]);
  }

  bool operator ==(other) {
    if (other is! TimeseriesNode) return false;
    TimeseriesNode key = other;
    return (key.element == element && key.locationName == locationName && key.locationSuffix == locationSuffix
        && key.model == model && key.product == product);
  }
}


class Edition{ 
  DateTime analysisAt;
  DateTime validFrom;
  DateTime validTo;

  Map datum;
  
  Edition.createMean ( this.analysisAt, this.validFrom, this.validTo, this.datum );     
}

class TimeseriesAssembly{
  
  TimeseriesNode node;
  DateTime analysis;
  List<Edition> editions;
  
  TimeseriesAssembly( this.node, this.analysis, this.editions);
}

class TimeseriesLatestSeries{
  TimeseriesNode node;
  DateTime latestAt;
  List<Edition> editions;
  
  TimeseriesLatestSeries( this.node, this.latestAt, this.editions);
}

List<Edition> filter( List<Edition> editions, DateTime validFrom, Duration period ){
  
    if(( validFrom == null)|| (period == null)){
      return editions;
    }
  
    DateTime validTo = validFrom.add( period);
    
    return editions.where((edition){
      
      
      if( !edition.validFrom.isBefore(validFrom)){
        if( !edition.validTo.isAfter(validTo)){
          return true;
        }
      }
      return false;
        
    }).toList();
}