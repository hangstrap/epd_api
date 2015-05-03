library utils;

import "package:quiver/core.dart";

class Period {
  DateTime from;
  DateTime toEx;
  Period();
  Period.create(this.from, this.toEx);

  int get hashCode {
    return hashObjects([from, toEx]);
  }

  bool operator ==(other) {
    if (other is! Period) return false;
    Period key = other;
    return (key.from == from && key.toEx == toEx);
  }

  String toString() {
    return "${from.toIso8601String()} - ${toEx.toIso8601String()}";
  }

  bool isPointInside(DateTime dt) {
    return !( isPointBefore( dt) || isPointAfter(dt));
  }

  bool isPointBefore(DateTime dt) {
    return dt.isBefore(from);
  }
  bool isPointAfter(DateTime dt) {
    if (dt.isAfter(toEx)) {
      return true;
    }
    if (dt.isAtSameMomentAs(toEx)) {
      return true;
    }
    return false;
  }
}
Duration parseDuration(String period) {
  int days = 0;
  int hours = 0;
  int minutes = 0;
  int seconds = 0;

  RegExp exp = new RegExp(r'(\d*[dhms])?');
  exp.allMatches(period).forEach((Match m) {
    String token = m.group(0);
    if (token.length != 0) {
      int value = int.parse(token.substring(0, token.length - 1));

      var unit = token.substring(token.length - 1);
      switch (unit) {
        case 'd':
          days = value;
          break;
        case 'h':
          hours = value;
          break;
        case 'm':
          minutes = value;
          break;
        case 's':
          seconds = value;
          break;
      }
    }
  });

  return new Duration(days: days, hours: hours, minutes: minutes, seconds: seconds);
}
