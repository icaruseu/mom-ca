package net.monasterium.Import;


import java.io.File;
import java.io.IOException;
import java.net.MalformedURLException;
import java.net.URI;
import java.net.URL;

import javax.xml.transform.OutputKeys;
import javax.xml.transform.Source;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerConfigurationException;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.sax.SAXResult;
import javax.xml.transform.sax.SAXSource;
import javax.xml.transform.sax.SAXTransformerFactory;
import javax.xml.transform.sax.TransformerHandler;
import javax.xml.transform.stream.StreamSource;
import javax.xml.validation.Schema;
import javax.xml.validation.SchemaFactory;
import javax.xml.validation.Validator;

import org.xml.sax.InputSource;
import org.xml.sax.SAXException;
import org.xml.sax.helpers.DefaultHandler;

public class XMLHandler {

	public static TransformerFactory FACTORY = null;
	public static Transformer TRANSFORMER = null; 
	public static TransformerHandler TRANSFORMER_HANDLER = null;
	public static SAXTransformerFactory SAX_FACTORY = null;
	public static Source SOURCE_EXCEL_XSL = null;
	public static DefaultHandler DEFAULT_HANDLER = null;
	public static SAXResult SAX_RESULT = null;
	
	public static String FILE_CEI_SCHEMA = "http://mom.uni-koeln.de:8080/MOM-CA/schema/cei_MOM_Lite_strict.xsd";
//	public static String FILE_CEI_SCHEMA = "C:/MOM-CA/MOM-CA/WebContent/schema/cei_MOM_Lite_strict.xsd";
//	public static String FILE_TMP_RESULT = "tmp/result.xml";

	public static Schema CEI_SCHEMA = null;
	public static Validator CEI_VALIDATOR = null;
	
	XMLHandler() throws TransformerConfigurationException, SAXException, MalformedURLException, IOException
	{
		FACTORY = TransformerFactory.newInstance();
		SOURCE_EXCEL_XSL = new StreamSource(new URL(Import.urlExcelSheet).openStream());
		TRANSFORMER = FACTORY.newTransformer(SOURCE_EXCEL_XSL);
		SAX_FACTORY = (SAXTransformerFactory)FACTORY;


	    String schemaLang = "http://www.w3.org/2001/XMLSchema";
	    SchemaFactory jaxp = SchemaFactory.newInstance(schemaLang);
	    CEI_SCHEMA = jaxp.newSchema(new StreamSource(FILE_CEI_SCHEMA));
	    CEI_VALIDATOR = CEI_SCHEMA.newValidator();
	    ImportError err = new ImportError(); 
	    CEI_VALIDATOR.setErrorHandler(err);
	    DEFAULT_HANDLER = new DefaultHandler();
	    SAX_RESULT = new SAXResult(DEFAULT_HANDLER);
	}

	public void validate(int row)
	{
		try
		{
		    SAXSource source = new SAXSource(new InputSource(Import.tmpFile.getPath()));
		    CEI_VALIDATOR.validate(source, XMLHandler.SAX_RESULT);
		}
		catch (SAXException e)
		{	
			e.printStackTrace();
		}
		catch (Exception e)
		{
			e.printStackTrace();
		}
	}
}
