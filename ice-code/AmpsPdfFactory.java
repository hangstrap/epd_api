/*
 * Copyright 2007 Meteorological Service of New Zealand Limited all rights
 * reserved. No part of this work may be stored in a retrievable system,
 * transmitted  or reproduced in any way without the prior written
 * permission of the Meteorological Service of New Zealand
 */

package com.metservice.ice.core.catalog.timeseries.wxdatum.ampspdf;

import java.util.ArrayList;
import java.util.List;

import org.xml.sax.SAXException;

import com.metservice.ice.core.GuardException;
import com.metservice.ice.core.util.xml.SaxElementFactory;
import com.metservice.ice.core.util.xml.SaxHandler;
import com.metservice.ice.core.util.xml.SaxRestriction;
import com.metservice.ice.core.util.xml.XmlWriter;
import com.metservice.ice.core.wx.qty.QuantityUnit;

/**
 * creates an AmpsPdf instance from a XML document that is typically stored in the database Document
 * allegedly looks like
 * 
 * <pre>
 *  <?xml version="1.0" encoding="US-ASCII"?>
 *  <ampspdf xmlns="http://www.metservice.com/ns/amps/2007/pdf" unit="C" 
 *  tailLeft="true" tailRight="true" 
 *  mean="6.925692" variance="0.579676" 
 *  cpformat="x,logny,curve">
 * 
 *  <cp>4.005136,-6.089006,0.304273</cp>
 *  <cp>6.338313,-0.973548,0.092982</cp>
 *  <cp>6.938137,-0.552154,-1.0E-6</cp>
 *  <cp>6.972854,-0.5517,2.0E-6</cp>
 *  <cp>7.007608,-0.55428,-7.0E-6</cp>
 *  <cp>7.042494,-0.559269,-1.6E-5</cp>
 *  <cp>7.077618,-0.567849,-2.6E-5</cp>
 *  <cp>7.113091,-0.578993,-5.0E-5</cp>
 *  <cp>7.149008,-0.592773,-8.7E-5</cp>
 *  <cp>7.18552,-0.611841,-1.07E-4</cp>
 *  <cp>7.22277,-0.632707,-1.52E-4</cp>
 *  <cp>7.26088,-0.657507,-2.14E-4</cp>
 *  <cp>7.300039,-0.686904,-3.1E-4</cp>
 *  <cp>7.340488,-0.72225,-3.84E-4</cp>
 *  <cp>7.382478,-0.76157,0.593096</cp>
 *  <cp>9.569915,-6.051848</cp>
 * 
 *  </ampspdf>
 * </pre>
 * 
 * 
 * @author roach
 */
public class AmpsPdfFactory extends SaxElementFactory {
    // Public Constants
    public static final String URI = "http://www.metservice.com/ns/amps/2007/pdf";
    public static final String ROOT = "ampspdf";

    // Public Constants
    public static final String ATT_UNIT = "unit";
    public static final String ATT_TAIL_LEFT = "tailLeft";
    public static final String ATT_TAIL_RIGHT = "tailRight";
    public static final String ATT_MEAN = "mean";
    public static final String ATT_VARIANCE = "variance";
    public static final String ATT_CPFORMAT = "cpformat";

    public static final String TAG_CONTROL_POINT = "cp";

    public static final String FIXED_CPFORMAT = "x,logny,curve";

    public static boolean matches( String rootUri, String rootLocalName ) {
        if ( rootUri == null )
            throw new IllegalArgumentException("rootUri is null");
        if ( rootLocalName == null )
            throw new IllegalArgumentException("rootLocalName is null");
        return rootUri.equals(URI) && rootLocalName.equals(ROOT);
    }

    public AmpsPdfDatum build()
            throws SAXException {
        if ( unit == null )
            throw new GuardException(this, "end");
        if ( tailLeft == null )
            throw new GuardException(this, "end");
        if ( tailRight == null )
            throw new GuardException(this, "end");
        if ( mean == null )
            throw new GuardException(this, "end");
        if ( variance == null )
            throw new GuardException(this, "end");
        if ( xlControlPoints.isEmpty() )
            throw new GuardException(this, "end");

        final int cpcount = xlControlPoints.size();
        final int ilast = cpcount - 1;
        final AmpsPdfControlPoint[] xptControlPoints = new AmpsPdfControlPoint[cpcount];
        for ( int i = 0; i < cpcount; i++ ) {
            final AmpsPdfControlPoint cp = xlControlPoints.get(i).build();
            if ( i < ilast ) {
                if ( !cp.hasCurvature() ) {
                    throw new SAXException("Control point " + i + " (" + cp + ") should have curvature");
                }
            } else {
                if ( cp.hasCurvature() ) {
                    throw new SAXException("Last control point " + i + " (" + cp + ") should not have curvature");
                }
            }

            xptControlPoints[i] = cp;
        }
        return new AmpsPdfDatum(unit, xptControlPoints, tailLeft.booleanValue(), tailRight.booleanValue(), mean.doubleValue(), variance.doubleValue());
    }

    public static void write( XmlWriter xw, AmpsPdfDatum o ) {
        xw.setNamespaceURI(URI);
        write(xw, ROOT, o);
    }

    public static void write( XmlWriter xw, String qTag, AmpsPdfDatum o ) {
        xw.open(qTag);
        if ( o != null ) {
            xw.addAttribute(ATT_UNIT, o.unit);
            xw.addAttribute(ATT_TAIL_LEFT, o.tailLeft);
            xw.addAttribute(ATT_TAIL_RIGHT, o.tailRight);
            xw.addAttribute(ATT_MEAN, o.mean);
            xw.addAttribute(ATT_VARIANCE, o.variance);
            xw.addAttribute(ATT_CPFORMAT, FIXED_CPFORMAT);
            for ( int i = 0; i < o.xptControlPoints.length; i++ ) {
                ControlPointFactory.write(xw, TAG_CONTROL_POINT, o.xptControlPoints[i]);
            }
        }
        xw.close();
    }

    // State
    private QuantityUnit unit;
    private Boolean tailLeft;
    private Boolean tailRight;
    private Double mean;
    private Double variance;
    private String cpFormat;
    private List<ControlPointFactory> xlControlPoints = new ArrayList<ControlPointFactory>(16);

    public AmpsPdfFactory( String uri, String localName, String qualifiedName ) {
        super(uri, localName, qualifiedName);
    }

    // SaxElement
    protected SaxElementFactory newChild( SaxHandler handler, String childUri, String childLocalName, String childQualifiedName )
            throws SAXException {
        if ( childLocalName.equals(TAG_CONTROL_POINT) )
            return new ControlPointFactory(childUri, childLocalName, childQualifiedName);
        throw new SAXException(unexpectedChild(handler, childUri, childLocalName, childQualifiedName));
    }

    protected void setAttribute( SaxHandler handler, String attributeUri, String attributeLocalName, String attributeQualifiedName, String qText )
            throws SAXException {
        if ( attributeLocalName.equals(ATT_UNIT) ) {
            unit = (QuantityUnit)SaxRestriction.attribute(handler, attributeLocalName, qText).name(QuantityUnit.Table);
            return;
        }

        if ( attributeLocalName.equals(ATT_TAIL_LEFT) ) {
            tailLeft = SaxRestriction.attribute(handler, attributeLocalName, qText).xsboolean();
            return;
        }

        if ( attributeLocalName.equals(ATT_TAIL_RIGHT) ) {
            tailRight = SaxRestriction.attribute(handler, attributeLocalName, qText).xsboolean();
            return;
        }

        if ( attributeLocalName.equals(ATT_MEAN) ) {
            mean = SaxRestriction.attribute(handler, attributeLocalName, qText).xsdouble();
            return;
        }

        if ( attributeLocalName.equals(ATT_VARIANCE) ) {
            variance = SaxRestriction.attribute(handler, attributeLocalName, qText).xsdouble();
            return;
        }

        if ( attributeLocalName.equals(ATT_CPFORMAT) ) {
            fixedAttribute(handler, attributeLocalName, FIXED_CPFORMAT, qText);
            cpFormat = qText;
            return;
        }
    }

    protected String oqrwText( SaxHandler handler, String qText )
            throws SAXException {
        return null;
    }

    protected void end( SaxHandler handler )
            throws SAXException {
        requiredAttribute(handler, ATT_UNIT, unit);
        requiredAttribute(handler, ATT_TAIL_LEFT, tailLeft);
        requiredAttribute(handler, ATT_TAIL_RIGHT, tailRight);
        requiredAttribute(handler, ATT_MEAN, mean);
        requiredAttribute(handler, ATT_VARIANCE, variance);
        requiredAttribute(handler, ATT_CPFORMAT, cpFormat);

        final Iterator i = iterator(handler);
        xlControlPoints.add((ControlPointFactory)i.nextRequiredElement(TAG_CONTROL_POINT));
        while ( i.more(TAG_CONTROL_POINT) ) {
            xlControlPoints.add((ControlPointFactory)i.next());
        }
        i.requiredEnd();
    }
}
