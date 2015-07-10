library chebyshev_series;

/**
 * data for a Chebyshev series over a given interval
 */
class ChebyshevSeries {


  /**
   * coefficients
   */
  final List<double> c;

  /**
   * order of expansion
   */
  final int order;

  /**
   * lower interval point
   */
  final double a;

  /**
   * upper interval point
   */
  final double b;

  /**
   * effective single precision order
   */
  final int order_sp;

  ChebyshevSeries(this.c, this.order, this.a, this.b, this.order_sp);

  double cheb_eval(final double x) {
    double d = 0.0;
    double dd = 0.0;

    double y = (2.0 * x - a - b) / (b - a);
    double y2 = 2.0 * y;

    for (int j = order; j >= 1; j--) {
      final double temp = d;
      d = y2 * d - dd + c[j];
      dd = temp;
    }

    d = y * d - dd + 0.5 * c[0];

    return d;
  }
}

