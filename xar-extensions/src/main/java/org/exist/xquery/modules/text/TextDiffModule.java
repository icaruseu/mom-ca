package org.exist.xquery.modules.text;

import java.util.List;
import java.util.Map;

import org.exist.xquery.AbstractInternalModule;
import org.exist.xquery.FunctionDef;

/**
 * eXist-db XQuery module providing text:diff() using Google's diff-match-patch.
 * Namespace: http://exist-db.org/xquery/text
 *
 * Used by MOM-CA for charter version difference display.
 */
public class TextDiffModule extends AbstractInternalModule {

    public static final String NAMESPACE_URI = "http://exist-db.org/xquery/text";
    public static final String PREFIX = "text";
    public static final String DESCRIPTION = "Text diff module using Google diff-match-patch";

    public static final FunctionDef[] functions = {
        new FunctionDef(TextDiffFunction.signature, TextDiffFunction.class)
    };

    public TextDiffModule(Map<String, List<?>> parameters) {
        super(functions, parameters);
    }

    @Override
    public String getNamespaceURI() { return NAMESPACE_URI; }

    @Override
    public String getDefaultPrefix() { return PREFIX; }

    @Override
    public String getDescription() { return DESCRIPTION; }

    @Override
    public String getReleaseVersion() { return "1.0.0"; }
}
