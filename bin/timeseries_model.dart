library timeseries_model;


class Product {
  final String name;
  Product(this.name);
}
class Model{
  final String name;
  Model(this.name);  
}




class Location{
  final String name;
  final String suffex;
  Location(this.name, this.suffex);
  
}

class Element{
  final String name;
  Element(this.name);
}

class TimeseriesAnalysis{
  final Product product;
  final Model model;
  final Location location;
  final Element element;  
  final DateTime analysisAt;
  
  TimeseriesAnalysis( this.product, this.model, this.analysisAt, this.element, this.location );
}


class Edition{ 
  final TimeseriesAnalysis analysis;
  final DateTime validFrom;
  final DateTime validTo;

  final Map dartum;
  
  Edition.createMean ( this.analysis, this.validFrom, this.validTo, this.dartum );
      
}

class TimeseriesAssembly{
  
  final TimeseriesAnalysis key;
  final List<Edition> editions;
  
  TimeseriesAssembly( this.key, this.editions);
}
