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

public class WorkbookInfoFunction extends ExcelFunction {

	public final static FunctionSignature signature =
		new FunctionSignature(
				new QName("workbookinfo", ExcelModule.NAMESPACE_URI, ExcelModule.PREFIX),
				"returns a XML document with information about the workbook.",
				new SequenceType[] {
					new FunctionParameterSequenceType("workbook", Type.ANY_URI, Cardinality.EXACTLY_ONE, "URL of the workbook")
					},
				new FunctionReturnSequenceType(Type.NODE, Cardinality.EXACTLY_ONE, "a XML document with information about the sheets found in the workbook."));

	public WorkbookInfoFunction(XQueryContext context, FunctionSignature signature) {
		super(context, signature);
	}

	public Sequence eval(Sequence[] args, Sequence contextSequence) {

		HSSFWorkbook workbook = null;
		try {
			workbook = getWorkbook(args);
		} catch (XPathException e) {
			e.printStackTrace();
		}

		builder.startDocument();

		if(workbook == null) {

			buildWorkbookError();
		}
		else {

			builder.startElement( new QName( "workbookinfo", ExcelModule.NAMESPACE_URI, ExcelModule.PREFIX ), null );

			for(int i=0;i < workbook.getNumberOfSheets(); i++) {

				HSSFSheet sheet = workbook.getSheetAt(i);
				builder.startElement( new QName( "sheet", ExcelModule.NAMESPACE_URI, ExcelModule.PREFIX ), null );
				builder.addAttribute( new QName( "name","" ), sheet.getSheetName() );
				builder.addAttribute( new QName( "num","" ), String.valueOf(i + 1) );
				builder.endElement();
			}

			builder.endElement();
		}

		builder.endDocument();

		xmlResponse = (NodeValue) builder.getDocument().getDocumentElement();

		return (xmlResponse);
	}
}
