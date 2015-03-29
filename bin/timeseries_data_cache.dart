library timeseries_data_cache;


import "dart:async";
import "package:quiver/cache.dart";
import "package:quiver/async.dart";
import "package:quiver/core.dart";

import "timeseries_model.dart";


/**Used to load timeseres data when there is a cache miss*/
typedef Future<TimeseriesAssembly> TimeseresLoader(TimeseriesNode key, DateTime analysis);

class TimeseriesDataCache {

  TimeseresLoader loader;
  MapCache<Key, TimeseriesAssembly> cache = new MapCache.lru();

  TimeseriesDataCache(this.loader);


  Future<TimeseriesAssembly> _loader(Key key) {
    return loader(key.node, key.analysis);
  }

  Future<TimeseriesAssembly> getTimeseriesAnalysis(TimeseriesNode node, DateTime analysis, DateTime from, Duration period) {

    print("inside getTimeseries");

    Key key = new Key(node, analysis);

    //todo add a filter
    return cache.get(key, ifAbsent: _loader);

  }


  Future<List<TimeseriesAssembly>> getTimeseriesAnalysisSet(List<TimeseriesNode> nodes, DateTime analysis, DateTime from, Duration period) {


    //Create a set of futures, wait for them to return, then produce the map.
    FutureGroup<TimeseriesAssembly> futures = new FutureGroup();
    nodes.forEach((TimeseriesNode node) {
      futures.add(getTimeseriesAnalysis(node, analysis, from, period));
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
