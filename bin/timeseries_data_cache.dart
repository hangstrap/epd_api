library timeseries_data_cache;


import "dart:async";
import "package:quiver/cache.dart";
import "package:quiver/async.dart";
import "package:quiver/core.dart";

import "timeseries_model.dart";
import "utils.dart";


/**Used to load timeseres data when there is a cache miss*/
typedef Future<TimeseriesAssembly> TimeseresLoader(TimeseriesNode key, DateTime analysis);

/**normally supplied by the catalogue*/
typedef List<DateTime> AnalysissForPeriodQuery(TimeseriesNode node, Period validFromTo);

class TimeseriesDataCache {

  TimeseresLoader loader;
  AnalysissForPeriodQuery analysisQuery;
  
  MapCache<Key, TimeseriesAssembly> cache = new MapCache.lru();

  TimeseriesDataCache(this.loader, this.analysisQuery);


  Future<TimeseriesAssembly> _loader(Key key) {
    return loader(key.node, key.analysis);
  }

  Future<TimeseriesAssembly> getTimeseriesAnalysis(TimeseriesNode node, DateTime analysis, DateTime validFrom, Duration period) async{

    Key key = new Key(node, analysis);
    
    TimeseriesAssembly assembly = await cache.get(key, ifAbsent: _loader);
    TimeseriesAssembly filteredAssembly =   new TimeseriesAssembly.filter(assembly, validFrom, period);
    return new Future.value( filteredAssembly);

  }


  Future<List<TimeseriesAssembly>> getTimeseriesAnalysisSet(List<TimeseriesNode> nodes, DateTime analysis, DateTime from, Duration period) {


    //Create a set of futures, wait for them to return, then produce the results.
    FutureGroup<TimeseriesAssembly> futures = new FutureGroup();
    nodes.forEach((TimeseriesNode node) {
      futures.add(getTimeseriesAnalysis(node, analysis, from, period));
    });

    return futures.future;
  }

  Future<TimeseriesBestSeries> getTimeseriesBestSeries(TimeseriesNode node, DateTime validFrom, Duration period) async{

      new Period.create( validFrom, validFrom.add( period));
      

      List<DateTime> analysis = analysisQuery(node, new Period.create( validFrom, validFrom.add( period)));
      if( analysis.length == 0){
        return new TimeseriesBestSeries.create(node, new DateTime.now(), []); 
      }

      FutureGroup<TimeseriesAssembly> futureGroup = new FutureGroup();      
      analysis.forEach( (analysis){
          futureGroup.add( getTimeseriesAnalysis(node, analysis, validFrom, period));          
      });
      //Wait for the data to return 
      List<TimeseriesAssembly> assemblies = await futureGroup.future;
      return new TimeseriesBestSeries.create(node, new DateTime.now(), assemblies);
  }
  Future<List<TimeseriesBestSeries>> getTimeseriesBestSeriesSet(List<TimeseriesNode> nodes, DateTime validFrom, Duration period) async{

    //Create a set of futures, wait for them to return, then produce the results.
    FutureGroup<TimeseriesBestSeries> futures = new FutureGroup();
    nodes.forEach((TimeseriesNode node) {
      futures.add(getTimeseriesBestSeries(node, validFrom, period));
    });

    return futures.future;

  }
  
}

class Key {
  final TimeseriesNode node;
  final DateTime analysis;

  Key(this.node, this.analysis);

  int get hashCode {
    return hash2(node, analysis);
  }

  bool operator ==(other) {
    if (other is! Key) return false;
    Key key = other;
    return (key.node == node && key.analysis == analysis);
  }


}
