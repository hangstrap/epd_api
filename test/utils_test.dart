import 'package:unittest/unittest.dart';

import '../bin/utils.dart';

main() {
  group("Duration decoder", () {
    test("days", () {
      expect(parseDuration("2d"), equals(new Duration(days: 2)));
      expect(parseDuration("14d"), equals(new Duration(days: 14)));
    });
    test("hours", () {
      expect(parseDuration("2h"), equals(new Duration(hours: 2)));
      expect(parseDuration("14h"), equals(new Duration(hours: 14)));
    });
    test("minutes", () {
      expect(parseDuration("2m"), equals(new Duration(minutes: 2)));
      expect(parseDuration("14m"), equals(new Duration(minutes: 14)));
    });
    test("seconds", () {
      expect(parseDuration("2s"), equals(new Duration(seconds: 2)));
      expect(parseDuration("14s"), equals(new Duration(seconds: 14)));
    });
    test("combined", () {
      expect(parseDuration("14d6h5m2s"), equals(new Duration(days: 14, hours: 6, minutes: 5, seconds: 2)));
      expect(parseDuration("4h5s"), equals(new Duration(hours: 4, seconds: 5)));
    });
  });

  group("Period", () {
    DateTime from = new DateTime(2015, 5, 1, 0, 0, 0);
    DateTime toEx = from.add(new Duration(hours: 1));

    DateTime before = from.subtract(new Duration(hours: 1));
    DateTime inside = from.add(new Duration(minutes: 30));
    DateTime after = toEx.add(new Duration(hours: 1));


    Period underTest = new Period.create(from, toEx);

    test("method isInside ", () {
      expect(underTest.isPointInside(before), isFalse);
      expect(underTest.isPointInside(from), isTrue);
      expect(underTest.isPointInside(inside), isTrue);
      expect(underTest.isPointInside(toEx), isFalse);
      expect(underTest.isPointInside(after), isFalse);
    });
      
    test("method isBefore ", () {
      expect(underTest.isPointBefore(before), isTrue);
      expect(underTest.isPointBefore(from), isFalse);
      expect(underTest.isPointBefore(inside), isFalse);
      expect(underTest.isPointBefore(toEx), isFalse);
      expect(underTest.isPointBefore(after), isFalse);
    });
    test("method isAfter ", () {
      expect(underTest.isPointAfter(before), isFalse);
      expect(underTest.isPointAfter(from), isFalse);
      expect(underTest.isPointAfter(inside), isFalse);
      expect(underTest.isPointAfter(toEx), isTrue);
      expect(underTest.isPointAfter(after), isTrue);
    });
    
    
  });
}
