package org.exist.xquery.modules.excel;

import org.apache.poi.hssf.usermodel.HSSFCell;
import org.apache.poi.hssf.usermodel.HSSFRow;
import org.apache.poi.hssf.usermodel.HSSFSheet;
import org.apache.poi.hssf.usermodel.HSSFWorkbook;
import org.apache.poi.ss.usermodel.CellType;
import org.exist.dom.QName;
import org.exist.dom.memtree.MemTreeBuilder;
import org.exist.xquery.*;
import org.exist.xquery.value.*;

/**
 * excel:sheet($workbook, $sheetnum, $rows, $cells) — returns cell data as XML.
 */
public class SheetFunction extends ExcelFunction {

    public static final FunctionSignature signature =
        new FunctionSignature(
            new QName("sheet", ExcelModule.NAMESPACE_URI, ExcelModule.PREFIX),
            "Returns selected cells from a sheet as an XML table.",
            new SequenceType[] {
                new FunctionParameterSequenceType("workbook", Type.ANY_URI, Cardinality.EXACTLY_ONE, "URL of the workbook"),
                new FunctionParameterSequenceType("sheetnum", Type.INTEGER, Cardinality.EXACTLY_ONE, "Sheet number (1-based)"),
                new FunctionParameterSequenceType("rows", Type.INTEGER, Cardinality.ONE_OR_MORE, "Row numbers (1-based)"),
                new FunctionParameterSequenceType("cells", Type.INTEGER, Cardinality.ONE_OR_MORE, "Cell numbers (1-based)")
            },
            new FunctionReturnSequenceType(Type.NODE, Cardinality.EXACTLY_ONE, "XML table element")
        );

    public SheetFunction(XQueryContext context) {
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

        Sequence rowSeq = args[2];
        Sequence cellSeq = args[3];

        startElement("table");

        for (SequenceIterator rowIter = rowSeq.iterate(); rowIter.hasNext(); ) {
            int rownum = ((IntegerValue) rowIter.nextItem()).getInt() - 1;
            HSSFRow row = sheet.getRow(rownum);

            startElement("row");
            addElement("number", String.valueOf(rownum + 1));

            if (row != null) {
                for (SequenceIterator cellIter = cellSeq.iterate(); cellIter.hasNext(); ) {
                    int cellnum = ((IntegerValue) cellIter.nextItem()).getInt() - 1;
                    HSSFCell cell = row.getCell(cellnum);

                    startElement("cell");
                    addElement("number", String.valueOf(cellnum + 1));
                    if (cell != null) {
                        cell.setCellType(CellType.STRING);
                        addElement("value", cell.getStringCellValue());
                    } else {
                        addElement("value", "");
                    }
                    endElement();
                }
            }
            endElement();
        }
        endElement();

        return builder.getDocument();
    }
}
