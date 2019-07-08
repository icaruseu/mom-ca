package net.monasterium.xquery.exista;

import java.util.List;
import java.util.Map;

import org.exist.xquery.AbstractInternalModule;
import org.exist.xquery.FunctionDef;

public class ArchiveModule extends AbstractInternalModule {

	public final static String NAMESPACE_URI = "http://www.monasterium.net/NS/exista";
	public final static String PREFIX = "exista";
	public final static String INCLUSION_DATE = "2011-01-24";
	public final static String RELEASED_IN_VERSION = "eXist/A-0.1";
	
	private final static FunctionDef[] functions = {
		new FunctionDef(TransactFunction.signature, TransactFunction.class),
		new FunctionDef(MappingFunction.signature, MappingFunction.class)
	};
	
	public ArchiveModule(Map<String, List<? extends Object>> parameters) {
		super(functions, parameters);
	}
	
	public String getNamespaceURI() {
		return NAMESPACE_URI;
	}

	public String getDefaultPrefix() {
		return PREFIX;
	}

	public String getDescription() {
		return "A module for projects using eXist as a Digital Archive.";
	}

    public String getReleaseVersion() {
        return RELEASED_IN_VERSION;
    }
}
