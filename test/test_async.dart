import 'dart:async';
import 'package:test/test.dart';

main() {

  test("test2", () async {
    expect(await throws, throwsException);
  });

//  test("test", () async {
//    await myCall2();
//    print("done");
//  });
}

Future throws() async {
  throw new FormatException("hello");
}

Future myCall() async {
  for (var item in ["0", "1", "2"]) {
    print("about to callback");
    await futurePrint(item);
    print("done  callback");
  }
  ;
  print("done mycall");
  return new Future.value();
}


Future myCall2() async{

  await ["0", "1", "2"].forEach((item) async{
    print("about to callback");
    await futurePrint(item);
    print("done  callback");
  });
  print("done mycall");
  return new Future.value();
}
Future futurePrint(String str) {
  print("string = ${str}");
  return new Future.value();
}
