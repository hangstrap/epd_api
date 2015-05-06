library matchers;
import 'package:unittest/unittest.dart';


class _ExceptionWithMessageMatcher extends Matcher {
  final String expectedMessage;
  final Type expectionType;
  const _ExceptionWithMessageMatcher(this.expectionType, this.expectedMessage);
  bool matches(item, Map matchState) {
    if (item.runtimeType == expectionType) {
      return (item.message == expectedMessage);
    }
    return false;
  }
  Description describe(Description description) => description.add('${expectionType} with a message of ').addDescriptionOf(expectedMessage);
}
Matcher exceptionMatching(type, message) => new _ExceptionWithMessageMatcher(type, message);

