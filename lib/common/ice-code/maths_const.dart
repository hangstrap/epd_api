library maths_const;
/**
 * e
 */
final double M_E = 2.71828182845904523536028747135;

/**
 * log 2 (e)
 */

final double M_LOG2E = 1.44269504088896340735992468100;

/**
 *  log_10 (e)
 */
final double M_LOG10E = 0.43429448190325182765112891892;

/**
 * sqrt(2)
 */
final double M_SQRT2 = 1.41421356237309504880168872421;

/**
 * sqrt(1/2)
 */
final double M_SQRT1_2 = 0.70710678118654752440084436210;

/**
 * sqrt(3)
 */
final double M_SQRT3 = 1.73205080756887729352744634151;

/**
 * pi
 */
final double M_PI = 3.14159265358979323846264338328;

/**
 * pi/2
 */
final double M_PI_2 = 1.57079632679489661923132169164;

/**
 * pi/4
 */
final double M_PI_4 = 0.78539816339744830961566084582;

/**
 * sqrt(pi)
 */
final double M_SQRTPI = 1.77245385090551602729816748334;

/**
 * 2/sqrt(pi)
 */
final double M_2_SQRTPI = 1.12837916709551257389615890312;

/**
 * 1/pi
 */
final double M_1_PI = 0.31830988618379067153776752675;

/**
 * 2/pi
 */
final double M_2_PI = 0.63661977236758134307553505349;

/**
 * ln(10)
 */
final double M_LN10 = 2.30258509299404568401799145468;

/**
 * ln(2)
 */
final double M_LN2 = 0.69314718055994530941723212146;

/**
 * ln(pi)
 */
final double M_LNPI = 1.14472988584940017414342735135;

/**
 * Euler constant
 */
final double M_EULER = 0.57721566490153286060651209008;

//GSL Compatibility
final double GSL_DBL_EPSILON = 2.2204460492503131e-16;
final double GSL_SQRT_DBL_EPSILON = 1.4901161193847656e-08;
final double GSL_LOG_DBL_EPSILON = -3.6043653389117154e+01;

final double GSL_DBL_MIN = 2.2250738585072014e-308;
final double GSL_SQRT_DBL_MIN = 1.4916681462400413e-154;
final double GSL_LOG_DBL_MIN = -7.0839641853226408e+02;

final double GSL_DBL_MAX = 1.7976931348623157e+308;
final double GSL_SQRT_DBL_MAX = 1.3407807929942596e+154;
final double GSL_LOG_DBL_MAX = 7.0978271289338397e+02;

//Array Utilities
double indexed(List<double> a, int index) {
  return index < 0 ? a[a.length + index] : a[index];
}
