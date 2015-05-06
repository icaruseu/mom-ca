package org.exist.xquery.modules.fuego;

import java.util.List;
import java.util.Map;

import org.exist.xquery.AbstractInternalModule;
import org.exist.xquery.FunctionDef;
import org.exist.xquery.modules.fuego.FuegoDiff;

public class FuegoModule extends AbstractInternalModule {

	public final static String NAMESPACE_URI = "https://github.com/ept/fuego-diff";
	public final static String PREFIX = "fuego";
	public final static String INCLUSION_DATE = "";
	public final static String RELEASED_IN_VERSION = "";
	
	private final static FunctionDef[] functions = {
		new FunctionDef(FuegoDiff.signature, FuegoDiff.class)
	};
	
	public FuegoModule(Map<String, List<? extends Object>> parameters) {
		super(functions, parameters);
	}
	
	public String getNamespaceURI() {
		return NAMESPACE_URI;
	}

	public String getDefaultPrefix() {
		return PREFIX;
	}

	public String getDescription() {
		return "A module to compare XMl files.";
	}

    public String getReleaseVersion() {
        return RELEASED_IN_VERSION;
    }
}

