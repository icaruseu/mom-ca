package net.monasterium.Import;

// TODO: Spezielle Sheet-Option, falls mehrere Sheets in der Excel-Datei vorhanden sind

import java.io.*;
import java.net.URL;
import java.util.ArrayList;

import javax.xml.transform.OutputKeys;
import javax.xml.transform.TransformerConfigurationException;
import javax.xml.transform.dom.DOMResult;
import javax.xml.transform.sax.TransformerHandler;
import javax.xml.transform.stream.StreamResult;
import javax.xml.transform.stream.StreamSource;

import org.xml.sax.*;
import org.xml.sax.helpers.*;

import org.apache.poi.hssf.usermodel.HSSFCell;
import org.apache.poi.hssf.usermodel.HSSFRow;
import org.apache.poi.hssf.usermodel.HSSFSheet;
import org.apache.poi.hssf.usermodel.HSSFWorkbook;
import org.apache.poi.poifs.filesystem.POIFSFileSystem;
import org.apache.poi.ss.usermodel.Cell;

public class ExcelReader extends AbstractReader
{	
	private static final Attributes EMPTY_ATTR = new AttributesImpl();
	public static HSSFWorkbook workbook;
	public HSSFSheet sheet;
	public static ArrayList<String>columnNames = new ArrayList<String>();
	

	ExcelReader() throws IOException, SAXNotRecognizedException, SAXNotSupportedException
	{
		POIFSFileSystem myFileSystem = 
			new POIFSFileSystem(new URL(Import.urlExcelSheet).openStream());
		workbook = new HSSFWorkbook(myFileSystem);
		sheet = workbook.getSheetAt(0);
		HSSFRow firstRow = sheet.getRow(0);
		int numColumns = firstRow.getLastCellNum();
		for(int numColumn = 0; numColumn < numColumns; numColumn++)
		{
			columnNames.add(firstRow.getCell(numColumn).getStringCellValue());
		}
	}
	
	public void parse(InputSource input) throws IOException, SAXException {}
	
	public boolean read(int numRow) throws IOException, TransformerConfigurationException
	{
		boolean empty = true;
		
		try 
		{	
			TransformerHandler th = XMLHandler.SAX_FACTORY.newTransformerHandler(
					new StreamSource(
							new URL("").openStream()));
			ContentHandler ch = th;
			
			th.setResult(new StreamResult(Import.tmpFile));
			
			ch.startDocument();
			String id = String.valueOf((Integer.valueOf(1) + Integer.valueOf(numRow)));
			
			ch.startElement("", "excelSheet", "excelSheet", EMPTY_ATTR);
			
			ch.startElement("", "id", "id", EMPTY_ATTR);
			ch.characters(id.toCharArray(), 0, id.length());
			ch.endElement("", "id", "id");
			
			HSSFRow firstRow = sheet.getRow(0);
			HSSFRow row = sheet.getRow(numRow);
			
			for(int numCell = 0; numCell < firstRow.getLastCellNum(); numCell++)
			{
				HSSFCell templateCell = firstRow.getCell(numCell, workbook.getMissingCellPolicy());
				HSSFCell labelCell = row.getCell(numCell, workbook.getMissingCellPolicy());
				
				if(templateCell != null && labelCell != null)
				{
					// force the cells to be in text format
					// since excel always assumes a generic type
					// we cannot know
					templateCell.setCellType(Cell.CELL_TYPE_STRING);
					labelCell.setCellType(Cell.CELL_TYPE_STRING);
					
					String[] tokens = labelCell.getStringCellValue().split("\\$\\$");
					String template = templateCell.getStringCellValue().trim();
					for(int numToken = 0; numToken < tokens.length; numToken++)
					{
						String label = tokens[numToken].trim();
						if(label != "")
						{
							empty = false;
							ch.startElement("", template, template, EMPTY_ATTR);
							ch.characters(label.toCharArray(), 0, label.length());
							ch.endElement("", template, template);
//							System.out.println("Template: " + template + " Label: " + label);
						}
					}
				}
				
			}
			
			ch.endElement("", "excelSheet", "excelSheet");
			ch.endDocument();
		} 
		catch (SAXException e) 
		{
			e.printStackTrace();
		}
		
		return empty;
	}
}
