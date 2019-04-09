package net.monasterium.Import;

import java.io.*;
import java.util.*;

import javax.xml.transform.TransformerConfigurationException;
import javax.xml.transform.stream.StreamResult;

import org.xml.sax.*;

public abstract class AbstractReader implements org.xml.sax.XMLReader {
	private Map featureMap = new HashMap();
	private Map propertyMap = new HashMap();
	private EntityResolver entityResolver;
	private DTDHandler dtdHandler;
	private ContentHandler contentHandler;
	private ErrorHandler errorHandler;
	
	public abstract void parse(InputSource input) throws IOException, SAXException;
	
	public void setEntityResolver(EntityResolver entityResolver)
	{
		this.entityResolver = entityResolver;
	}
	
	public EntityResolver getEntityResolver()
	{
		return this.entityResolver;
	}
	
	public void setDTDHandler(DTDHandler dtdHandler)
	{
		this.dtdHandler = dtdHandler;
	}
	
	public boolean getFeature(String name) throws SAXNotRecognizedException, SAXNotSupportedException
	{
		Boolean feature = (Boolean) this.featureMap.get(name);
		return (feature == null) ? false : feature.booleanValue();
	}
	
	public Object getProperty(String name) throws SAXNotRecognizedException, SAXNotSupportedException
	{
		return this.propertyMap.get(name);
	}
	
	public DTDHandler getDTDHandler()
	{
		return this.dtdHandler;
	}
	
	public void setFeature(String name, boolean value) throws SAXNotRecognizedException, SAXNotSupportedException
	{
		this.featureMap.put(name, new Boolean(value));
	}
	
	public void setProperty(String name, Object value) throws SAXNotRecognizedException, SAXNotSupportedException
	{
		this.propertyMap.put(name, value);
	}
	
	public ErrorHandler getErrorHandler()
	{
		return this.errorHandler;
	}

	public ContentHandler getContentHandler()
	{
		return this.contentHandler;
	}
	
	public void setErrorHandler(ErrorHandler errorHandler)
	{
		this.errorHandler = errorHandler;
	}
	
	public void setContentHandler(ContentHandler contentHandler)
	{
		this.contentHandler = contentHandler;
	}
	
	public void parse(String systemId) throws IOException, SAXException {}

	public abstract boolean read(int row) throws IOException, TransformerConfigurationException;
}
