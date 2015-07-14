library timeseries_model;

import "package:quiver/core.dart";
import 'utils.dart';
import 'ice-code/probability_density_function.dart';

class TimeseriesNode {
  String product;
  String model;
  String element;
  String locationName;
  String locationSuffix;

  TimeseriesNode();
  TimeseriesNode.create(this.product, this.model, this.element, this.locationName, this.locationSuffix);

  TimeseriesNode.fromNamespace(String namespace) {
    List<String> tokens = namespace.split("/");
    product = tokens[0];
    model = tokens[1];
    element = tokens[2];
    locationName = tokens[3].split(".")[0];
    locationSuffix = tokens[3].split(".")[1];
  }

  int get hashCode {
    return hashObjects([product, model, element, locationName, locationSuffix]);
  }

  bool operator ==(other) {
    if (other is! TimeseriesNode) return false;
    TimeseriesNode key = other;
    return (key.element == element 
        && key.locationName == locationName 
        && key.locationSuffix == locationSuffix 
        && key.model == model 
        && key.product == product);
  }
  String toNamespace() => "${product}/${model}/${element}/${locationName}.${locationSuffix}";
  String toString() => toNamespace();
}

class Edition {
  DateTime analysisAt;
  DateTime validFrom;
  DateTime validTo;

  Map<String, double> datum;
  ProbabilityDensityFunction _pdf;

  ProbabilityDensityFunction get pdf {
    if( _pdf==null){
      _pdf = ProbabilityDensityFunction.createFromMap( datum);
    }
    return _pdf;
  }

  double get mean => datum['mean'];

  Edition();
  Edition.createMean(this.analysisAt, this.validFrom, this.validTo, this.datum);


}

class TimeseriesAssembly {
  TimeseriesNode node;
  DateTime analysis;
  List<Edition> editions;

  TimeseriesAssembly();
  TimeseriesAssembly.create(this.node, this.analysis, this.editions) {
    editions.forEach((edition) {
      if (edition.analysisAt != analysis) {
        throw new ArgumentError("edition's analysis time does not match Assembly analysis time");
      }
    });
  }

  TimeseriesAssembly.filter(TimeseriesAssembly orignal, DateTime validFrom, Duration period) {
    this.node = orignal.node;
    this.analysis = orignal.analysis;
    this.editions = _filter(orignal.editions, validFrom, period);
  }

  Period get timePeriodOfEditions => new Period.create(editions.first.validFrom, editions.last.validTo);

  int get hashCode {
    return hashObjects([node, analysis]);
  }

  bool operator ==(other) {
    if (other is! TimeseriesAssembly) return false;
    TimeseriesAssembly key = other;
    return (key.node == node && key.analysis == analysis);
  }

  List<Edition> _filter(List<Edition> editions, DateTime validFrom, Duration period) {
    if ((validFrom == null) || (period == null)) {
      return editions;
    }

    DateTime validTo = validFrom.add(period);

    return editions.where((edition) {
      if (!edition.validTo.isBefore(validFrom)) {
        if (!edition.validFrom.isAfter(validTo)) {
          return true;
        }
      }
      return false;
    }).toList();
  }
}

class TimeseriesBestSeries {
  TimeseriesNode node;
  DateTime latestAt;
  List<Edition> editions = [];

  TimeseriesBestSeries();
  TimeseriesBestSeries.create(this.node, this.latestAt, List<TimeseriesAssembly> assemblies) {
    assemblies.forEach((assembly) {
      if (assembly.node != node) {
        throw new ArgumentError("An assembly is for the wrong node");
      }
    });
    //sort earlist analysis first
    assemblies.sort((assembly1, assembly2) => assembly1.analysis.compareTo(assembly2.analysis));

    //older editions will be replaced by newer ones
    Map<DateTime, Edition> map = {};
    assemblies.forEach((assembly) {
      assembly.editions.forEach((edition) {
        map[edition.validFrom] = edition;
      });
    });
    editions = map.values.toList();
  }
}
