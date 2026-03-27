package org.exist.xquery.modules.excel;

import java.util.List;
import java.util.Map;

import org.exist.xquery.AbstractInternalModule;
import org.exist.xquery.FunctionDef;

/**
 * eXist-db XQuery module for reading Excel (.xls) files via Apache POI.
 * Namespace: http://exist-db.org/xquery/excel
 */
public class ExcelModule extends AbstractInternalModule {

    public static final String NAMESPACE_URI = "http://exist-db.org/xquery/excel";
    public static final String PREFIX = "excel";
    public static final String DESCRIPTION = "Module for reading Microsoft Excel workbooks";

    public static final FunctionDef[] functions = {
        new FunctionDef(WorkbookInfoFunction.signature, WorkbookInfoFunction.class),
        new FunctionDef(SheetInfoFunction.signature, SheetInfoFunction.class),
        new FunctionDef(RowInfoFunction.signature, RowInfoFunction.class),
        new FunctionDef(SheetFunction.signature, SheetFunction.class)
    };

    public ExcelModule(Map<String, List<?>> parameters) {
        super(functions, parameters);
    }

    @Override
    public String getNamespaceURI() {
        return NAMESPACE_URI;
    }

    @Override
    public String getDefaultPrefix() {
        return PREFIX;
    }

    @Override
    public String getDescription() {
        return DESCRIPTION;
    }

    @Override
    public String getReleaseVersion() {
        return "1.0.0";
    }
}
