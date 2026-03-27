package org.exist.xquery.modules.excel;

import org.apache.poi.hssf.usermodel.HSSFRow;
import org.apache.poi.hssf.usermodel.HSSFSheet;
import org.apache.poi.hssf.usermodel.HSSFWorkbook;
import org.exist.dom.QName;
import org.exist.dom.memtree.MemTreeBuilder;
import org.exist.xquery.*;
import org.exist.xquery.value.*;

/**
 * excel:rowinfo($workbook, $sheetnum, $rownum) — returns cell range info.
 */
public class RowInfoFunction extends ExcelFunction {

    public static final FunctionSignature signature =
        new FunctionSignature(
            new QName("rowinfo", ExcelModule.NAMESPACE_URI, ExcelModule.PREFIX),
            "Returns information about a specific row.",
            new SequenceType[] {
                new FunctionParameterSequenceType("workbook", Type.ANY_URI, Cardinality.EXACTLY_ONE, "URL of the workbook"),
                new FunctionParameterSequenceType("sheetnum", Type.INTEGER, Cardinality.EXACTLY_ONE, "Sheet number (1-based)"),
                new FunctionParameterSequenceType("rownum", Type.INTEGER, Cardinality.EXACTLY_ONE, "Row number (1-based)")
            },
            new FunctionReturnSequenceType(Type.NODE, Cardinality.EXACTLY_ONE, "XML element with row info")
        );

    public RowInfoFunction(XQueryContext context) {
        super(context, signature);
    }

    @Override
    public Sequence eval(Sequence[] args, Sequence contextSequence) throws XPathException {
        builder = context.getDocumentBuilder();
        HSSFWorkbook workbook = getWorkbook(args);
        if (workbook == null) {
            buildError("workbook", "Could not open workbook");
            return builder.getDocument();
        }

        HSSFSheet sheet = getSheet(workbook, args);
        if (sheet == null) {
            buildError("sheet", "Sheet not found");
            return builder.getDocument();
        }

        int rownum = Integer.parseInt(args[2].getStringValue()) - 1;
        HSSFRow row = sheet.getRow(rownum);

        startElement("row");
        if (row != null) {
            addElement("number", String.valueOf(rownum + 1));
            addElement("firstcell", String.valueOf(row.getFirstCellNum() + 1));
            addElement("lastcell", String.valueOf(row.getLastCellNum()));
        } else {
            buildError("row", "Row " + (rownum + 1) + " not found");
        }
        endElement();

        return builder.getDocument();
    }
}
