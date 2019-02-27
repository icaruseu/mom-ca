package org.exist.xquery.modules.excel;

import org.apache.poi.hssf.usermodel.HSSFCell;
import org.apache.poi.hssf.usermodel.HSSFRow;
import org.apache.poi.hssf.usermodel.HSSFSheet;
import org.apache.poi.hssf.usermodel.HSSFWorkbook;
import org.apache.poi.ss.usermodel.Cell;
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

public class SheetFunction extends ExcelFunction {

	public final static FunctionSignature signature =
		new FunctionSignature(
				new QName("sheet", ExcelModule.NAMESPACE_URI, ExcelModule.PREFIX),
				"returns a Excel sheet as a table in XML format",
				new SequenceType[] {
					new FunctionParameterSequenceType("workbook", Type.ANY_URI, Cardinality.EXACTLY_ONE, "URL of the workbook"),
					new FunctionParameterSequenceType("sheetnum", Type.INTEGER, Cardinality.EXACTLY_ONE, "number of the sheet"),
					new FunctionParameterSequenceType("rows", Type.INTEGER, Cardinality.ONE_OR_MORE, "sequence of row numbers"),
					new FunctionParameterSequenceType("cells", Type.INTEGER, Cardinality.ONE_OR_MORE, "sequence of cell numbers")
					},
				new FunctionReturnSequenceType(Type.NODE, Cardinality.EXACTLY_ONE, "a table in XML format representing the selected cells of the excel sheet"));

	public SheetFunction(XQueryContext context, FunctionSignature signature) {
		super(context, signature);
	}

	public Sequence eval(Sequence[] args, Sequence contextSequence) {

		HSSFWorkbook workbook = null;
		try {
			workbook = getWorkbook(args);
		} catch (XPathException e2) {
			e2.printStackTrace();
		}
		HSSFSheet sheet = getSheet(workbook, args);
		int rownum = 0, cellnum = 0;

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

			builder.startElement( new QName( "sheet", ExcelModule.NAMESPACE_URI, ExcelModule.PREFIX ), null );
			try {
				builder.addAttribute( new QName( "num","" ), args[1].itemAt(0).getStringValue() );
			} catch (XPathException e1) {
				e1.printStackTrace();
			}
			builder.addAttribute( new QName( "name","" ), sheet.getSheetName() );

			for(int i=0; i < args[2].getItemCount(); i++) {

				HSSFRow row = null;

				try {
					rownum = Integer.parseInt(args[2].itemAt(i).getStringValue()) - 1;
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

					builder.startElement( new QName( "row", ExcelModule.NAMESPACE_URI, ExcelModule.PREFIX ), null );
					builder.addAttribute( new QName( "num","" ), String.valueOf(rownum + 1));

					for(int j=0; j < args[3].getItemCount(); j++) {

						HSSFCell cell = null;

						try {
							cellnum = Integer.parseInt(args[3].itemAt(j).getStringValue()) - 1;
						} catch (NumberFormatException e) {
							e.printStackTrace();
						} catch (XPathException e) {
							e.printStackTrace();
						}

						cell = row.getCell(cellnum);

						if(cell == null) {

							// return a empty cell
							builder.startElement( new QName( "cell", ExcelModule.NAMESPACE_URI, ExcelModule.PREFIX ), null );
							builder.addAttribute( new QName( "num","" ), String.valueOf(cellnum + 1) );
							builder.endElement();
						}
						else {

							builder.startElement( new QName( "cell", ExcelModule.NAMESPACE_URI, ExcelModule.PREFIX ), null );
							builder.addAttribute( new QName( "num","" ), String.valueOf(cellnum + 1) );
							if(cell != null) {
								cell.setCellType(Cell.CELL_TYPE_STRING);
								builder.characters( cell.getStringCellValue() );
							}
							builder.endElement();
						}
					}

					builder.endElement();
				}
			}

			builder.endElement();
		}

		builder.endDocument();

		xmlResponse = (NodeValue) builder.getDocument().getDocumentElement();

		return (xmlResponse);
	}
}
