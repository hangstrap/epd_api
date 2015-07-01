import 'dart:io';

import 'package:test/test.dart';

import '../bin/caf_file_system_datasource.dart' as underTest;
import '../bin/timeseries_model.dart';
import '../bin/timeseries_catalogue.dart';
import '../bin/utils.dart';

main() {
  group("CafFileSystemDatasource", () {
    group("generate datasouce", () {
      test("Should create correct catalogue", () async {
        Directory source = new Directory("test/test-data");

        TimeseriesCatalogue timeseriesCatalogue = await underTest.generateCataloge(source);

        //Only expect to find one caf file
        Map<DateTime, CatalogueItem> ayalysiss = await timeseriesCatalogue.analysissFor(
            new TimeseriesNode.create("City, Town & Spot Forecasts", "PDF-PROFOUND", "TTTTT", "99647", "INTL"));
        expect(ayalysiss.length, equals(2));
        DateTime analysis = new DateTime.utc(2015, 02, 15, 03, 00);
        DateTime prog1 = new DateTime.utc(2015, 02, 15, 04, 00);

        expect(ayalysiss[analysis].analyis, equals(analysis));

        expect(ayalysiss[analysis].fromTo, equals(new Period.create(analysis, prog1)));
      });
    });
  });
}
