import 'dart:async';

import 'package:unittest/unittest.dart';

import "../bin/timeseries_catalogue.dart";
import "../bin/timeseries_model.dart";
import '../bin/json_converters.dart';
import '../bin/utils.dart';


Future<Map<DateTime, CatalogueItem>>  nullLoader(TimeseriesNode node) {
  print( "null loader ${node}");  
  return new Future.value({});
}

Future nullSaver(TimeseriesNode node, Map<DateTime, CatalogueItem> catalogue) {
  return new Future.value();
}

main() {
  setUpJsonConverters();

  TimeseriesNode node =
      new TimeseriesNode.create("City Town & Spot Forecasts", "PDF-PROFOUND", "TTTTT", "01492", "INTL");
  DateTime _0am = new DateTime.utc(2013, 4, 1, 00, 00);

  DateTime beforeAnalysis = _0am.subtract(new Duration(hours: 1));
  DateTime wellBeforeAnalysis = _0am.subtract(new Duration(hours: 2));

  DateTime _1am = _0am.add(new Duration(hours: 1));
  DateTime _2am = _0am.add(new Duration(hours: 2));
  DateTime _3am = _0am.add(new Duration(hours: 3));
  DateTime _4am = _0am.add(new Duration(hours: 4));
  DateTime _5am = _0am.add(new Duration(hours: 5));
  DateTime _6am = _0am.add(new Duration(hours: 6));

  DateTime afterAnalysis = _0am.add(new Duration(hours: 100));
  DateTime wellAfterAnalysis = _0am.add(new Duration(hours: 101));

  group("TimeseriesCatalog", () {
    test("Add a single Analysis with a single spot edition", () async {
      TimeseriesCatalogue catalog = new TimeseriesCatalogue(nullLoader, nullSaver);
      TimeseriesAssembly assembly =
          new TimeseriesAssembly.create(node, _0am, [new Edition.createMean(_0am, _1am, _1am, {})]);
      await catalog.addAnalysis(assembly);

      Map<DateTime, CatalogueItem> analysisMap = await catalog.analysissFor(node);
      expect(analysisMap.length, equals(1));
      expect(analysisMap[_0am].analyis, equals(_0am));
      expect(analysisMap[_0am].fromTo, equals(new Period.create(_1am, _1am)));
    });

    test("Add a single Analysis with a two interval period editions", () async {
      TimeseriesCatalogue catalog = new TimeseriesCatalogue(nullLoader, nullSaver);
      TimeseriesAssembly assembly = new TimeseriesAssembly.create(
          node, _0am, [new Edition.createMean(_0am, _1am, _2am, {}), new Edition.createMean(_0am, _2am, _3am, {})]);
      await catalog.addAnalysis(assembly);

      Map<DateTime, CatalogueItem> analysisMap = await catalog.analysissFor(node);

      expect(analysisMap.length, equals(1));
      expect(analysisMap[_0am].analyis, equals(_0am));
      expect(analysisMap[_0am].fromTo, equals(new Period.create(_1am, _3am)));
    });

    test("Add a two Analysis for the same node", () async {
      TimeseriesCatalogue catalog = new TimeseriesCatalogue(nullLoader, nullSaver);
      TimeseriesAssembly assembly =
          new TimeseriesAssembly.create(node, _0am, [new Edition.createMean(_0am, _1am, _1am, {}),]);
      await catalog.addAnalysis(assembly);

      DateTime analysisAt2 = _0am.add(new Duration(hours: 1));
      TimeseriesAssembly assembly2 =
          new TimeseriesAssembly.create(node, analysisAt2, [new Edition.createMean(analysisAt2, _2am, _2am, {}),]);
      await catalog.addAnalysis(assembly2);

      Map<DateTime, CatalogueItem> analysisMap = await catalog.analysissFor(node);
      expect(analysisMap.length, equals(2));
      expect(analysisMap[_0am].fromTo, equals(new Period.create(_1am, _1am)));
      expect(analysisMap[analysisAt2].fromTo, equals(new Period.create(_2am, _2am)));
    });

    group("findAnalysisCoveredByPeriod", () {
      TimeseriesCatalogue catalog;
      TimeseriesAssembly assembly00 =
          new TimeseriesAssembly.create(node, _0am, [new Edition.createMean(_0am, _0am, _3am, {})]);
      TimeseriesAssembly assembly01 =
          new TimeseriesAssembly.create(node, _1am, [new Edition.createMean(_1am, _1am, _4am, {})]);
      TimeseriesAssembly assembly02 =
          new TimeseriesAssembly.create(node, _2am, [new Edition.createMean(_2am, _2am, _5am, {})]);

      setUp(() async {
        catalog = new TimeseriesCatalogue(nullLoader, nullSaver);
        await catalog.addAnalysis(assembly00);
        await catalog.addAnalysis(assembly01);
        await catalog.addAnalysis(assembly02);
      });

      test("an unknown node should return a empty map", () async {
        TimeseriesCatalogue catalog = new TimeseriesCatalogue(nullLoader, nullSaver);
        expect(await catalog.findAnalysissForPeriod(node, new Period.create(_1am, _2am)), isEmpty);
      });
      test("an period before the analysis should return a empty map", () async {
        await catalog.addAnalysis(assembly00);
        expect(
            await catalog.findAnalysissForPeriod(node, new Period.create(wellBeforeAnalysis, beforeAnalysis)), isEmpty);
      });

      test("an period after the analysis should return a empty map", () async {
        expect(
            await catalog.findAnalysissForPeriod(node, new Period.create(afterAnalysis, wellAfterAnalysis)), isEmpty);
      });
      test("an period that covers all the anaysis period should return all analysis", () async {
        List<DateTime> result = await catalog.findAnalysissForPeriod(node, new Period.create(_0am, _5am));
        expect(result.length, equals(3));
        expect(result.elementAt(0), equals(_0am));
        expect(result.elementAt(1), equals(_1am));
        expect(result.elementAt(2), equals(_2am));
      });
      test("an period that is totally within the last anaysis period should only return the last analysis", () async {
        List<DateTime> result = await catalog.findAnalysissForPeriod(node, new Period.create(_2am, _5am));
        expect(result.length, equals(1));
        expect(result.elementAt(0), equals(_2am));
      });
      test("an period that intersects with the last two anaysis periods should return the last two analysis", () async {
        TimeseriesAssembly assembly03 =
            new TimeseriesAssembly.create(node, _3am, [new Edition.createMean(_3am, _5am, _6am, {})]);
        await catalog.addAnalysis(assembly03);

        List<DateTime> result = await catalog.findAnalysissForPeriod(node, new Period.create(_4am, _6am));
        expect(result.length, equals(2));
        expect(result.elementAt(0), equals(_2am));
        expect(result.elementAt(1), equals(_3am));
      });
    });
  });

}
