package net.monasterium.xquery.exista;

import java.io.IOException;
import java.net.MalformedURLException;
import java.net.URL;

import org.apache.poi.hssf.usermodel.HSSFSheet;
import org.apache.poi.hssf.usermodel.HSSFWorkbook;
import org.apache.poi.poifs.filesystem.POIFSFileSystem;
import org.exist.dom.QName;
import org.exist.memtree.MemTreeBuilder;
import org.exist.xquery.BasicFunction;
import org.exist.xquery.Cardinality;
import org.exist.xquery.FunctionSignature;
import org.exist.xquery.XPathException;
import org.exist.xquery.XQueryContext;
import org.exist.xquery.value.FunctionParameterSequenceType;
import org.exist.xquery.value.FunctionReturnSequenceType;
import org.exist.xquery.value.NodeValue;
import org.exist.xquery.value.Sequence;
import org.exist.xquery.value.SequenceType;
import org.exist.xquery.value.Type;

public class MappingFunction extends BasicFunction {

	final static String NAMESPACE_URI = ArchiveModule.NAMESPACE_URI;
	final static String PREFIX = ArchiveModule.PREFIX;
	
    public final static FunctionSignature signature =
		new FunctionSignature(
			new QName("map", ArchiveModule.NAMESPACE_URI, ArchiveModule.PREFIX),
			"maps several file formats into XML",
			new SequenceType[] { 
				new FunctionParameterSequenceType(
						"url-excel-file",
						Type.STRING,
						Cardinality.EXACTLY_ONE,
						"URL of Excel file to map"
						)
				},
			new FunctionReturnSequenceType(
					Type.STRING, 
					Cardinality.EXACTLY_ONE, 
					"mapped table as XML")
			);
    
	public MappingFunction(XQueryContext context) {
		super(context, signature);
	}
	
	public Sequence eval(Sequence[] args, Sequence contextSequence) throws XPathException {
		
		Sequence xmlResponse = null;
		
		String fileToMap = args[0].getStringValue();
		
		HSSFWorkbook workbook;
		HSSFSheet sheet;
		POIFSFileSystem myFileSystem;
		
		MemTreeBuilder builder = context.getDocumentBuilder();
		
		builder.startDocument();
		builder.startElement( new QName( "table", NAMESPACE_URI, PREFIX ), null );
		
		try {
			
			myFileSystem = new POIFSFileSystem(new URL(fileToMap).openStream());
			workbook = new HSSFWorkbook(myFileSystem);
			sheet = workbook.getSheetAt(0);
					
			for(int numRow = 1; numRow < sheet.getLastRowNum(); numRow ++) {
				
			}	
			
		} catch (MalformedURLException e) {
			e.printStackTrace();
		} catch (IOException e) {
			e.printStackTrace();
		}
		

		builder.endElement();
		builder.endDocument();
		
		xmlResponse = (NodeValue) builder.getDocument().getDocumentElement();
		
		return(xmlResponse);
	}
}