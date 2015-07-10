library probability_desity_function;

import "dart:math";
import "erf.dart";
import "maths_const.dart";

class ProbabilityDensityFunction {


  static final int NoSegment = -1;
  static final int BISECTION_ITERATION_LIMIT = 32;

  List<double> m_x;
  List<double> m_y;
  List<double> m_c;
  int m_k;
  bool m_tailL;
  bool m_tailR;

  Map<int, double> m_a = {};
  Map<int, double> m_b = {};

  static ProbabilityDensityFunction createFromMap( Map datum){
      List<double> controlPoints =datum['control-points'];
      List<double> longPdfValues = datum['logn-pdf-values'];
      List<double> curvatureValues = datum['curvature-values'];
      bool tailLeft  =  datum['tail-left']==1?true:false;
      bool tailRight = datum["tail-right"]==1?true:false;
      return new ProbabilityDensityFunction( controlPoints, longPdfValues, curvatureValues, tailLeft, tailRight);
  }

  ProbabilityDensityFunction(List<double> x, List<double> logny, List<double> c,
                             bool tailL, bool tailR) {
    if (x == null) throw new Exception("x is null");
    if (logny == null) throw new Exception("logny is null");
    if (c == null) throw new Exception("c is null");

    if (x.length != logny.length) throw new Exception("x,y length mismatch");
    if (x.length != c.length + 1) throw new Exception("x,c length mismatch");
    if (c.length == 0) throw new Exception("no segments");

    m_x = x;
    m_y = logny;
    m_c = c;
    m_k = c.length;
    m_tailL = tailL;
    m_tailR = tailR;
    for (num i = 0; i < m_k; i++) {
      final double ai = (m_y[i + 1] + m_y[i]) / 2.0;
      final double bi = m_y[i + 1] - ai;
      m_a[i] = ai;
      m_b[i] = bi;
    }
  }

  ///probability density at X
  double pdf(double x) {
    final int i = _segment(x);
    if (i == NoSegment) {
      return 0.0;
    }
    double z = _z(i, x);
    return exp(m_a[i] + (m_b[i] * z) + (m_c[i] * (1 + z) * (1 - z)));
  }
  ///Cumulative distribution at X
  ///probability outcome will be less than z
  double cdf(double x) {
    int j = _segment(x);
    if (j == NoSegment) {
      return (x <= m_x[0]) ? 0.0 : 1.0;
    }
    double z = _z(j, x);
    if (j == 0 && m_tailL) {
      return (_cdfI_zi(z, j) - _cdfI_zi(double.NEGATIVE_INFINITY, j)) *
          _xd(j) /
          2.0;
    }
    double r = 0.0;
    for (int i = 0; i < j; i++) {
      r += _cdfA(i) * _xd(i) / 2.0;
    }
    r += (_cdfI_zi(z, j) - _cdfI_zi(-1.0, j)) * _xd(j) / 2.0;
    return r;
  }
  ///Inverse cumulative distribution
  ///gives level such that the probability of outcome less than level is x
  ///X must be between 0 and 1
  double cdfInverse(double probability) {
    if (probability < 0 || probability > 1) {
      throw "probality must be between 0 and 1, value was ${probability}";
    }
    double lhs = -1.0;
    double rhs = 1.0;
    while (cdf(lhs) > probability) {
      rhs = lhs;
      lhs = lhs * 2.0;
    }
    while (cdf(rhs) < probability) {
      rhs = rhs * 2.0;
    }

    double m = (lhs + rhs) / 2.0;
    double cm = cdf(m);
    int i = 1;
    while (i <= BISECTION_ITERATION_LIMIT) {
      if (cm < probability) {
        lhs = m;
      } else {
        rhs = m;
      }
      m = (lhs + rhs) / 2.0;
      cm = cdf(m);
      i++;
    }
    return m;
  }

  double _cdfA(int i) {
    double lhs = -1.0;
    double rhs = 1.0;
    if (i == 0 && m_tailL) {
      lhs = double.NEGATIVE_INFINITY;
    }
    if (i == (m_k - 1) && m_tailR) {
      rhs = double.INFINITY;
    }

    return _cdfI_zi(rhs, i) - _cdfI_zi(lhs, i);
  }

  double _cdfI_zi(double z, int i) {
    return _cdfI(z, m_a[i], m_b[i], m_c[i]);
  }

  double _cdfI(double z, double a, double b, double c) {
    if (c == 0.0) {
      if (b == 0) {
        return exp(a) * z;
      }
      if (_isPositiveInfinity(z) && b < 0) {
        return 0.0;
      }
      if (_isNegativeInfinity(z) && b > 0) {
        return 0.0;
      }
      return exp(a + (b * z)) / b;
    }

    final double bsq = b * b;
    final double e = exp((bsq / 4.0 / c) + a + c) * sqrt(PI);
    if (c > 0.0) {
      if (_isPositiveInfinity(z)) {
        return e / 2.0 / sqrt(c);
      }
      if (_isNegativeInfinity(z)) {
        return -e / 2.0 / sqrt(c);
      }
      final double z1 = ((2 * c * z) - b) / 2.0 / sqrt(c);
      return e * erf(z1) / 2.0 / sqrt(c);
    } else {
      final double z1 = (b - (2 * c * z)) / 2.0 / sqrt(-c);
      return e * erfi(z1) / 2.0 / sqrt(-c);
    }
  }

  static bool _isPositiveInfinity(double z) {
    return z.isInfinite && z > 0.0;
  }

  static bool _isNegativeInfinity(double z) {
    return z.isInfinite && z < 0.0;
  }

  double _xd(int i) {
    return m_x[i + 1] - m_x[i];
  }

  double _z(int i, double x) {
    return (2.0 * x - m_x[i + 1] - m_x[i]) / (m_x[i + 1] - m_x[i]);
  }

  int _segment(double x) {
    if (x <= m_x[0]) {
      return m_tailL ? 0 : NoSegment;
    }

    if (x > indexed(m_x, -1)) {
      return m_tailR ? (m_k - 1) : NoSegment;
    }

    for (int i = 0; i < m_k; i++) {
      if (x <= m_x[i + 1]) {
        if (m_x[i] < x) {
          return i;
        }
        throw new Exception("x array is unordered (detected at ${i})");
      }
    }
    throw new Exception("x array is unordered (detected at end)");
  }
}
