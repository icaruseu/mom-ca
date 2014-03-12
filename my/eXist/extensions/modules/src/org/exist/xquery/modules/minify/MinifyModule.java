package org.exist.xquery.modules.minify;

import java.util.List;
import java.util.Map;

import org.exist.xquery.AbstractInternalModule;
import org.exist.xquery.FunctionDef;

public class MinifyModule extends AbstractInternalModule {

    public final static String NAMESPACE_URI = "http://exist-db.org/xquery/minify";

    public final static String PREFIX = "minify";
    public final static String INCLUSION_DATE = "2012-09-01";
    public final static String RELEASED_IN_VERSION = "eXist-2.1";

    private final static FunctionDef[] functions = {
        new FunctionDef(CssFunction.signature, CssFunction.class),
        new FunctionDef(JavascriptFunction.signature, JavascriptFunction.class)
    };

    public MinifyModule(Map<String, List<? extends Object>> parameters) {
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

    public String getDescription() {
        return "A module to minify CSS and Javascript files.";
    }

    public String getReleaseVersion() {
        return RELEASED_IN_VERSION;
    }

}