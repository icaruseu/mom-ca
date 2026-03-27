package org.exist.xquery.modules.excel;

import org.apache.poi.hssf.usermodel.HSSFSheet;
import org.apache.poi.hssf.usermodel.HSSFWorkbook;
import org.exist.dom.QName;
import org.exist.dom.memtree.MemTreeBuilder;
import org.exist.xquery.*;
import org.exist.xquery.value.*;

/**
 * excel:sheetinfo($workbook, $sheetnum) — returns row range info.
 */
public class SheetInfoFunction extends ExcelFunction {

    public static final FunctionSignature signature =
        new FunctionSignature(
            new QName("sheetinfo", ExcelModule.NAMESPACE_URI, ExcelModule.PREFIX),
            "Returns information about a specific sheet.",
            new SequenceType[] {
                new FunctionParameterSequenceType("workbook", Type.ANY_URI, Cardinality.EXACTLY_ONE, "URL of the workbook"),
                new FunctionParameterSequenceType("sheetnum", Type.INTEGER, Cardinality.EXACTLY_ONE, "Sheet number (1-based)")
            },
            new FunctionReturnSequenceType(Type.NODE, Cardinality.EXACTLY_ONE, "XML element with sheet info")
        );

    public SheetInfoFunction(XQueryContext context) {
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

        startElement("sheet");
        addElement("name", sheet.getSheetName());
        addElement("firstrow", String.valueOf(sheet.getFirstRowNum() + 1));
        addElement("lastrow", String.valueOf(sheet.getLastRowNum() + 1));
        endElement();

        return builder.getDocument();
    }
}
