library matchers;
import 'package:unittest/unittest.dart';


class _FormatExceptionWithMessageMatcher extends Matcher {
  final String expectedMessage;
  const _FormatExceptionWithMessageMatcher(this.expectedMessage);
  bool matches(item, Map matchState) {
    if (item is FormatException) {
      FormatException e = item;
      return (e.message == expectedMessage);
    }
    return false;
  }
  Description describe(Description description) => description.add('FormatException with a message of ').addDescriptionOf(expectedMessage);
}
Matcher formatExceptionMatching(message) => new _FormatExceptionWithMessageMatcher(message);
