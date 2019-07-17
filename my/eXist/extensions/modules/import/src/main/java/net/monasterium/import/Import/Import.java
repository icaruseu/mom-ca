package net.monasterium.Import;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;

import org.xml.sax.helpers.DefaultHandler;

public class Import
{
	public static String urlExcelSheet = null;
	
	private static XMLHandler xmlHandler = null;
	private static ExcelReader excelReader = null;
	
	public static File tmpFile = null;
	public static boolean VALID;
	
	public Import(String urlExcelSheet, 
			String dbDestinationCollection,
			String urlMappingXsl, 
			String urlConfigurationFile) throws Exception
	{
		this.urlExcelSheet = urlExcelSheet;

		tmpFile = File.createTempFile("tmp", ".xml");
		tmpFile.deleteOnExit();
		
		xmlHandler = new XMLHandler();
		excelReader = new ExcelReader();
		excelReader.setErrorHandler(new DefaultHandler());
	}
	
	public static void main(String[] args) throws Exception
	{
		Import i = 
			new Import(
					"http://localhost:8181/upload/1319468386240/test.xls", 
					"http://localhost/xmlrpc/db/test", 
					"http://localhost/mom/excel2cei.xsl", 
					"http://localhost/mom/excelimport.xml");
		i.execute();
		System.out.println("Finished");
	}
	
	public String execute() throws Exception
	{	
		for(int numRow = 1; numRow < excelReader.sheet.getLastRowNum(); numRow ++)
		{
			excelReader.read(numRow);
			ImportError.NUM_ROW = numRow;
			xmlHandler.validate(numRow);
		}
		
		BufferedReader reader = new BufferedReader( new FileReader (tmpFile.getPath()));
	    String line  = null;
	    StringBuilder stringBuilder = new StringBuilder();
	    String ls = System.getProperty("line.separator");
	    while( ( line = reader.readLine() ) != null ) {
	        stringBuilder.append( line );
	        stringBuilder.append( ls );
	    }
	    return stringBuilder.toString();
	}
}
