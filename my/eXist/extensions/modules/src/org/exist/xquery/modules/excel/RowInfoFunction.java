package org.exist.xquery.modules.excel;

import org.apache.poi.hssf.usermodel.HSSFRow;
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

public class RowInfoFunction extends ExcelFunction {

	public final static FunctionSignature signature =
		new FunctionSignature(
				new QName("rowinfo", ExcelModule.NAMESPACE_URI, ExcelModule.PREFIX),
				"returns a XML document with information about a row.",
				new SequenceType[] {
					new FunctionParameterSequenceType("workbook", Type.ANY_URI, Cardinality.EXACTLY_ONE, "URL of the workbook"),
					new FunctionParameterSequenceType("sheetnum", Type.INTEGER, Cardinality.EXACTLY_ONE, "number of the sheet"),
					new FunctionParameterSequenceType("rownum", Type.INTEGER, Cardinality.EXACTLY_ONE, "number of the row")
					},
				new FunctionReturnSequenceType(Type.NODE, Cardinality.EXACTLY_ONE, "a XML document with information about the cells found in the row."));

	public RowInfoFunction(XQueryContext context, FunctionSignature signature) {
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
		HSSFRow row = null;
		int rownum = 0;

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
			try {
				 rownum = Integer.parseInt(args[2].getStringValue()) - 1;
			} catch (NumberFormatException e) {
				e.printStackTrace();
			} catch (XPathException e) {
				e.printStackTrace();
			}

			if(rownum >= 0) row = sheet.getRow(rownum);

			if(row == null) {

				buildRowError(rownum + 1);
			}
			else {

				builder.startElement( new QName( "rowinfo", ExcelModule.NAMESPACE_URI, ExcelModule.PREFIX ), null );
				try {
					builder.addAttribute( new QName( "num","" ), args[2].itemAt(0).getStringValue() );
				} catch (XPathException e) {
					e.printStackTrace();
				}

				builder.startElement( new QName( "sheet", ExcelModule.NAMESPACE_URI, ExcelModule.PREFIX ), null );
				builder.addAttribute( new QName( "name","" ), row.getSheet().getSheetName() );
				try {
					builder.addAttribute( new QName( "num","" ), args[2].itemAt(0).getStringValue() );
				} catch (XPathException e) {
					e.printStackTrace();
				}
				builder.endElement();

				if(row.getLastCellNum() != 0) {

					// number of first cell which has any content
					builder.startElement( new QName( "firstcellnum", ExcelModule.NAMESPACE_URI, ExcelModule.PREFIX ), null );
					builder.addAttribute( new QName( "num","" ), String.valueOf(row.getFirstCellNum() + 1) );
					builder.endElement();

					// number of last cell which has any content
					builder.startElement( new QName( "lastcellnum", ExcelModule.NAMESPACE_URI, ExcelModule.PREFIX ), null );
					builder.addAttribute( new QName( "num","" ), String.valueOf(row.getLastCellNum()) );
					builder.endElement();
				}

				builder.endElement();

			}
		}

		builder.endDocument();

		xmlResponse = (NodeValue) builder.getDocument().getDocumentElement();

		return (xmlResponse);
	}
}
