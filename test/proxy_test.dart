import 'package:mock/mock.dart';

class MyClass {
  String field;
}
@proxy
class MockMyClass extends Mock implements MyClass{}