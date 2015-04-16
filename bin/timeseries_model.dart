library timeseries_model;

import "package:quiver/core.dart";


class TimeseriesNode{
  String product;
  String model;
  String element;
  String locationName;
  String locationSuffix;
  
  TimeseriesNode( this.product, this.model, this.element, this.locationName, this.locationSuffix);
   
  TimeseriesNode.fromNamespace( String namespace){
    List<String> tokens = namespace.split("/");
    product = tokens[0];
    model = tokens[1];
    element = tokens[2];
    locationName = tokens[3].split( ".")[0];
    locationSuffix = tokens[3].split( ".")[1];
  }
  
  int get hashCode {
    return hashObjects([product, model, element, locationName, locationSuffix]);
  }

  bool operator ==(other) {
    if (other is! TimeseriesNode) return false;
    TimeseriesNode key = other;
    return (key.element == element && key.locationName == locationName && key.locationSuffix == locationSuffix
        && key.model == model && key.product == product);
  }
  String toNamespace() =>"${product}/${model}/${element}/${locationName}.${locationSuffix}"; 
  String toString()=>toNamespace();
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
  
  TimeseriesAssembly.filter( TimeseriesAssembly orignal, DateTime validFrom, Duration period){
    this.node = orignal.node;
    this.analysis = orignal.analysis;
    this.editions = _filter(orignal.editions, validFrom, period);
  }

  Period get timePeriodOfEditions => new Period.create( editions.first.validFrom, editions.last.validTo); 

  int get hashCode {
    return hashObjects([node, analysis]);
  }

  bool operator ==(other) {
    if (other is! TimeseriesAssembly) return false;
    TimeseriesAssembly key = other;
    return (key.node == node && key.analysis == analysis );
  }

  
  List<Edition> _filter( List<Edition> editions, DateTime validFrom, Duration period ){
    
      if(( validFrom == null)|| (period == null)){
        return editions;
      }
    
      DateTime validTo = validFrom.add( period);
      
      return editions.where((edition){
        
        
        if( !edition.validTo.isBefore(validFrom)){
          if( !edition.validFrom.isAfter(validTo)){
            return true;
          }
        }
        return false;
          
      }).toList();
  }  
}

class TimeseriesLatestSeries{
  TimeseriesNode node;
  DateTime latestAt;
  List<Edition> editions;
  
  TimeseriesLatestSeries( this.node, this.latestAt, this.editions);
}

class Period{
  DateTime from;
  DateTime to;
  Period();
  Period.create( this.from, this.to);
 
  int get hashCode {
    return hashObjects([from, to]);
  }

  bool operator ==(other) {
    if (other is! Period) return false;
    Period key = other;
    return (key.from== from  && key.to == to);
  }

  String toString(){
    return "${from.toIso8601String()} - ${to.toIso8601String()}"; 
  }
}

class TimeseriesCatalogue{

  
  Map<TimeseriesNode, Map<DateTime, Period>> catalogue={};

  int get numberOfNodes => catalogue.length;
  
  
  TimeseriesCatalogue();
  
  Map<DateTime,Period> analysisFor( TimeseriesNode node){
    
    return catalogue[ node];
  }
  
  Period periodFor( TimeseriesNode node, DateTime analysis){
    return catalogue[ node.toNamespace()][analysis.toIso8601String()];
  }
  
  void addAnalysis( TimeseriesAssembly assembly){
    
      Map<DateTime, Period> analayisMap = catalogue.putIfAbsent(assembly.node, ()  => {});      
     analayisMap[assembly.analysis]= assembly.timePeriodOfEditions;
  }  
  
  
}


