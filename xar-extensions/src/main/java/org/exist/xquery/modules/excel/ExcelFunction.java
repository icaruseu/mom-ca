package org.exist.xquery.modules.excel;

import java.io.IOException;
import java.net.URL;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.apache.poi.hssf.usermodel.HSSFSheet;
import org.apache.poi.hssf.usermodel.HSSFWorkbook;
import org.apache.poi.poifs.filesystem.POIFSFileSystem;
import org.exist.dom.QName;
import org.exist.dom.memtree.MemTreeBuilder;
import org.exist.xquery.BasicFunction;
import org.exist.xquery.FunctionSignature;
import org.exist.xquery.XPathException;
import org.exist.xquery.XQueryContext;
import org.exist.xquery.value.Sequence;

/**
 * Abstract base class for Excel XQuery functions.
 * Provides common workbook/sheet loading via Apache POI.
 */
public abstract class ExcelFunction extends BasicFunction {

    private static final Logger LOG = LogManager.getLogger(ExcelFunction.class);

    protected MemTreeBuilder builder;

    public ExcelFunction(XQueryContext context, FunctionSignature signature) {
        super(context, signature);
    }

    protected HSSFWorkbook getWorkbook(Sequence[] args) throws XPathException {
        try {
            URL url = new URL(args[0].getStringValue());
            POIFSFileSystem fileSystem = new POIFSFileSystem(url.openStream());
            return new HSSFWorkbook(fileSystem);
        } catch (IOException e) {
            throw new XPathException(this, "Failed to open workbook: " + e.getMessage(), e);
        }
    }

    protected HSSFSheet getSheet(HSSFWorkbook workbook, Sequence[] args) throws XPathException {
        if (workbook == null) return null;
        try {
            int sheetnum = Integer.parseInt(args[1].getStringValue()) - 1;
            if (sheetnum >= 0 && sheetnum < workbook.getNumberOfSheets()) {
                return workbook.getSheetAt(sheetnum);
            }
            return null;
        } catch (NumberFormatException e) {
            throw new XPathException(this, "Invalid sheet number: " + e.getMessage(), e);
        }
    }

    protected void startElement(String name) {
        builder.startElement(new QName(name, ExcelModule.NAMESPACE_URI, ExcelModule.PREFIX), null);
    }

    protected void endElement() {
        builder.endElement();
    }

    protected void addElement(String name, String value) {
        startElement(name);
        builder.characters(value != null ? value : "");
        endElement();
    }

    protected void buildError(String type, String message) {
        startElement("error");
        addElement("type", type);
        addElement("message", message);
        endElement();
    }
}
