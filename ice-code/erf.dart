library erf;

import "dart:math";
import "dawson.dart";
import "chebyshev_series.dart";
/**
 * Error function
 * Implemented using complementary error function in general, and Abramowitz+Stegun for small x
 * @param x
 * @return erf(x) := 2/Sqrt[Pi] Integrate[Exp[-t^2], {t,0,x}]
 */

double erf(double x) {
  if (x.abs() < 1.0) {
    return erfseries(x);
  } else {
    return 1.0 - erfc(x);
  }
}

/**
 * Complementary error function
 * Implemented using Chebyshev series
 * @param x
 * @return erfc(x) := 1 - erf(x)
 */
double erfc(double x) {
  double ax = x.abs();
  double e;
  if (ax <= 1.0) {
    double t = 2.0 * ax - 1.0;
    double c = cs_erfc_xlt1.cheb_eval(t);
    e = c;
  } else if (ax <= 5.0) {
    double ex2 = exp(-x * x);
    double t = 0.5 * (ax - 3.0);
    double c = cs_erfc_x15.cheb_eval(t);
    e = ex2 * c;
  } else if (ax < 10.0) {
    double exterm = exp(-x * x) / ax;
    double t = (2.0 * ax - 15.0) / 5.0;
    double c = cs_erfc_x510.cheb_eval(t);
    e = exterm * c;
  } else {
    e = erfc8(ax);
  }

  return (x < 0.0) ? 2.0 - e : e;
}

/**
 * Imaginary error function
 * Implemented using Dawson's integral as follows:
 * erfi(x) := 2*Exp[x^2]*D(x)/Sqrt[Pi]
 * @param x
 * @return erfi(x) := -i erf(ix)
 * @throws MathException
 */
double erfi(final double x) {
  return dawson(x) * exp(x * x) * 2 / sqrt(PI);
}

/**
 * Abramowitz+Stegun, 7.1.5
 */
double erfseries(double x) {
  double coef = x;
  double e = coef;
  double del = 0.0;
  for (int k = 1; k < 30; ++k) {
    coef *= -x * x / k;
    del = coef / (2.0 * k + 1.0);
    e += del;
  }
  return 2.0 / sqrt(PI) * e;
}

double erfc8(double x) {
  double e = erfc8_sum(x);
  e *= exp(-x * x);
  return e;
}

/**
 * Estimates erfc(x) valid for 8 < x < 100
 * This is based on index 5725 in Hart et al
 */
double erfc8_sum(double x) {
  final List<double> P = erfc8_sum_P;
  final List<double> Q = erfc8_sum_Q;

  double num = 0.0;
  double den = 0.0;

  num = P[5];
  for (int i = 4; i >= 0; --i) {
    num = x * num + P[i];
  }
  den = Q[6];
  for (int i = 5; i >= 0; --i) {
    den = x * den + Q[i];
  }

  return num / den;
}

final List<double> erfc8_sum_P = [
  2.97886562639399288862,
  7.409740605964741794425,
  6.1602098531096305440906,
  5.019049726784267463450058,
  1.275366644729965952479585264,
  0.5641895835477550741253201704
];

final List<double> erfc8_sum_Q = [
  3.3690752069827527677,
  9.608965327192787870698,
  17.08144074746600431571095,
  12.0489519278551290360340491,
  9.396034016235054150430579648,
  2.260528520767326969591866945,
  1.0
];

/**
 * Chebyshev fit for erfc((t+1)/2), -1 < t < 1
 */
final List<double> erfc_xlt1_data = [
  1.06073416421769980345174155056,
  -0.42582445804381043569204735291,
  0.04955262679620434040357683080,
  0.00449293488768382749558001242,
  -0.00129194104658496953494224761,
  -0.00001836389292149396270416979,
  0.00002211114704099526291538556,
  -5.23337485234257134673693179020e-7,
  -2.78184788833537885382530989578e-7,
  1.41158092748813114560316684249e-8,
  2.72571296330561699984539141865e-9,
  -2.06343904872070629406401492476e-10,
  -2.14273991996785367924201401812e-11,
  2.22990255539358204580285098119e-12,
  1.36250074650698280575807934155e-13,
  -1.95144010922293091898995913038e-14,
  -6.85627169231704599442806370690e-16,
  1.44506492869699938239521607493e-16,
  2.45935306460536488037576200030e-18,
  -9.29599561220523396007359328540e-19
];
final ChebyshevSeries cs_erfc_xlt1 =
new ChebyshevSeries(erfc_xlt1_data, 19, -1.0, 1.0, 12);

/**
 * Chebyshev fit for erfc(x) exp(x^2), 1 < x < 5, x = 2t + 3, -1 < t < 1
 */
final List<double> erfc_x15_data = [
  0.44045832024338111077637466616,
  -0.143958836762168335790826895326,
  0.044786499817939267247056666937,
  -0.013343124200271211203618353102,
  0.003824682739750469767692372556,
  -0.001058699227195126547306482530,
  0.000283859419210073742736310108,
  -0.000073906170662206760483959432,
  0.000018725312521489179015872934,
  -4.62530981164919445131297264430e-6,
  1.11558657244432857487884006422e-6,
  -2.63098662650834130067808832725e-7,
  6.07462122724551777372119408710e-8,
  -1.37460865539865444777251011793e-8,
  3.05157051905475145520096717210e-9,
  -6.65174789720310713757307724790e-10,
  1.42483346273207784489792999706e-10,
  -3.00141127395323902092018744545e-11,
  6.22171792645348091472914001250e-12,
  -1.26994639225668496876152836555e-12,
  2.55385883033257575402681845385e-13,
  -5.06258237507038698392265499770e-14,
  9.89705409478327321641264227110e-15,
  -1.90685978789192181051961024995e-15,
  3.50826648032737849245113757340e-16
];

final ChebyshevSeries cs_erfc_x15 =
new ChebyshevSeries(erfc_x15_data, 24, -1.0, 1.0, 16);

/*
   * Chebyshev fit for erfc(x) x exp(x^2), 5 < x < 10, x = (5t + 15)/2, -1 < t < 1
   */
final List<double> erfc_x510_data = [
  1.11684990123545698684297865808,
  0.003736240359381998520654927536,
  -0.000916623948045470238763619870,
  0.000199094325044940833965078819,
  -0.000040276384918650072591781859,
  7.76515264697061049477127605790e-6,
  -1.44464794206689070402099225301e-6,
  2.61311930343463958393485241947e-7,
  -4.61833026634844152345304095560e-8,
  8.00253111512943601598732144340e-9,
  -1.36291114862793031395712122089e-9,
  2.28570483090160869607683087722e-10,
  -3.78022521563251805044056974560e-11,
  6.17253683874528285729910462130e-12,
  -9.96019290955316888445830597430e-13,
  1.58953143706980770269506726000e-13,
  -2.51045971047162509999527428316e-14,
  3.92607828989125810013581287560e-15,
  -6.07970619384160374392535453420e-16,
  9.12600607264794717315507477670e-17
];

final ChebyshevSeries cs_erfc_x510 =
new ChebyshevSeries(erfc_x510_data, 19, -1.0, 1.0, 12);
