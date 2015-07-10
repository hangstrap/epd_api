import "dart:math";

import 'package:test/test.dart';

import "../lib/common/ice-code/probability_density_function.dart";
import "../lib/common/ice-code/erf.dart";

import "matchers.dart";

display(int index, num x, num expected, num actual) {
  num diff = expected - actual;
  diff = diff.abs();
  print("$index $x $expected $actual ${diff.toStringAsPrecision(1)}");
}

void main() {
  test("erf", () {

    for (int i = 0; i < expectedErf.length; i += 3)
    {
      double x = expectedErf[i];
      double expected_erfx = expectedErf[i + 1];
      double expected_erfix = expectedErf[i + 2];

      double actual_erfx = erf(x);
      double actual_erfix = erfi(x);

      expect(actual_erfx, doubleMatcher(expected_erfx));
      expect(actual_erfix, doubleMatcher(expected_erfix));
    }
  });


  group("density", ()
  {

    final List<ProbabilityDensityFunction> pdfArray = [];
    {
      //                      0            1         2          3         4           5         6          7          8          9
      List<double> x = [ 7.283316, 8.626362, 8.852718, 9.074044, 9.260159, 9.486515, 9.697780, 10.160553, 10.839621, 12.313450];
      List<double> y = [-6.849891, -0.354872, -0.628248, -0.731795, -0.807645, -1.619973, -2.211708, -2.086554, -2.024422, -7.383624];
      List<double> c = [ 1.786991, 0.038937, -0.098030, 0.118087, -0.086712, 0.106517, -0.421220, 0.280183, 0.759790];
      bool tailL = false;
      bool tailR = false;
      //mean=9.083207 var=0.742504
      pdfArray.add(new ProbabilityDensityFunction(x, y, c, tailL, tailR));
    }
    {
      //                      0            1         2          3           4          5          6           7           8          9
      List<double> x = [7.283316, 8.626362, 8.852718, 9.074044, 9.260159, 9.486515, 9.697780, 10.160553, 10.839621, 12.313450];
      List<double> y = [-6.849992, -0.354974, -0.628349, -0.731896, -0.807746, -1.620074, -2.211810, -2.086656, -2.024523, -7.383725];
      List<double> c = [1.786991, 0.038937, -0.098030, 0.118087, -0.086712, 0.106517, -0.421220, 0.280183, 0.759790];
      bool tailL = false;
      bool tailR = true;
      //mean=9.083550 var=0.743591
      pdfArray.add(new ProbabilityDensityFunction(x, y, c, tailL, tailR));
    }
    { //                      0            1         2          3           4          5          6           7           8          9
      List<double> x = [7.283316, 8.626362, 8.852718, 9.074044, 9.260159, 9.486515, 9.697780, 10.160553, 10.839621, 12.313450];
      List<double> y = [-6.849988, -0.354970, -0.628346, -0.731893, -0.807742, -1.620071, -2.211806, -2.086652, -2.024519, -7.383722];
      List<double> c = [1.786991, 0.038937, -0.098030, 0.118087, -0.086712, 0.106517, -0.421220, 0.280183, 0.759790];
      bool tailL = true;
      bool tailR = false;
      //mean=9.083023 var=0.742779
      pdfArray.add(new ProbabilityDensityFunction(x, y, c, tailL, tailR));
    }

    { //                      0            1         2          3           4          5          6           7           8          9
      final List<double> x = [7.283316, 8.626362, 8.852718, 9.074044, 9.260159, 9.486515, 9.697780, 10.160553, 10.839621, 12.313450];
      final List<double> y = [-6.850090, -0.355071, -0.628447, -0.731994, -0.807844, -1.620172, -2.211907, -2.086753, -2.024621, -7.383823];
      final List<double> c = [1.786991, 0.038937, -0.098030, 0.118087, -0.086712, 0.106517, -0.421220, 0.280183, 0.759790];
      final bool tailL = true;
      final bool tailR = true;
      //mean=9.083366 var=0.743867
      pdfArray.add(new ProbabilityDensityFunction(x, y, c, tailL, tailR));
    }

    { //                      0            1         2          3           4          5          6           7           8

      Map datum = {
      'control-points':     [7.000000, 7.000250, 7.018750, 7.045000, 7.105000, 7.258750, 7.675000, 9.500000, 10.750000],
      'logn-pdf-values':    [-9.999820, -1.131157, -0.279547, -0.126680, -0.017522, -0.021517, -0.432122, -3.529888, -6.106577],
      'curvature-values':  [3.920818, 0.337233, 0.019309, 0.018923, 0.024092, 0.036923, 0.154945, 0.000000],
      'tail-left': 0,
      'tail-right': 1
      };
      //mean=7.715046 var=0.286490
      pdfArray.add( ProbabilityDensityFunction.createFromMap( datum));
    }

    test("", () {
      for (int ipdf = 1; ipdf < pdfArray.length; ipdf++)
    {
      final ProbabilityDensityFunction pdf = pdfArray[ipdf-1];

        for (int i=0; i < expectedDensityArray.length; i++)
        {
          final double z = expectedDensityArray[i][0];
          final double exp = expectedDensityArray[i][ipdf];
          final double act = pdf.pdf(z);
          assertDecimalPlaces("Density.pdf $ipdf", i, z, exp, act, 10);
        }

        for (int i=0; i < expectedCumulativeArray.length; i++)
        {
          final double z = expectedCumulativeArray[i][0];
          final double exp = expectedCumulativeArray[i][ipdf];
          final double act = pdf.cdf(z);
          assertDecimalPlaces("Cumulative.pdf ${ipdf}", i, z, exp, act, 6);
        }

        for (int i=0; i < expectedInverseCumulativeArray.length; i++)
        {
          final double z = expectedInverseCumulativeArray[i][0];
          final double exp = expectedInverseCumulativeArray[i][ipdf];
          final double act = pdf.cdfInverse(z);
//          System.out.println(expCumulative+":"+actCumulative);
          assertDecimalPlaces("InverseCumulative.pdf $ipdf", i, z, exp, act, 6);
        }
      }
    });

  });
}

void assertDecimalPlaces(String fn, int i, double x, double expected, double actual, int places)
  {

    final double mul = pow(10.0, places);
    final int rExp = (expected * mul).round();
    final int rActual = (actual * mul).round();
    bool accept = rExp == rActual;
    if (!accept) {
      throw "${fn} (${i}: ${x})=${actual}, but expected ${expected}";
    }
  }
final List<List<double>> expectedDensityArray = [

  [ 6.0, 0.0, 0.0, 3.38208105349e-12, 3.38173286748e-12, 0.0],
  [ 6.16, 0.0, 0.0, 7.90218269321e-11, 7.90137010302e-11, 0.0],
  [ 6.32, 0.0, 0.0, 1.50728058309e-09, 1.50712576731e-09, 0.0],
  [ 6.48, 0.0, 0.0, 2.34706505315e-08, 2.34682426102e-08, 0.0],
  [ 6.64, 0.0, 0.0, 2.98359680505e-07, 2.98329106471e-07, 0.0],
  [ 6.8, 0.0, 0.0, 3.0962721309e-06, 3.09595521313e-06, 0.0],
  [ 6.96, 0.0, 0.0, 2.62314379345e-05, 2.62287561501e-05, 0.0],
  [ 7.12, 0.0, 0.0, 0.000181421626537, 0.000181403100416, 0.990617052663],
  [ 7.28, 0.0, 0.0, 0.00102433025049, 0.00102422577161, 0.96529270603],
  [ 7.44, 0.00472190344065, 0.00472142600167, 0.00472144488741, 0.00472096387535, 0.848740635608],
  [ 7.6, 0.0177678984605, 0.0177660998043, 0.0177661708688, 0.0177643630005, 0.714392497309],
  [ 7.76, 0.0545806884627, 0.0545751567213, 0.0545753750223, 0.0545698279863, 0.577596637973],
  [ 7.92, 0.136875569487, 0.136861680872, 0.13686222832, 0.136848333959, 0.46026498637],
  [ 8.08, 0.280218531484, 0.280190064635, 0.280191185397, 0.280162773544, 0.363290007155],
  [ 8.24, 0.468329754051, 0.468282121566, 0.468283994698, 0.468236565703, 0.284028027953],
  [ 8.4, 0.638984953777, 0.638919888321, 0.638922444006, 0.638857808422, 0.219953652017],
  [ 8.56, 0.711727091639, 0.711654534342, 0.711657380966, 0.71158547204, 0.16871876525],
  [ 8.72, 0.650388989548, 0.650322922277, 0.65032525455, 0.650259575016, 0.128191087548],
  [ 8.88, 0.504903038443, 0.504852045811, 0.50485356037, 0.504802572735, 0.0964749379808],
  [ 9.04, 0.464448206755, 0.464401299855, 0.464402693061, 0.464355790757, 0.0719173069968],
  [ 9.2, 0.50671863334, 0.506667457343, 0.506669320243, 0.506617806365, 0.0531024498414],
  [ 9.36, 0.286088483094, 0.286059589617, 0.286060607682, 0.286031557151, 0.0388380959821],
  [ 9.52, 0.190722785312, 0.190703493057, 0.190704095395, 0.190684835254, 0.028124476724],
  [ 9.68, 0.1189481282, 0.118936006119, 0.118936471854, 0.118924459877, 0.0202230706278],
  [ 9.84, 0.0795066826111, 0.079498573343, 0.079498891338, 0.0794908623554, 0.0145415180389],
  [10.0, 0.0811285290192, 0.0811202543312, 0.0811205788129, 0.0811123860482, 0.0104561641883],
  [10.16, 0.123846234035, 0.123833602363, 0.123834097699, 0.123821591087, 0.00751856644129],
  [10.32, 0.15403077164, 0.154015097466, 0.154015713528, 0.154000122566, 0.00540626948029],
  [10.48, 0.168954892074, 0.168937739025, 0.168938414778, 0.168921273396, 0.00388740991008],
  [10.64, 0.163641061416, 0.163624486404, 0.163625140903, 0.163608500085, 0.00279526499079],
  [10.8, 0.139949722178, 0.139935579805, 0.139936139549, 0.139921874954, 0.00200995175437],
  [10.96, 0.107078533972, 0.107067719586, 0.107068139112, 0.107057227463, 0.00144526764661],
  [11.12, 0.0760950125025, 0.0760873272943, 0.0760876171695, 0.0760798711016, 0.00103922821322],
  [11.28, 0.0503383519046, 0.0503332679878, 0.0503334542817, 0.0503283355693, 0.000747263167259],
  [11.44, 0.0309977960037, 0.0309946653844, 0.0309947767373, 0.030991628056, 0.000537323981432],
  [11.6, 0.0177685366662, 0.0177667421347, 0.0177668040355, 0.0177650010792, 0.000386365973424],
  [11.76, 0.00948116126103, 0.0094802037121, 0.00948023571275, 0.00947927469765, 0.000277818728697],
  [11.92, 0.00470934413373, 0.00470886851399, 0.00470888389769, 0.00470840706748, 0.000199767193086],
  [12.08, 0.00217745077228, 0.00217723086086, 0.00217723773743, 0.00217701750269, 0.00014364377672],
  [12.24, 0.000937184908713, 0.000937090257818, 0.000937093115794, 0.000936998427472, 0.000103287903642],
  [12.4, 0.0, 0.000375445918843, 0.0, 0.000375409126945, 7.42697754289e-05],
  [12.56, 0.0, 0.000140023966665, 0.0, 0.000140010244988, 5.34041194348e-05],
  [12.72, 0.0, 4.86123245296e-05, 0.0, 4.86075607552e-05, 3.84005466037e-05],
  [12.88, 0.0, 1.57101171755e-05, 0.0, 1.57085776594e-05, 2.76121391958e-05],
  [13.04, 0.0, 4.72608451407e-06, 0.0, 4.72562138048e-06, 1.98546713108e-05],
  [13.2, 0.0, 1.32346532306e-06, 0.0, 1.32333562981e-06, 1.42766183403e-05],
  [13.36, 0.0, 3.4499489848e-07, 0.0, 3.44961090636e-07, 1.02656864999e-05],
  [13.52, 0.0, 8.37147150368e-08, 0.0, 8.37065113967e-08, 7.38160233762e-06],
  [13.68, 0.0, 1.8909496146e-08, 0.0, 1.89076431062e-08, 5.30778463489e-06],
  [13.84, 0.0, 3.97600694498e-09, 0.0, 3.97561731539e-09, 3.81659380197e-06]
];

final List<List<double>> expectedCumulativeArray = [
  [6.0, 0.0, 0.0, 1.6334787889e-13, 1.6334787889e-13, 0.0],
  [6.16, 0.0, 0.0, 4.06062250008e-12, 4.06013789889e-12, 0.0],
  [6.32, 0.0, 0.0, 8.27332030977e-11, 8.27247412153e-11, 0.0],
  [6.48, 0.0, 0.0, 1.382244346e-09, 1.3821024324e-09, 0.0],
  [6.64, 0.0, 0.0, 1.89484656332e-08, 1.89465230161e-08, 0.0],
  [6.8, 0.0, 0.0, 2.13290064144e-07, 2.13268222311e-07, 0.0],
  [6.96, 0.0, 0.0, 1.97319424502e-06, 1.97299240825e-06, 0.0],
  [7.12, 0.0, 0.0, 1.50196900262e-05, 1.5018155386e-05, 0.104974521614],
  [7.28, 0.0, 0.0, 9.42013432718e-05, 9.41917288924e-05, 0.264052311101],
  [7.44, 0.000390063714342, 0.000390024291713, 0.000487681830856, 0.000487632111691, 0.409503147604],
  [7.6, 0.00199135894353, 0.00199115749575, 0.00208882143943, 0.00208860871484, 0.534699717814],
  [7.76, 0.0073274219763, 0.0073266799796, 0.00742436526542, 0.00742360997671, 0.637922002843],
  [7.92, 0.0218902675472, 0.0218880486115, 0.0219857921429, 0.0219835578296, 0.72066161413],
  [8.08, 0.0544420779292, 0.0544365538299, 0.0545344275556, 0.0545288910459, 0.786292417106],
  [8.24, 0.114039932781, 0.114028350403, 0.114126462496, 0.114114887105, 0.837858894718],
  [8.4, 0.203417874826, 0.203397196475, 0.203495666044, 0.203475044708, 0.877991072035],
  [8.56, 0.313213830773, 0.313181965653, 0.313280874363, 0.313249153435, 0.908928448637],
  [8.72, 0.423768820569, 0.423725693556, 0.423825031465, 0.423782144977, 0.932551704331],
  [8.88, 0.5169260467, 0.51687348736, 0.516973128635, 0.516920834664, 0.950419110978],
  [9.04, 0.591835814194, 0.591775689349, 0.591875555332, 0.591815696597, 0.963805048574],
  [9.2, 0.672388487311, 0.672320227058, 0.672420356678, 0.672352341327, 0.973738532032],
  [9.36, 0.736793536422, 0.736718771586, 0.736819146781, 0.736744575108, 0.981040162527],
  [9.52, 0.773045685078, 0.772967258448, 0.773067751723, 0.772989510305, 0.986356266191],
  [9.68, 0.798380737988, 0.798299739778, 0.798400321919, 0.798319522041, 0.99018938599],
  [9.84, 0.813391847512, 0.813309318334, 0.813409960427, 0.813327644652, 0.992945613356],
  [10.0, 0.825819437044, 0.825735640316, 0.825836332114, 0.825752761338, 0.994927494877],
  [10.16, 0.841447156646, 0.841361765973, 0.841462520275, 0.841377371335, 0.996352578456],
  [10.32, 0.863833331025, 0.863745659792, 0.86384650363, 0.863759091308, 0.997377293197],
  [10.48, 0.88992316822, 0.889832845205, 0.889933793392, 0.889843737142, 0.998114120367],
  [10.64, 0.916806188554, 0.916713139406, 0.916814195114, 0.916721408287, 0.998643940283],
  [10.8, 0.941296875205, 0.941201348234, 0.941302501895, 0.941207221776, 0.999024910414],
  [10.96, 0.961077858046, 0.960980333137, 0.961081565348, 0.960984268593, 0.99929884923],
  [11.12, 0.975677684031, 0.975578684614, 0.975679973279, 0.975581189502, 0.999495826549],
  [11.28, 0.98571042842, 0.985610415747, 0.985711742123, 0.985611937573, 0.999637464251],
  [11.44, 0.992130864781, 0.992030203677, 0.992131553493, 0.992031096395, 0.999739309674],
  [11.6, 0.995957186562, 0.995856139019, 0.995957502392, 0.995856656814, 0.999812542226],
  [11.76, 0.998080772825, 0.997979510811, 0.998080881478, 0.997979820525, 0.999865200523],
  [11.92, 0.999178334759, 0.999076961897, 0.999178336216, 0.999077164066, 0.999903064782],
  [12.08, 0.999706607291, 0.999605181076, 0.999706557096, 0.999605331482, 0.9999302913],
  [12.24, 0.999943393257, 0.999841943127, 0.999943319884, 0.999842070332, 0.999949868689],
  [12.4, 1.0, 0.999940770657, 1.0, 0.999940888177, 0.999963945925],
  [12.56, 1.0, 0.999979186522, 1.0, 0.999979300277, 0.999974068245],
  [12.72, 1.0, 0.999993092737, 1.0, 0.99999320513, 0.999981346759],
  [12.88, 1.0, 0.999997780566, 1.0, 0.999997892499, 0.999986580417],
  [13.04, 1.0, 0.999999252192, 1.0, 0.999999363981, 0.99999034371],
  [13.2, 1.0, 0.999999682406, 1.0, 0.999999794153, 0.999993049727],
  [13.36, 1.0, 0.999999799527, 1.0, 0.999999911262, 0.999994995505],
  [13.52, 1.0, 0.999999829219, 1.0, 0.999999940951, 0.999996394628],
  [13.68, 1.0, 0.999999836229, 1.0, 0.99999994796, 0.999997400676],
  [13.84, 1.0, 0.99999983777, 1.0, 0.999999949501, 0.999998124081]
];

final List<List<double>> expectedInverseCumulativeArray = [
  [0.01, 7.80270684367, 7.80272107869, 7.80134243061, 7.80135684346, 7.0163180849],
  [0.02, 7.90567420314, 7.9056901525, 7.90491966063, 7.90493571853, 7.02904637831],
  [0.03, 7.9719288296, 7.9719460565, 7.9713916493, 7.97140895426, 7.04087635817],
  [0.04, 8.0222951114, 8.02231342733, 8.02187144954, 8.02188982391, 7.05217659851],
  [0.05, 8.06363837687, 8.06365767697, 8.06328511646, 8.06330446012, 7.06313190628],
  [0.06, 8.09912354838, 8.09914376755, 8.09881849885, 8.0988387492, 7.07381551876],
  [0.07, 8.1304851399, 8.13050623556, 8.13021531287, 8.13023642886, 7.08428972057],
  [0.08, 8.15878234754, 8.15880429143, 8.15853945497, 8.1585614093, 7.094609321],
  [0.09, 8.18471220576, 8.18473497945, 8.18449061921, 8.18451339409, 7.10482395135],
  [0.1, 8.2087593996, 8.20878299185, 8.20855511246, 8.20857869711, 7.11497214497],
  [0.11, 8.23127557511, 8.23129998025, 8.23108562789, 8.23111001693, 7.12506710807],
  [0.12, 8.25252464512, 8.25254986195, 8.25234678562, 8.25237197806, 7.13511770473],
  [0.13, 8.27271025551, 8.2727362866, 8.27254272706, 8.2725687256, 7.14513253714],
  [0.14, 8.29199325291, 8.29202010411, 8.29183465671, 8.29186146723, 7.15511999893],
  [0.15, 8.31050324085, 8.31053092091, 8.31035244312, 8.31038007443, 7.16508832597],
  [0.16, 8.32834648273, 8.32837500313, 8.32820255031, 8.32823101384, 7.1750456448],
  [0.17, 8.34561146191, 8.34564083669, 8.34547361631, 8.34550292604, 7.1850000194],
  [0.18, 8.36237289094, 8.36240313664, 8.36224047484, 8.3622706472, 7.19495949709],
  [0.19, 8.37869466575, 8.37872580135, 8.37856711808, 8.37859817194, 7.2049321541],
  [0.2, 8.39463208497, 8.39466413195, 8.3945089221, 8.39454087878, 7.21492614165],
  [0.21, 8.4102335469, 8.41026652927, 8.41011434812, 8.41014723144, 7.22494973306],
  [0.22, 8.42554186818, 8.42557581258, 8.42542626439, 8.42546010077, 7.2350113728],
  [0.23, 8.44059532444, 8.44063026025, 8.4404829892, 8.4405178078, 7.24511972799],
  [0.24, 8.4554284838, 8.45546444333, 8.45531912619, 8.45535495903, 7.25528374346],
  [0.25, 8.47007288436, 8.47010990303, 8.46996624317, 8.47000312537, 7.26551188421],
  [0.26, 8.48455759319, 8.48459570976, 8.48445343215, 8.48449140214, 7.27580784021],
  [0.27, 8.4989096749, 8.49894893176, 8.49880777876, 8.49884687855, 7.28617431841],
  [0.28, 8.51315459105, 8.51319503456, 8.51305476225, 8.51309503779, 7.29661421757],
  [0.29, 8.52731654702, 8.52735822786, 8.5272186029, 8.52726010443, 7.30713055329],
  [0.3, 8.5414187994, 8.54146177303, 8.54132256976, 8.54136535225, 7.31772646578],
  [0.31, 8.55548393457, 8.55552826177, 8.55538925957, 8.55543338324, 7.32840522829],
  [0.32, 8.56953412755, 8.56957987498, 8.56944085583, 8.56948638674, 7.33917025619],
  [0.33, 8.58359138891, 8.58363862984, 8.58349937586, 8.58354638661, 7.35002511679],
  [0.34, 8.59767780692, 8.59772662203, 8.59758691313, 8.59763548368, 7.36097354001],
  [0.35, 8.61181579197, 8.61186627036, 8.61172588173, 8.61177610036, 7.37201942993],
  [0.36, 8.62602833032, 8.62608057058, 8.62593927017, 8.62599123458, 7.38316687737],
  [0.37, 8.64034169344, 8.64039582024, 8.64025332511, 8.64030715942, 7.39442017356],
  [0.38, 8.65478005237, 8.65483616707, 8.65469227479, 8.65474808076, 7.40578382507],
  [0.39, 8.66936426502, 8.66942247968, 8.66927697665, 8.66933486651, 7.41726257014],
  [0.4, 8.68411658718, 8.68417702663, 8.68402968382, 8.68408978254, 7.42886139648],
  [0.41, 8.69906095181, 8.6991237555, 8.69897432551, 8.69903677262, 7.44058556085],
  [0.42, 8.71422329327, 8.71428861752, 8.71413683104, 8.71420178288, 7.45244061056],
  [0.43, 8.72963193085, 8.72969995158, 8.72954551322, 8.72961314565, 7.46443240708],
  [0.44, 8.74531802755, 8.74538894353, 8.74523152681, 8.74530203849, 7.47656715213],
  [0.45, 8.76131614493, 8.76139018187, 8.76122942308, 8.76130303951, 7.48885141647],
  [0.46, 8.7776649218, 8.77774233731, 8.77757782806, 8.77765480658, 7.5012921718],
  [0.47, 8.79440791377, 8.79448900368, 8.79432028146, 8.79440091751, 7.51389682616],
  [0.48, 8.81159464417, 8.81167975042, 8.8115062869, 8.81159092191, 7.5266732633],
  [0.49, 8.82928193625, 8.82937145702, 8.829192643, 8.82928167451, 7.53962988656],
  [0.5, 8.84753562466, 8.84763002753, 8.84744515351, 8.84753904826, 7.55277566801],
  [0.51, 8.86645588298, 8.86655599107, 8.86636370597, 8.8664632838, 7.56612020342],
  [0.52, 8.88612124863, 8.88622711181, 8.88602759409, 8.88613290984, 7.57967377409],
  [0.53, 8.90646769662, 8.90657901877, 8.90637308038, 8.90648384078, 7.59344741662],
  [0.54, 8.92740051838, 8.92751683806, 8.92730554699, 8.92742129407, 7.60745300168],
  [0.55, 8.9488001351, 8.94892082558, 8.94870548766, 8.94882559871, 7.62170332345],
  [0.56, 8.97052518448, 8.97064946883, 8.97043158483, 8.97055528728, 7.63621220142],
  [0.57, 8.99241803447, 8.99254501618, 8.99232621578, 8.99245261764, 7.65099459662],
  [0.58, 9.01431230685, 9.01444101342, 9.01422297279, 9.01435110594, 7.66606674495],
  [0.59, 9.03604154816, 9.03617098255, 9.03595533568, 9.03608420714, 7.68144659586],
  [0.6, 9.05744791086, 9.05757710374, 9.05736535959, 9.05749400356, 7.69715423214],
  [0.61, 9.07838252123, 9.0785101671, 9.07830429937, 9.07843142132, 7.71320632538],
  [0.62, 9.09860623582, 9.09873149078, 9.09853266289, 9.09865740778, 7.72961993226],
  [0.63, 9.1182481715, 9.11837249295, 9.11817820439, 9.11830202625, 7.74641343548],
  [0.64, 9.13753877134, 9.13766345746, 9.13747156768, 9.13759576167, 7.76360668629],
  [0.65, 9.15668176214, 9.15680805676, 9.1566166042, 9.15674241132, 7.78122116669],
  [0.66, 9.17587018284, 9.17599936533, 9.17580642233, 9.17593511913, 7.79928017492],
  [0.67, 9.19530032855, 9.19543380642, 9.19523734068, 9.19537033162, 7.81780903816],
  [0.68, 9.21518631981, 9.21532574195, 9.21512345792, 9.21526238843, 7.83683535753],
  [0.69, 9.23577824588, 9.23592566182, 9.23571478756, 9.23586170285, 7.85638929139],
  [0.7, 9.25738828124, 9.25754639023, 9.25732335212, 9.2574809457, 7.87650388453],
  [0.71, 9.28084252, 9.28102175314, 9.2807723803, 9.28095103353, 7.89721545229],
  [0.72, 9.3072871385, 9.30749273532, 9.30721052784, 9.30741549111, 7.91856403123],
  [0.73, 9.33728292926, 9.33751992585, 9.33719893391, 9.33743523286, 7.94059391063],
  [0.74, 9.37144815172, 9.3717221122, 9.37135591405, 9.37162910188, 7.96335426292],
  [0.75, 9.41040975335, 9.41072611307, 9.41030870596, 9.41062420875, 7.98689989621],
  [0.76, 9.45467068697, 9.45503331936, 9.45456096493, 9.45492265238, 8.01129215839],
  [0.77, 9.50419714657, 9.50459871551, 9.50408221246, 9.50448280698, 8.03660003116],
  [0.78, 9.55761422344, 9.55805815083, 9.55749432446, 9.55793711952, 8.06290146431],
  [0.79, 9.61806311031, 9.61859325007, 9.61792828392, 9.61845695599, 8.09028501653],
  [0.8, 9.69405476962, 9.6947841466, 9.69388057867, 9.69460760627, 8.11885189177],
  [0.81, 9.79852311419, 9.79949702887, 9.79830476048, 9.79927587919, 8.14871849184],
  [0.82, 9.9255755958, 9.92666402264, 9.92534708996, 9.92643277518, 8.18001965147],
  [0.83, 10.0494606442, 10.0504106922, 10.0492744583, 10.050222368, 8.21291278784],
  [0.84, 10.1480446076, 10.1487640798, 10.1479135313, 10.1486313839, 8.24758329497],
  [0.85, 10.2253523199, 10.2259793137, 10.2252466846, 10.2258720096, 8.28425166179],
  [0.86, 10.2947958646, 10.2953772621, 10.2947055897, 10.295285382, 8.32318302273],
  [0.87, 10.3593286478, 10.3598825277, 10.35924978, 10.359802097, 8.36470021675],
  [0.88, 10.4207703308, 10.4213094821, 10.4207003376, 10.4212379513, 8.40920203142],
  [0.89, 10.4804547278, 10.4809893544, 10.4803918834, 10.480924983, 8.45718932877],
  [0.9, 10.5394778033, 10.540017092, 10.5394208754, 10.5399586338, 8.5093035479],
  [0.91, 10.5988527332, 10.5994060187, 10.5988008077, 10.5993525451, 8.56638539818],
  [0.92, 10.6596362949, 10.660214236, 10.6595886707, 10.660165029, 8.62956801877],
  [0.93, 10.7230701181, 10.7236862936, 10.7230262378, 10.7236407742, 8.70043229701],
  [0.94, 10.7907908206, 10.7914644484, 10.7907502188, 10.7914221205, 8.78128218618],
  [0.95, 10.8652176908, 10.8659789159, 10.8651799543, 10.8659393177, 8.87567270351],
  [0.96, 10.9500290814, 10.9509226391, 10.9499941468, 10.950885626, 8.9895349883],
  [0.97, 11.0511253194, 11.0522335933, 11.0510933705, 11.0521991893, 9.13396032232],
  [0.98, 11.181094963, 11.1826152279, 11.1810664427, 11.1825834923, 9.33390449564],
  [0.99, 11.3778567433, 11.3805294689, 11.3778329951, 11.3805002995, 9.67072439559]
];


  /*
   * x, erf(x), erfi(x)
   */
final List<double> expectedErf = [
  0.0,    0.0,               0.0,
  1e-05,  1.12837916706e-05, 1.12837916713e-05,
  0.0001, 0.000112837916333, 0.000112837917086,
  0.001,  0.00112837879097,  0.00112837954322,
  0.01,   0.0112834155558,   0.0112841678086,
  0.1,    0.112462916018,    0.11321517417,
  0.2,    0.22270258921,     0.228721299244,
  0.25,   0.276326390168,    0.288083619795,
  0.5,    0.520499877813,    0.614952094697,
  0.8,    0.742100964708,    1.13867078995,
  0.99,   0.838508069555,    1.62005691632,
  1.0, 0.84270079295, 1.6504257588,
  1.0001, 0.842742299549,    1.65073251473,
  2.2,    0.998137153702,    37.7471089806,
  3.4,    0.999998478007,    18276.5986163,
  4.3,    0.999999998807,    14478838.1348,
  5.0,    0.999999999998,    8298273880.68,
  6.0,    1.0,               4.11275145583e+14,
  7.0,    1.0,               1.55348625346e+20
];


