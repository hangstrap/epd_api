/*
 * Copyright 2007 Meteorological Service of New Zealand Limited all rights
 * reserved. No part of this work may be stored in a retrievable system,
 * transmitted  or reproduced in any way without the prior written
 * permission of the Meteorological Service of New Zealand
 */
package com.metservice.ice.core.catalog.timeseries.wxdatum.ampspdf;

import com.metservice.ice.core.GuardException;

/**
 * 
 * @author roach
 */
public class AmpsPdfControlPoint
{
  public final double x() {
    return m_x;
  }
  
  public final double logny() {
    return m_logny;
  }
  
  public final double curvature() {
    if (!hasCurvature()) throw new GuardException(this, "hasCurvature");
    return m_curvature;
  }
  
  public final boolean hasCurvature() {
    return !Double.isNaN(m_curvature);
  }
  
  private final double m_x;
  private final double m_logny;
  private final double m_curvature;
  public AmpsPdfControlPoint(double x, double logny, double curvature)
  {
    m_x = x;
    m_logny = logny;
    m_curvature = curvature;
  }
  
  public AmpsPdfControlPoint(double x, double logny)
  {
    m_x = x;
    m_logny = logny;
    m_curvature = Double.NaN;
  }
  
  public String toString() {
    final StringBuffer b = new StringBuffer();
    b.append(m_x);
    b.append(',');
    b.append(m_logny);
    if (!Double.isNaN(m_curvature)) {
      b.append(',');
      b.append(m_curvature);
    }
    return b.toString();
  }
}

