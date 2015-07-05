/*
 * Copyright 2007 Meteorological Service of New Zealand Limited all rights
 * reserved. No part of this work may be stored in a retrievable system,
 * transmitted  or reproduced in any way without the prior written
 * permission of the Meteorological Service of New Zealand
 */
package com.metservice.ice.core.catalog.timeseries.wxdatum.ampspdf;

import java.util.regex.Pattern;

import org.xml.sax.SAXException;

import com.metservice.ice.core.GuardException;
import com.metservice.ice.core.util.Text;
import com.metservice.ice.core.util.xml.SaxElementFactory;
import com.metservice.ice.core.util.xml.SaxHandler;
import com.metservice.ice.core.util.xml.XmlWriter;

/**
 * 
 * @author roach
 */
class ControlPointFactory extends SaxElementFactory
{
  public AmpsPdfControlPoint build() throws SAXException {
    if (controlPoint == null) throw new GuardException(this, "end");
    return controlPoint;
  }
  
  public static void write(XmlWriter xw, String qTag, AmpsPdfControlPoint o)
  {
    xw.open(qTag);
    if (o != null) {
      xw.addText(o.toString());
    }
    xw.close();
  }
  
  private static final Pattern SPLITTER = Pattern.compile(",");
  private static final String[] COORDS = {"x", "logny", "curvature"};
  
  //State
  private AmpsPdfControlPoint controlPoint;
  
  public ControlPointFactory(String uri, String localName, String qualifiedName) {
    super(uri, localName, qualifiedName);
  }
  
  //SaxElement
  protected SaxElementFactory newChild(SaxHandler handler, String childUri, String childLocalName, String childQualifiedName) throws SAXException {
    throw new SAXException(unexpectedChild(handler, childUri, childLocalName, childQualifiedName));
  }
  
  protected void setAttribute(SaxHandler handler, String attributeUri, String attributeLocalName, String attributeQualifiedName, String qText) throws SAXException
  {}

  protected String oqrwText(SaxHandler handler, String qText) throws SAXException {
    return Text.oqrwTrimCompressEmbeddedFlatten(qText);
  }
  
  protected void end(SaxHandler handler) throws SAXException
  {
    final String qrwText = selectOnlyTextChild(handler).qrwText();
    final String[] xptzValues = SPLITTER.split(qrwText);
    final int len = xptzValues.length;
    if (len < 2 || len > COORDS.length) {
      throw new SAXException("Control point '"+qrwText+"' in '" + handler.localNamePath() + "' has too many coordinates.");
    }
    final double[] xptCoords = new double[len];
    for (int i=0; i < len; i++)
    {
      final String cname = COORDS[i];
      final String ztwValue = xptzValues[i].trim();
      if (ztwValue.length() == 0) {
        throw new SAXException("Coordinate "+cname+" of control point '"+qrwText+"' in '" + handler.localNamePath() + "' is empty.");
      }
      try {
        xptCoords[i] = Double.parseDouble(ztwValue);
      }
      catch (NumberFormatException exNF) {
        throw new SAXException("Coordinate "+cname+" of control point '"+qrwText+"' in '" + handler.localNamePath() + "' is malformed.");
      }
    }
    if (len == 3) {
      controlPoint = new AmpsPdfControlPoint(xptCoords[0], xptCoords[1], xptCoords[2]);
    }
    else {
      controlPoint = new AmpsPdfControlPoint(xptCoords[0], xptCoords[1]);
    }
  }
}

