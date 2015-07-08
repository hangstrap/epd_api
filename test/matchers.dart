library matchers;

import 'package:test/test.dart';

///assumes exception has a field called message
class _ExceptionWithMessageMatcher extends Matcher {
  final String expectedMessage;
  final Type exceptionType;

  const _ExceptionWithMessageMatcher(this.exceptionType, this.expectedMessage);
  bool matches(item, Map matchState) {
    if (item.runtimeType == exceptionType) {
      try {
        return (item.message == expectedMessage);
      } catch (e) {
        //Some exceptions have the message in a field 'msg'
        return (item.msg == expectedMessage);
      }
    }
    return false;
  }

  Description describe(Description description) => description.add('${exceptionType} with a message of ').addDescriptionOf(expectedMessage);
}
Matcher exceptionMatching(type, message) => new _ExceptionWithMessageMatcher(type, message);

class _DoubleMatcher extends Matcher {
  final num expected;
  final num error;
  String err = "";

  _DoubleMatcher(this.expected, this.error);

  bool matches(item, Map matchState) {
    num diff = item - expected;
    diff = diff.abs();
    if (diff > error) {
      err = "                          diff=${diff}";
      return false;
    } else {
      return true;
    }
  }

  Description describe(Description description) => description.add("${expected}").addDescriptionOf(err);
}

Matcher doubleMatcher(num expected, {num error:1.0e-11}) => new _DoubleMatcher(expected, error);