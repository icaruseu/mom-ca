package org.exist.xquery.modules.excel;

import org.apache.poi.hssf.usermodel.HSSFSheet;
import org.apache.poi.hssf.usermodel.HSSFWorkbook;
import org.exist.dom.QName;
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

public class SheetInfoFunction extends ExcelFunction {

	public final static FunctionSignature signature =
		new FunctionSignature(
				new QName("sheetinfo", ExcelModule.NAMESPACE_URI, ExcelModule.PREFIX),
				"returns a XML document with information about a sheet.",
				new SequenceType[] {
					new FunctionParameterSequenceType("workbook", Type.ANY_URI, Cardinality.EXACTLY_ONE, "URL of the workbook"),
					new FunctionParameterSequenceType("sheetnum", Type.INTEGER, Cardinality.EXACTLY_ONE, "number of the sheet")
					},
				new FunctionReturnSequenceType(Type.NODE, Cardinality.EXACTLY_ONE, "a XML document with information about the rows found in the sheet."));

	public SheetInfoFunction(XQueryContext context, FunctionSignature signature) {
		super(context, signature);
	}

	public Sequence eval(Sequence[] args, Sequence contextSequence) {

		HSSFWorkbook workbook = null;
		try {
			workbook = getWorkbook(args);
		} catch (XPathException e1) {
			e1.printStackTrace();
		}
		HSSFSheet sheet = getSheet(workbook, args);

		builder.startDocument();

		if(workbook == null) {

			buildWorkbookError();
		}
		else if(sheet == null) {

			try {
				buildSheetError(Integer.parseInt(args[1].itemAt(0).getStringValue()));
			} catch (NumberFormatException e) {
				e.printStackTrace();
			} catch (XPathException e) {
				e.printStackTrace();
			}
		}
		else {

			builder.startElement( new QName( "sheetinfo", ExcelModule.NAMESPACE_URI, ExcelModule.PREFIX ), null );
			builder.addAttribute( new QName( "name","" ), sheet.getSheetName() );
			try {
				builder.addAttribute( new QName( "num","" ), args[1].itemAt(0).getStringValue() );
			} catch (XPathException e) {
				e.printStackTrace();
			}

			if(sheet.getLastRowNum() != 0) {

				// number of first row which has any content
				builder.startElement( new QName( "firstrownum", ExcelModule.NAMESPACE_URI, ExcelModule.PREFIX ), null );
				builder.addAttribute( new QName( "num","" ), String.valueOf(sheet.getFirstRowNum() + 1) );
				builder.endElement();

				// number of last row which has any content
				builder.startElement( new QName( "lastrownum", ExcelModule.NAMESPACE_URI, ExcelModule.PREFIX ), null );
				builder.addAttribute( new QName( "num","" ), String.valueOf(sheet.getLastRowNum() + 1) );
				builder.endElement();

			}

			builder.endElement();
		}

		builder.endDocument();

		xmlResponse = (NodeValue) builder.getDocument().getDocumentElement();

		return (xmlResponse);
	}
}
