import 'dart:async';
import 'package:test/test.dart';


main() {
  test("test", () async{
    await myCall();
    print("done");
  });
}

Future myCall() async{

  await futurePrint('aa');
  await ["0", "1", "2"].forEach((item) async{
    print("about to future print ${item}");
    await futurePrint(item);
    print("done future print ${item}");
  });
  print("done mycall");
  return new Future.value();
}

Future futurePrint(String str) {
  print("string = ${str}");
  return new Future.value();
}