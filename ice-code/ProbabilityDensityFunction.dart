import "dart:math";

class ProbabilityDensityFunction
{
  double pdf(double x)
  {
    final int i = segment(x);
    if (i == NoSegment) {
      return 0.0;
    }
    final double z = z(i, x);
    return exp(m_a[i] + (m_b[i]*z) + (m_c[i] * (1+z) * (1-z)));
  }
  
  
  double cdf(double x)
  {
    final int j = segment(x);
    if (j == NoSegment) {
      return (x <= m_x[0]) ? 0.0 : 1.0;
    }
    final double z = z(j, x);
    if (j==0 && m_tailL) {
      return (cdfI_zi(z, j) - cdfI_zi(double.NEGATIVE_INFINITY, j)) * xd(j) / 2.0;
    }
    double r = 0.0;
    for (int i=0; i < j; i++) {
      r += cdfA(i) * xd(i) / 2.0;
    }
    r += (cdfI_zi(z,j) - cdfI_zi(-1,j)) * xd(j) / 2.0;
    return r;
  }
  
  double cdfInverse(double x)
  {
    double lhs = -1.0;
    double rhs = 1.0;
    while (cdf(lhs) > x) {
      rhs= lhs;
      lhs= lhs * 2.0;
    }
    while (cdf(rhs) < x) {
      rhs=rhs * 2.0;
    }
    
    double m = (lhs+rhs) / 2.0;
    double cm = cdf(m);
    int i = 1;
    while (i <= BISECTION_ITERATION_LIMIT)
    {
      if ( cm < x) {
        lhs=m;
      }
      else {
        rhs=m;
      }
      m = (lhs + rhs) / 2.0;
      cm = cdf(m);
      i++;
    }
    return m;
  }
  
  
   static final int NoSegment = -1;
   static final int BISECTION_ITERATION_LIMIT = 32;
  
   List<double> m_x;
  List<double> m_y;
  List<double> m_c;
   final int m_k;
   final boolean m_tailL;
   final boolean m_tailR;

  List<double> m_a;
  List<double> m_b;
  
  ProbabilityDensityFunction(List<double> x, List<double> logny, List<double> c, boolean tailL, boolean tailR)
  {
    if (x == null) throw new IllegalArgumentException("x is null");
    if (logny == null) throw new IllegalArgumentException("logny is null");
    if (c == null) throw new IllegalArgumentException("c is null");
    
    if (x.length != logny.length) throw new IllegalArgumentException("x,y length mismatch");
    if (x.length != c.length + 1) throw new IllegalArgumentException("x,c length mismatch");
    if (c.length == 0) throw new IllegalArgumentException("no segments");
    
    m_x = x;
    m_y = logny;
    m_c = c;
    m_k = c.length;
    m_tailL = tailL;
    m_tailR = tailR;
    for (int i=0; i < m_k; i++)
    {
      final double ai = (m_y[i+1] + m_y[i]) / 2.0; 
      final double bi = m_y[i+1] - ai; 
      m_a[i] = ai;
      m_b[i] = bi;
    }
  }
  
   double cdfA(int i)
  {
    double lhs = -1.0;
    double rhs =  1.0;
    if (i == 0 && m_tailL) {
      lhs = double.NEGATIVE_INFINITY;
    }
    if (i == (m_k-1) && m_tailR) {
      rhs = double.INFINITY;
    }
    
    return cdfI_zi(rhs, i) - cdfI_zi(lhs, i);
  }
  
   double cdfI_zi(double z, int i) {
    return cdfI(z, m_a[i], m_b[i], m_c[i]);
  }
  
   double cdfI(double z, double a, double b, double c)
  {
    if (c == 0.0)
    {
      if (b==0) {
        return exp(a) * z;
      }
      if (isPositiveInfinity(z) && b < 0) {
        return 0.0;
      }
      if (isNegativeInfinity(z) && b > 0) {
        return 0.0;
      }
      return exp(a + (b * z)) / b;
    }
    
    final double bsq = b * b;
    final double e = exp( (bsq / 4.0 / c) + a + c) * sqrt( PI);
    if (c > 0.0)
    {
      if (isPositiveInfinity(z)) {
          return e / 2.0 / sqrt(c);
      }
      if (isNegativeInfinity(z)) {
          return -e / 2.0 / sqrt(c);
      }
      final double z1 = ( (2 * c * z) - b) / 2.0 / sqrt(c);
      return e * Erf.erf(z1) / 2.0 / sqrt(c);
    }
    else
    {
      final double z1 = (b - (2 * c * z)) / 2.0 / sqrt(-c);
      return e * Erf.erfi(z1) / 2.0 / sqrt(-c);
    }
  }
  
   static bool isPositiveInfinity(double z) {
    return z.isInfinite && z > 0.0;
  }
  
   static bool isNegativeInfinity(double z) {
    return z.isInfinite && z < 0.0;
  }
  
   double xd(int i) {
    return m_x[i+1] - m_x[i];
  }
  
   double z(int i, double x) {
    return (2.0 * x - m_x[i+1] - m_x[i]) / (m_x[i+1]-m_x[i]);
  }
  
   int segment(double x) {
    if (x <= m_x[0]) {
      return m_tailL ? 0 : NoSegment;
    }
    
    if (x > indexed(m_x, -1)) {
      return m_tailR ? (m_k-1) : NoSegment;
    }
    
    for (int i=0; i < m_k; i++)
    {
      if (x <= m_x[i+1])
      {
        if (m_x[i] < x) {
          return i;
        }
        throw new Exception("x array is unordered (detected at "+i+")");
      }
    }
    throw new Exception("x array is unordered (detected at end)");
  }
  
}

