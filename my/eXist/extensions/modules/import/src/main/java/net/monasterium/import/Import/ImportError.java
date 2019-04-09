package net.monasterium.Import;


import org.xml.sax.ErrorHandler;
import org.xml.sax.SAXParseException;

public class ImportError implements ErrorHandler
{
	public static int NUM_ROW = 0;
	
    public void warning(SAXParseException ex) 
    {
		System.err.println("WARNING in row " + String.valueOf(NUM_ROW + 1));
        System.err.println(ex.getMessage());
    }

    public void fatalError(SAXParseException ex)
    {
		System.err.println("FATAL ERROR in row " + String.valueOf(NUM_ROW + 1));
		Import.VALID = false;
    	System.err.println(ex.getMessage());
    }
    
	public void error(SAXParseException ex)
	{
		System.err.println("ERROR in row " + String.valueOf(NUM_ROW + 1));
		Import.VALID = false;
		System.err.println(ex.getMessage());
	}
}
