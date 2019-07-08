package org.exist.xquery.modules.excel;

import java.io.IOException;
import java.net.MalformedURLException;
import java.net.URL;

import org.apache.log4j.Logger;
import org.apache.poi.hssf.usermodel.HSSFSheet;
import org.apache.poi.hssf.usermodel.HSSFWorkbook;
import org.apache.poi.poifs.filesystem.POIFSFileSystem;
import org.exist.dom.QName;
import org.exist.dom.memtree.MemTreeBuilder;
import org.exist.xquery.BasicFunction;
import org.exist.xquery.FunctionSignature;
import org.exist.xquery.XPathException;
import org.exist.xquery.XQueryContext;
import org.exist.xquery.value.Item;
import org.exist.xquery.value.Sequence;

public abstract class ExcelFunction extends BasicFunction {

	private POIFSFileSystem fileSystem = null;
	private URL url = null;
		
	protected Sequence xmlResponse = null;
	protected MemTreeBuilder builder = null;
	
	public ExcelFunction(XQueryContext context, FunctionSignature signature) {
		super(context, signature);
		builder = context.getDocumentBuilder();
	}

	protected HSSFWorkbook getWorkbook(Sequence[] args) throws XPathException {
		
		HSSFWorkbook workbook = null;
		try {
			// get URL
			url = new URL(args[0].getStringValue());
			
			// initialize workbook 
			fileSystem = new POIFSFileSystem(url.openStream());
			workbook = new HSSFWorkbook(fileSystem);
			
		} catch (MalformedURLException e) {
			e.printStackTrace();
		} catch (IOException e) {
            throw( new XPathException( this, e ) );
		} catch (XPathException e) {
			e.printStackTrace();
		}

		return workbook;
	}
	
	protected HSSFSheet getSheet(HSSFWorkbook workbook, Sequence[] args) {
		
		HSSFSheet sheet = null;
		int sheetnum = 0;
		
		if( workbook != null) {
			try {
				sheetnum = Integer.parseInt(args[1].getStringValue()) - 1;
			} catch (NumberFormatException e) {
				e.printStackTrace();
			} catch (XPathException e) {
				e.printStackTrace();
			}
			
			if(sheetnum < workbook.getNumberOfSheets() && sheetnum >= 0) sheet = workbook.getSheetAt(sheetnum);
		}
			
		return sheet;
	}
	
	protected void buildWorkbookError() {
		
		builder.startElement( new QName( "error", ExcelModule.NAMESPACE_URI, ExcelModule.PREFIX ), null );
		builder.characters( "Workbook does not exist." );
		builder.endElement();		
	}
	
	protected void buildSheetError(int number) {
		
		builder.startElement( new QName( "error", ExcelModule.NAMESPACE_URI, ExcelModule.PREFIX ), null );
		builder.characters( "Sheet number '" + number + "' does not exist." );
		builder.endElement();		
	}
	
	protected void buildRowError(int number) {
		
		builder.startElement( new QName( "error", ExcelModule.NAMESPACE_URI, ExcelModule.PREFIX ), null );
		builder.characters( "Row number '" + number + "' does not exist." );
		builder.endElement();			
	}
	
	protected void buildCellError(int number) {
		
		builder.startElement( new QName( "error", ExcelModule.NAMESPACE_URI, ExcelModule.PREFIX ), null );
		builder.characters( "Cell number '" + number + "' does not exist." );
		builder.endElement();			
	}

}
