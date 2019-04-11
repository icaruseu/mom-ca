package org.exist.xquery.modules.excel;

import java.util.List;
import java.util.Map;

import org.exist.xquery.AbstractInternalModule;
import org.exist.xquery.FunctionDef;

public class ExcelModule extends AbstractInternalModule {

	public final static String NAMESPACE_URI = "http://exist-db.org/xquery/excel";
	public final static String PREFIX = "excel";
	public final static String INCLUSION_DATE = "";
	public final static String RELEASED_IN_VERSION = "";
	
	private final static FunctionDef[] functions = {
		new FunctionDef(WorkbookInfoFunction.signature, WorkbookInfoFunction.class),
		new FunctionDef(SheetInfoFunction.signature, SheetInfoFunction.class),
		new FunctionDef(RowInfoFunction.signature, RowInfoFunction.class),
		new FunctionDef(SheetFunction.signature, SheetFunction.class)
	};
	
	public ExcelModule(Map<String, List<? extends Object>> parameters) {
		super(functions, parameters);
	}
	
	public String getNamespaceURI() {
		return NAMESPACE_URI;
	}

	public String getDefaultPrefix() {
		return PREFIX;
	}

	public String getDescription() {
		return "A module to read Excel files.";
	}

    public String getReleaseVersion() {
        return RELEASED_IN_VERSION;
    }
}

