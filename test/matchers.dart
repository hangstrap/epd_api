library matchers;

import 'package:test/test.dart';

///assumes exception has a field called message
class _ExceptionWithMessageMatcher extends Matcher {
  final String expectedMessage;
  final Type expectionType;
  const _ExceptionWithMessageMatcher(this.expectionType, this.expectedMessage);
  bool matches(item, Map matchState) {
    if (item.runtimeType == expectionType) {
      try {
        return (item.message == expectedMessage);
      } catch (e) {
        //Some exceptions have the message in a field 'msg'
        return (item.msg == expectedMessage);
      }
    }
    return false;
  }
  Description describe(Description description) => description.add('${expectionType} with a message of ').addDescriptionOf(expectedMessage);
}
Matcher exceptionMatching(type, message) => new _ExceptionWithMessageMatcher(type, message);

