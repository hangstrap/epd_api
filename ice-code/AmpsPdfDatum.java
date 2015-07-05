/*
 * Copyright 2007 Meteorological Service of New Zealand Limited all rights
 * reserved. No part of this work may be stored in a retrievable system,
 * transmitted  or reproduced in any way without the prior written
 * permission of the Meteorological Service of New Zealand
 */
package com.metservice.ice.core.catalog.timeseries.wxdatum.ampspdf;

import com.metservice.ice.core.catalog.timeseries.wxdatum.CompactXmlTimeseriesDatum;
import com.metservice.ice.core.catalog.tuple.TimeseriesDatum;
import com.metservice.ice.core.math.ProbabilityDensityFunction;
import com.metservice.ice.core.util.xml.XmlWriter;
import com.metservice.ice.core.wx.qty.QuantityUnit;

/**
 * 
 * @author roach
 */
public class AmpsPdfDatum extends CompactXmlTimeseriesDatum
{
  public ProbabilityDensityFunction newComputeEngine()
  {
    final int n = xptControlPoints.length;
    final int k = n - 1;
    final double[] xArray = new double[n];
    final double[] lognyArray = new double[n];
    final double[] cArray = new double[k];
    for (int i=0; i < n; i++) {
      final AmpsPdfControlPoint controlPoint = xptControlPoints[i];
      xArray[i] = controlPoint.x();
      lognyArray[i] = controlPoint.logny();
    }
    for (int i=0; i < k; i++) {
      final AmpsPdfControlPoint controlPoint = xptControlPoints[i];
      cArray[i] = controlPoint.curvature();
    }
    return new ProbabilityDensityFunction(xArray, lognyArray, cArray, tailLeft, tailRight);
  }
  
  public final QuantityUnit unit;
  public final AmpsPdfControlPoint[] xptControlPoints;
  public final boolean tailLeft;
  public final boolean tailRight;
  public final double mean;
  public final double variance;
  
  public AmpsPdfDatum(
    QuantityUnit unit,
    double[] xptControlPointXs,
    double[] xptControlPointLognYs,
    double[] xptControlPointCurvatures,
    boolean tailLeft,
    boolean tailRight,
    double mean,
    double variance
    )
  {
    if (unit == null) throw new IllegalArgumentException("unit is null");
    if (xptControlPointXs == null) throw new IllegalArgumentException("xptControlPointXs is null");
    if (xptControlPointLognYs == null) throw new IllegalArgumentException("xptControlPointLognYs is null");
    if (xptControlPointCurvatures == null) throw new IllegalArgumentException("xptControlPointCurvatures is null");
    
    final int nX = xptControlPointXs.length;
    final int nY = xptControlPointLognYs.length;
    final int nC = xptControlPointCurvatures.length;
    if (nX < 2 || nX != nY || (nC + 1) != nX) throw new IllegalArgumentException("Invalid control point arrays: nX="+nX+" nY="+nY+" nC="+nC);
    
    xptControlPoints = new AmpsPdfControlPoint[nX];
    for (int i=0; i < nC; i++) {
      xptControlPoints[i] = new AmpsPdfControlPoint(xptControlPointXs[i], xptControlPointLognYs[i], xptControlPointCurvatures[i]);
    }
    xptControlPoints[nC] = new AmpsPdfControlPoint(xptControlPointXs[nC], xptControlPointLognYs[nC]);
    
    this.unit = unit;
    this.tailLeft = tailLeft;
    this.tailRight = tailRight;
    this.mean = mean;
    this.variance = variance;
  }
  
  public AmpsPdfDatum(QuantityUnit unit, AmpsPdfControlPoint[] xptControlPoints, boolean tailLeft, boolean tailRight, double mean, double variance)
  {
    if (unit == null) throw new IllegalArgumentException("unit is null");
    if (xptControlPoints == null || xptControlPoints.length == 1) throw new IllegalArgumentException("xptControlPoints is empty");
    this.unit = unit;
    this.xptControlPoints = xptControlPoints;
    this.tailLeft = tailLeft;
    this.tailRight = tailRight;
    this.mean = mean;
    this.variance = variance;
  }
  
  @Override
  protected void write(XmlWriter xw) {
    AmpsPdfFactory.write(xw, this);
  }
  
  @Override
  public boolean isReportedMissing() {
    return false;
  }

  @Override
  public boolean same(TimeseriesDatum baseline)
  {
    if (baseline instanceof AmpsPdfDatum) {
      final AmpsPdfDatum b = (AmpsPdfDatum)baseline;
      return qXmlContent().equals(b.qXmlContent());
    }
    return false;
  }
  
  //Canonical
  public String toString() {
    return "m"+mean + unit.name();
  }
}

