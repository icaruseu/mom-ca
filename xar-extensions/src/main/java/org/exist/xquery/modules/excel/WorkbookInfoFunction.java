package org.exist.xquery.modules.excel;

import org.apache.poi.hssf.usermodel.HSSFWorkbook;
import org.exist.dom.QName;
import org.exist.dom.memtree.MemTreeBuilder;
import org.exist.xquery.*;
import org.exist.xquery.value.*;

import static org.exist.xquery.FunctionDSL.*;

/**
 * excel:workbookinfo($workbook as xs:anyURI) — returns sheet listing.
 */
public class WorkbookInfoFunction extends ExcelFunction {

    public static final FunctionSignature signature =
        new FunctionSignature(
            new QName("workbookinfo", ExcelModule.NAMESPACE_URI, ExcelModule.PREFIX),
            "Returns information about the sheets in an Excel workbook.",
            new SequenceType[] {
                new FunctionParameterSequenceType("workbook", Type.ANY_URI, Cardinality.EXACTLY_ONE, "URL of the workbook")
            },
            new FunctionReturnSequenceType(Type.NODE, Cardinality.EXACTLY_ONE, "XML element with sheet info")
        );

    public WorkbookInfoFunction(XQueryContext context) {
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

        startElement("workbook");
        int numSheets = workbook.getNumberOfSheets();
        for (int i = 0; i < numSheets; i++) {
            startElement("sheet");
            addElement("number", String.valueOf(i + 1));
            addElement("name", workbook.getSheetName(i));
            endElement();
        }
        endElement();

        return builder.getDocument();
    }
}
